import 'dart:async';
import 'dart:io';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/utils/uuid_generator.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/outbound/data/outbound_clock.dart';
import 'package:eerl_app/features/outbound/data/outbound_queries.dart';
import 'package:eerl_app/features/outbound/data/outbound_writes.dart';
import 'package:flutter/material.dart';

/// The outbound screens' link to the phone's SQLite database.
///
/// The host app opens one when it shows the Driver or Pickup Supervisor
/// module ([OutboundLiveScope]). Screens read [OutboundLiveSession.of]: a
/// `null` session means a preview or a widget test, where every screen keeps
/// its static design content. Every read goes through [queries] and every
/// change through [writes] (row + outbox in one transaction), as the outbound
/// SQLite doc says; after a change the session starts the outbox and the
/// screens reload when [changes] ticks.
class OutboundLiveSession {
  OutboundLiveSession._({
    required this.actor,
    required this.queries,
    required this.writes,
    required this.clock,
    AppDatabase? database,
    BootstrapSyncService? sync,
  }) : _database = database ?? AppDatabase.instance,
       _sync = sync; // ignore: prefer_initializing_formals

  final OutboundActor actor;
  final OutboundQueries queries;
  final OutboundWrites writes;
  final OutboundClock clock;
  final AppDatabase _database;
  final BootstrapSyncService? _sync;

  /// Ticks after a local change or a finished sync: screens reload.
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  /// Opens a session for the signed-in user (`me.user` in `sync_meta`).
  /// Null before the first `/bootstrap` stored who is signed in.
  static Future<OutboundLiveSession?> open({
    AppDatabase? database,
    BootstrapSyncService? sync,
    OutboundClock? clock,
  }) async {
    final db = database ?? AppDatabase.instance;
    final id = await db.getSyncMeta('user_id');
    if (id == null || id.isEmpty) return null;
    final actor = OutboundActor(
      id: id,
      name: await db.getSyncMeta('user_name') ?? '',
      phone: await db.getSyncMeta('user_phone'),
    );
    final time = clock ?? OutboundClock();
    return OutboundLiveSession._(
      actor: actor,
      queries: OutboundQueries(actorId: id, database: db, clock: time),
      writes: OutboundWrites(actor: actor, database: db, clock: time),
      clock: time,
      database: db,
      sync: sync ?? BootstrapSyncService.instance,
    );
  }

  /// A test or preview session over a given database (no sync service).
  @visibleForTesting
  static OutboundLiveSession forTesting({
    required OutboundActor actor,
    required AppDatabase database,
    required OutboundClock clock,
  }) => OutboundLiveSession._(
    actor: actor,
    queries: OutboundQueries(
      actorId: actor.id,
      database: database,
      clock: clock,
    ),
    writes: OutboundWrites(actor: actor, database: database, clock: clock),
    clock: clock,
    database: database,
  );

  static OutboundLiveSession? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_OutboundLiveInherited>()
      ?.session;

  /// A new app-made id (uuid v4) for a record the phone creates.
  String newId() => UuidGenerator.v4();

  /// Puts a photo or voice note into the fixed-point photo queue. The id it
  /// returns goes in the write's body where the URL goes; the outbox item
  /// waits for the upload and the id is swapped for the URL before sending.
  Future<String> stagePhoto({
    required String localPath,
    required String ownerTable,
    required String ownerId,
    required String field,
    required String purpose,
    String contentType = 'image/jpeg',
  }) async {
    final id = newId();
    int? size;
    try {
      size = await File(localPath).length();
    } on FileSystemException {
      size = null;
    }
    await _database.insert(DatabaseTables.photos, {
      'id': id,
      'owner_table': ownerTable,
      'owner_id': ownerId,
      'field': field,
      'purpose': purpose,
      'content_type': contentType,
      'local_path': localPath,
      'status': 'local',
      'size_bytes': size,
      'created_at': clock.now,
    });
    return id;
  }

  /// Runs a queued write, then tells the screens and starts the outbox.
  Future<T> change<T>(Future<T> Function() write) async {
    final result = await write();
    changes.value++;
    final sync = _sync;
    if (sync != null) unawaited(sync.triggerAfterLocalMutation());
    return result;
  }

