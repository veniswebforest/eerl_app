import 'dart:io';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_repository.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/bootstrap/service/item_image_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  late String databasePath;
  late Directory imageDirectory;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(
      await getDatabasesPath(),
      'bootstrap_outbox_order_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
    imageDirectory = await Directory.systemTemp.createTemp(
      'bootstrap_outbox_order_',
    );
  });

  setUp(() => database.clearDatabaseOnLogout());

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
    await imageDirectory.delete(recursive: true);
  });

  test('does not call Bootstrap while a failed outbox row remains', () async {
    await _insertOutbox(database, status: 'failed');
    final gateway = _RecordingGateway();
    final service = _service(
      database,
      gateway,
      imageDirectory,
      beforeBootstrap: () async {},
    );

    await service.triggerBootstrap(trigger: BootstrapTrigger.localMutation);

    expect(gateway.fetchCount, 0);
    expect(await database.query(DatabaseTables.outbox), hasLength(1));
  });

  test('calls Bootstrap only after outgoing sync empties the queue', () async {
    await _insertOutbox(database, status: 'queued');
    final events = <String>[];
    final gateway = _RecordingGateway(onFetch: () => events.add('bootstrap'));
    final service = _service(
      database,
      gateway,
      imageDirectory,
      beforeBootstrap: () async {
        events.add('outbox');
        await database.delete(DatabaseTables.outbox);
      },
    );

    await service.triggerBootstrap(trigger: BootstrapTrigger.localMutation);

    expect(events, ['outbox', 'bootstrap']);
    expect(gateway.fetchCount, 1);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
  });

  test('app open sends every outbox API before Bootstrap', () async {
    await _insertOutbox(database, status: 'queued');
    await _insertOutbox(database, status: 'failed');
    final events = <String>[];
    final gateway = _RecordingGateway(onFetch: () => events.add('bootstrap'));
    final service = _service(
      database,
      gateway,
      imageDirectory,
      beforeBootstrap: () async {
        final rows = await database.query(
          DatabaseTables.outbox,
          orderBy: 'seq ASC',
        );
        for (final row in rows) {
          events.add('outbox');
          await database.delete(
            DatabaseTables.outbox,
            where: 'seq = ?',
            whereArgs: [row['seq']],
          );
        }
      },
    );

    await service.triggerBootstrap(trigger: BootstrapTrigger.appOpen);

    expect(events, ['outbox', 'outbox', 'bootstrap']);
    expect(gateway.fetchCount, 1);
  });

  test('refuses logout reset while an outbox row remains', () async {
    await _insertOutbox(database, status: 'failed');
    final service = _service(database, _RecordingGateway(), imageDirectory);

    await expectLater(service.clearForLogout(), throwsStateError);

    expect(await database.query(DatabaseTables.outbox), hasLength(1));
  });
}

BootstrapSyncService _service(
  AppDatabase database,
  BootstrapGateway gateway,
  Directory imageDirectory, {
  Future<void> Function()? beforeBootstrap,
}) => BootstrapSyncService.forTesting(
  gateway: gateway,
  database: database,
  itemImageCache: ItemImageCacheService(
    database: database,
    directoryProvider: () async => imageDirectory,
  ),
  accessTokenProvider: () async => 'test-token',
  internetAccessChecker: () async => true,
  beforeBootstrap: beforeBootstrap,
);

Future<void> _insertOutbox(AppDatabase database, {required String status}) =>
    database.insert(DatabaseTables.outbox, {
      'method': 'PUT',
      'path': '/cash-requests/request-1',
      'entity': DatabaseTables.cashRequests,
      'entity_id': 'request-1',
      'kind': 'create',
      'status': status,
      'created_at': '2026-10-09T00:00:00.000Z',
    });

class _RecordingGateway implements BootstrapGateway {
  _RecordingGateway({this.onFetch});

  final void Function()? onFetch;
  int fetchCount = 0;

  @override
  Future<BootstrapResponse> fetch({
    required String accessToken,
    String? since,
  }) async {
    fetchCount++;
    onFetch?.call();
    return const BootstrapResponse(
      data: BootstrapData(
        cursor: 'cursor-1',
        hasMore: false,
        full: false,
        serverTime: null,
        me: null,
        tables: {},
      ),
    );
  }
}
