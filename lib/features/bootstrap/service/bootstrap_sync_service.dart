import 'dart:async';
import 'dart:io';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/network/internet_connectivity_service.dart';
import 'package:eerl_app/features/auth/data/auth_session_storage.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_database_applier.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_remote_service.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_repository.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_log.dart';
import 'package:eerl_app/features/bootstrap/service/item_image_cache_service.dart';
import 'package:flutter/foundation.dart';

enum BootstrapTrigger {
  initialLogin,
  appOpen,
  appResume,
  reconnect,
  localMutation,
  outboxFinished,
  pullToRefresh,
}

class BootstrapSyncService extends ChangeNotifier {
  BootstrapSyncService._({
    required this._gateway,
    required this._database,
    required this._applier,
    required this._itemImageCache,
    required this._accessTokenProvider,
    required this._onSessionExpired,
    required this._internetAccessChecker,
  });

  factory BootstrapSyncService.forTesting({
    required BootstrapGateway gateway,
    AppDatabase? database,
    BootstrapDatabaseApplier? applier,
    ItemImageCacheService? itemImageCache,
    required Future<String?> Function() accessTokenProvider,
    Future<void> Function()? onSessionExpired,
    Future<bool> Function()? internetAccessChecker,
  }) {
    final resolvedDatabase = database ?? AppDatabase.instance;
    return BootstrapSyncService._(
      gateway: gateway,
      database: resolvedDatabase,
      applier: applier ?? BootstrapDatabaseApplier(database: resolvedDatabase),
      itemImageCache:
          itemImageCache ?? ItemImageCacheService(database: resolvedDatabase),
      accessTokenProvider: accessTokenProvider,
      onSessionExpired: onSessionExpired ?? () async {},
      internetAccessChecker: internetAccessChecker ?? () async => true,
    );
  }

  static final BootstrapSyncService instance = BootstrapSyncService._(
    gateway: BootstrapRepository(),
    database: AppDatabase.instance,
    applier: BootstrapDatabaseApplier(),
    itemImageCache: ItemImageCacheService.instance,
    accessTokenProvider: AuthSessionStorage().getAccessToken,
    onSessionExpired: AuthSessionStorage().clearSession,
    internetAccessChecker:
        InternetConnectivityService.instance.hasInternetAccess,
  );

  static const _maximumPagesPerRun = 100;

  final BootstrapGateway _gateway;
  final AppDatabase _database;
  final BootstrapDatabaseApplier _applier;
  final ItemImageCacheService _itemImageCache;
  final Future<String?> Function() _accessTokenProvider;
  final Future<void> Function() _onSessionExpired;
  // Nullable so a singleton retained across Flutter hot reload can safely
  // fall back when this field did not exist on the original instance.
  final Future<bool> Function()? _internetAccessChecker;

  Future<void> Function()? _beforeBootstrap;
  Future<void>? _activeRun;
  bool _running = false;
  bool _runAgain = false;
  bool _disposed = false;
  bool _isSyncing = false;
  int _pageNumber = 0;
  int _revision = 0;
  Object? _lastError;

  bool get isSyncing => _isSyncing;
  int get pageNumber => _pageNumber;
  int get revision => _revision;
  Object? get lastError => _lastError;
  bool get sessionExpired =>
      _lastError is BootstrapApiException &&
      (_lastError as BootstrapApiException).statusCode == 401;

  /// Registers the outbox/photo sender that runs before Bootstrap.
  void configureOutgoingSync(Future<void> Function()? callback) {
    _beforeBootstrap = callback;
  }

  Future<void> triggerBootstrap({required BootstrapTrigger trigger}) {
    _log('Trigger received: ${trigger.name}');
    if (_running) {
      _runAgain = true;
      _log('Sync already running; queued one additional run');
      return _activeRun ?? Future<void>.value();
    }

    final run = _runQueued(trigger);
    _activeRun = run;
    return run;
  }

  Future<void> triggerAfterOutboxFinished() {
    return triggerBootstrap(trigger: BootstrapTrigger.outboxFinished);
  }