  /// Sync now (pull to refresh, the Sync now button).
  Future<void> syncNow() async {
    final sync = _sync;
    if (sync == null) return;
    await sync.triggerBootstrap(trigger: BootstrapTrigger.pullToRefresh);
    changes.value++;
  }

  void _onSync() => changes.value++;

  void _attach() => _sync?.addListener(_onSync);

  void _detach() => _sync?.removeListener(_onSync);
}

/// Opens an [OutboundLiveSession] for its subtree, and for every screen the
/// subtree pushes (the host wraps its Navigator, or the module's routes, in
/// it). While opening, [child] shows without a session.
class OutboundLiveScope extends StatefulWidget {
  const OutboundLiveScope({super.key, required this.child, this.session});

  final Widget child;

  /// A ready session (tests); otherwise one is opened.
  final OutboundLiveSession? session;

  @override
  State<OutboundLiveScope> createState() => _OutboundLiveScopeState();
}

class _OutboundLiveScopeState extends State<OutboundLiveScope> {
  OutboundLiveSession? _session;
  BootstrapSyncService? _watched;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    final given = widget.session;
    if (given != null) {
      _use(given);
      return;
    }
    // The signed-in user appears after the first /bootstrap and changes on
    // logout: check again after every sync.
    _watched = BootstrapSyncService.instance..addListener(_reopenIfUserChanged);
    _reopenIfUserChanged();
  }

  Future<void> _reopenIfUserChanged() async {
    if (_opening) return;
    _opening = true;
    try {
      final userId = await AppDatabase.instance.getSyncMeta('user_id');
      if (!mounted || userId == _session?.actor.id) return;
      final next = (userId == null || userId.isEmpty)
          ? null
          : await OutboundLiveSession.open();
      if (!mounted) return;
      setState(() {
        _session?._detach();
        _session = null;
        if (next != null) _use(next);
      });
    } finally {
      _opening = false;
    }
  }

  void _use(OutboundLiveSession session) {
    _session = session.._attach();
  }

  @override
  void dispose() {
    _watched?.removeListener(_reopenIfUserChanged);
    _session?._detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _OutboundLiveInherited(session: _session, child: widget.child);
}

class _OutboundLiveInherited extends InheritedWidget {
  const _OutboundLiveInherited({required this.session, required super.child});

  final OutboundLiveSession? session;

  @override
  bool updateShouldNotify(_OutboundLiveInherited oldWidget) =>
      oldWidget.session != session;
}

/// Rebuilds [builder] with fresh data whenever the session changes.
/// Without a session (preview, widget test) it shows [fallback].
class OutboundLiveBuilder<T> extends StatefulWidget {
  const OutboundLiveBuilder({
    super.key,
    required this.load,
    required this.builder,
    required this.fallback,
  });

  final Future<T> Function(OutboundLiveSession session) load;
  final Widget Function(
    BuildContext context,
    T data,
    OutboundLiveSession session,
  )
  builder;
  final Widget fallback;

  @override
  State<OutboundLiveBuilder<T>> createState() => _OutboundLiveBuilderState<T>();
}

class _OutboundLiveBuilderState<T> extends State<OutboundLiveBuilder<T>> {
  OutboundLiveSession? _session;
  Future<T>? _future;
  T? _last;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = OutboundLiveSession.of(context);
    if (session != _session) {
      _session?.changes.removeListener(_reload);
      _session = session;
      session?.changes.addListener(_reload);
      _reload();
    }
  }

  void _reload() {
    final session = _session;
    if (session == null) return;
    final future = widget.load(session);
    if (mounted) {
      setState(() {
        _future = future;
      });
    } else {
      _future = future;
    }
  }

  @override
  void dispose() {
    _session?.changes.removeListener(_reload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session == null) return widget.fallback;
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) _last = snapshot.data;
        final data = _last;
        if (data == null) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        }
        return widget.builder(context, data, session);
      },
    );
  }
}
