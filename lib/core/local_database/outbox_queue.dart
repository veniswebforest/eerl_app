import 'dart:convert';

import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:sqflite/sqflite.dart';

import 'database_tables.dart';
import 'mobile_write_validator.dart';

/// Generic transaction-scoped writer for every locally-created API mutation.
///
/// [entity] is the SQLite table name and [entityId] is the affected row key.
/// A compound local identity may be used for tables such as `center_items`.
abstract final class OutboxQueue {
  static const _allowedMethods = {'PUT', 'POST', 'PATCH', 'DELETE'};

  static Future<int> enqueue(
    Transaction txn, {
    required String method,
    required String path,
    required String entity,
    required String entityId,
    String? kind,
    Object? body,
    Iterable<Object?> refs = const [],
    Iterable<String> blockingPhotoIds = const [],
    String? createdAt,
  }) async {
    final normalizedMethod = method.toUpperCase();
    _validate(
      method: normalizedMethod,
      path: path,
      entity: entity,
      entityId: entityId,
    );
    await MobileWriteValidator.validate(
      txn,
      method: normalizedMethod,
      path: path,
      body: body,
    );
    final refList = refs.toList(growable: false);
    final photoIds = blockingPhotoIds.toSet().toList(growable: false);
    final seq = await txn.insert(DatabaseTables.outbox, {
      'method': normalizedMethod,
      'path': path,
      'body': body == null ? null : jsonEncode(body),
      'entity': entity,
      'entity_id': entityId,
      'kind': kind,
      'refs': jsonEncode(refList),
      'status': 'queued',
      'attempts': 0,
      'created_at': createdAt ?? DateTime.now().toUtc().toIso8601String(),
    });
    for (final photoId in photoIds) {
      await txn.insert(DatabaseTables.outboxPhotos, {
        'outbox_seq': seq,
        'photo_id': photoId,
      });
    }
    _log(
      'QUEUED #$seq $normalizedMethod $path entity=$entity/$entityId '
      'kind=${kind ?? '-'} refs=${refList.length} photos=${photoIds.length}',
    );
    return seq;
  }

  static Future<bool> hasQueued(
    Transaction txn, {
    required String entity,
    required String entityId,
    required String kind,
  }) async {
    final rows = await txn.query(
      DatabaseTables.outbox,
      columns: const ['seq'],
      where: "entity = ? AND entity_id = ? AND kind = ? AND status = 'queued'",
      whereArgs: [entity, entityId, kind],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  static Future<int> updateQueued(
    Transaction txn, {
    required String entity,
    required String entityId,
    required String kind,
    required Object body,
    Iterable<Object?> refs = const [],
    Iterable<String>? blockingPhotoIds,
  }) async {
    final queuedRows = await txn.query(
      DatabaseTables.outbox,
      columns: const ['seq', 'method', 'path'],
      where: "entity = ? AND entity_id = ? AND kind = ? AND status = 'queued'",
      whereArgs: [entity, entityId, kind],
    );
    for (final row in queuedRows) {
      await MobileWriteValidator.validate(
        txn,
        method: row['method']! as String,
        path: row['path']! as String,
        body: body,
      );
    }
    final updated = await txn.update(
      DatabaseTables.outbox,
      {
        'body': jsonEncode(body),
        'refs': jsonEncode(refs.toList(growable: false)),
        'attempts': 0,
        'last_error': null,
        'next_attempt_at': null,
      },
      where: "entity = ? AND entity_id = ? AND kind = ? AND status = 'queued'",
      whereArgs: [entity, entityId, kind],
    );
    if (blockingPhotoIds != null) {
      final photoIds = blockingPhotoIds.toSet();
      for (final row in queuedRows) {
        final seq = row['seq']! as int;
        await txn.delete(
          DatabaseTables.outboxPhotos,
          where: 'outbox_seq = ?',
          whereArgs: [seq],
        );
        for (final photoId in photoIds) {
          await txn.insert(DatabaseTables.outboxPhotos, {
            'outbox_seq': seq,
            'photo_id': photoId,
          });
        }
      }
    }
    return updated;
  }

  static Future<int> removeQueued(
    Transaction txn, {
    required String entity,
    required String entityId,
    required String kind,
  }) async {
    final rows = await txn.query(
      DatabaseTables.outbox,
      columns: const ['seq'],
      where: "entity = ? AND entity_id = ? AND kind = ? AND status = 'queued'",
      whereArgs: [entity, entityId, kind],
    );
    for (final row in rows) {
      await txn.delete(
        DatabaseTables.outboxPhotos,
        where: 'outbox_seq = ?',
        whereArgs: [row['seq']],
      );
    }
    return txn.delete(
      DatabaseTables.outbox,
      where: "entity = ? AND entity_id = ? AND kind = ? AND status = 'queued'",
      whereArgs: [entity, entityId, kind],
    );
  }

  static void _validate({
    required String method,
    required String path,
    required String entity,
    required String entityId,
  }) {
    if (!_allowedMethods.contains(method)) {
      throw ArgumentError.value(method, 'method', 'Unsupported HTTP method.');
    }
    if (!path.startsWith('/')) {
      throw ArgumentError.value(path, 'path', 'API path must start with /.');
    }
    if (entity.trim().isEmpty || entityId.trim().isEmpty) {
      throw ArgumentError('Outbox entity and entity id are required.');
    }
  }

  static void _log(String message) {
    AppLogger.sqlite('OUTBOX_QUEUE', message);
  }
}