  /// Starts the outgoing queue after a local transaction has committed.
  ///
  /// The configured outgoing sync uploads blocking photos first, sends the
  /// queued API request, and then Bootstrap refreshes the local server state.
  Future<void> triggerAfterLocalMutation() {
    return triggerBootstrap(trigger: BootstrapTrigger.localMutation);
  }

  Future<void> _runQueued(BootstrapTrigger initialTrigger) async {
    _running = true;
    var trigger = initialTrigger;
    try {
      do {
        _runAgain = false;
        _setSyncState(syncing: true, page: 0, error: null);
        try {
          await _performBootstrap(trigger);
          _revision++;
          _log('Bootstrap finished');
        } catch (error) {
          _lastError = error;
          if (error is BootstrapApiException && error.statusCode == 401) {
            await _onSessionExpired();
          }
          _log('Bootstrap stopped safely: $error');
        } finally {
          _setSyncState(syncing: false, page: _pageNumber);
        }
        trigger = BootstrapTrigger.outboxFinished;
      } while (_runAgain);
    } finally {
      _running = false;
      _activeRun = null;
    }
  }

  Future<void> _performBootstrap(BootstrapTrigger trigger) async {
    if (!await _hasInternetAccess()) {
      _log('Skipped ${trigger.name}: internet is unavailable');
      return;
    }
    final accessToken = await _accessTokenProvider();
    if (accessToken == null || accessToken.trim().isEmpty) {
      _log('Skipped ${trigger.name}: no authenticated session');
      return;
    }

    _log(
      'Authentication ready: locally stored access token loaded; '
      'Bearer header will be attached to every Bootstrap request',
    );
    _log('Bootstrap start: trigger=${trigger.name}');
    await _beforeBootstrap?.call();
    final activeOutboxCount = await _outboxCount(
      where: "status IN ('queued', 'sending')",
    );
    if (activeOutboxCount > 0) {
      _log(
        'Bootstrap postponed: $activeOutboxCount outgoing item(s) still active',
      );
      return;
    }

    final itemImagesNeedRefetch =
        await _database.getSyncMeta('item_images_refetch_required') == '1';
    final transferDispatchNeedsRefetch =
        await _database.getSyncMeta('transfer_dispatch_refetch_required') ==
        '1';
    final schemaRefetchRequired =
        itemImagesNeedRefetch || transferDispatchNeedsRefetch;
    var schemaResetDone = false;
    String? cursor = await _database.getSyncMeta('cursor');
    if (cursor != null && cursor.isEmpty) cursor = null;
    _log(cursor == null ? 'Starting full/first sync' : 'Starting cursor sync');

    var page = 0;
    var invalidCursorResetUsed = false;
    var identityResetCount = 0;

    while (true) {
      page++;
      if (page > _maximumPagesPerRun) {
        throw StateError('Bootstrap exceeded $_maximumPagesPerRun pages');
      }
      _setSyncState(syncing: true, page: page);
      _log('Request page $page; has cursor: ${cursor == null ? 'no' : 'yes'}');

      BootstrapResponse response;
      try {
        response = await _gateway.fetch(
          accessToken: accessToken,
          since: cursor,
        );
      } on BootstrapApiException catch (error) {
        if (error.isInvalidCursor &&
            cursor != null &&
            !invalidCursorResetUsed) {
          _log('Server rejected cursor; resetting server-backed scope');
          invalidCursorResetUsed = true;
          await _requireDrainedOutboxForReset();
          await _database.scopeReset();
          cursor = null;
          page = 0;
          continue;
        }
        rethrow;
      }

      // Wait for one successful network response before clearing synced data.
      // This preserves the existing offline catalogue when the app is upgraded
      // without connectivity. The fetched page is intentionally discarded;
      // the next request is a full download without a cursor.
      if (schemaRefetchRequired && !schemaResetDone) {
        _log(
          'Local schema upgraded and network is available; resetting scope '
          'for a full Bootstrap fetch',
        );
        await _requireDrainedOutboxForReset();
        await _database.scopeReset();
        cursor = null;
        page = 0;
        schemaResetDone = true;
        continue;
      }

      final data = response.data;
      _logPage(data);

      final resetReason = await _identityResetReason(data.me);
      if (resetReason != null) {
        identityResetCount++;
        if (identityResetCount > 2) {
          throw StateError('Bootstrap identity kept changing: $resetReason');
        }
        _log('$resetReason; resetting and downloading without cursor');
        if (resetReason == 'Different authenticated user') {
          await _fullUserReset();
        } else {
          await _requireDrainedOutboxForReset();
          await _database.scopeReset();
        }
        cursor = null;
        page = 0;
        continue;
      }

      await _applier.apply(data);

      if (!data.hasMore) break;
      if (data.cursor == cursor) {
        throw StateError(
          'Bootstrap returned the same cursor while hasMore was true',
        );
      }
      cursor = data.cursor;
    }
    await _itemImageCache.reconcile();
    if (schemaResetDone) {
      if (itemImagesNeedRefetch) {
        await _database.setSyncMeta('item_images_refetch_required', '0');
      }
      if (transferDispatchNeedsRefetch) {
        await _database.setSyncMeta('transfer_dispatch_refetch_required', '0');
      }
      _log('One-time schema full refetch completed');
    }
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final checker = _internetAccessChecker;
      return await (checker ??
          InternetConnectivityService.instance.hasInternetAccess)();
    } on Object catch (error) {
      _log('Internet check failed safely: $error');
      return false;
    }
  }

  Future<String?> _identityResetReason(BootstrapMe? me) async {
    if (me == null) return null;
    final storedUserId = await _database.getSyncMeta('user_id');
    final incomingUserId = me.user?.id;
    if (storedUserId != null &&
        incomingUserId != null &&
        storedUserId != incomingUserId) {
      return 'Different authenticated user';
    }

    final storedScopeKey = await _database.getSyncMeta('scope_key');
    final incomingScopeKey = me.scopeKey;
    if (storedScopeKey != null &&
        incomingScopeKey != null &&
        storedScopeKey != incomingScopeKey) {
      return 'Bootstrap scope changed';
    }
    return null;
  }

  Future<void> clearForLogout() => _fullUserReset();

  Future<int> _outboxCount({String? where}) async {
    final rows = await _database.rawQuery(
      'SELECT COUNT(*) AS total FROM ${DatabaseTables.outbox}'
      '${where == null ? '' : ' WHERE $where'}',
    );
    return (rows.single['total'] as num?)?.toInt() ?? 0;
  }

  Future<void> _requireDrainedOutboxForReset() async {
    final count = await _outboxCount();
    if (count != 0) {
      throw StateError(
        'Scope reset postponed until all $count outgoing item(s) are resolved.',
      );
    }
  }

  Future<void> _fullUserReset() async {
    final photoRows = await _database.query(
      DatabaseTables.photos,
      columns: const ['local_path'],
      where: 'local_path IS NOT NULL',
    );
    await _database.clearDatabaseOnLogout();
    await _itemImageCache.clear();
    for (final row in photoRows) {
      final path = row['local_path'];
      if (path is! String || path.isEmpty) continue;
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } on FileSystemException catch (error) {
        _log('Could not remove a local photo during reset: $error');
      }
    }
  }

  void _logPage(BootstrapData data) {
    _log(
      'Response cursor=${data.cursor}, hasMore=${data.hasMore}, '
      'full=${data.full}, tables=${data.tables.keys.join(',')}',
    );
    for (final entry in data.tables.entries) {
      _log(
        '${entry.key}: replace=${entry.value.replace.length}, '
        'upserts=${entry.value.upserts.length}, '
        'deletes=${entry.value.deletes.length}',
      );
    }
  }

  void _setSyncState({
    required bool syncing,
    required int page,
    Object? error,
  }) {
    _isSyncing = syncing;
    _pageNumber = page;
    if (error != null || syncing) _lastError = error;
    if (!_disposed) notifyListeners();
  }

  static void _log(String message) {
    BootstrapLog.sync(message);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
