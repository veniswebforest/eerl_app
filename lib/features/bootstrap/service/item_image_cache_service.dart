import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Keeps every server-managed image available while the phone is offline.
///
/// A remote URL is only returned to the UI after its bytes have been committed
/// to the persistent cache. The URL is the content identity: when the server
/// replaces an image, the new URL naturally gets a new cache file.
class ItemImageCacheService {
  ItemImageCacheService({
    AppDatabase? database,
    http.Client? client,
    Future<Directory> Function()? directoryProvider,
  }) : _database = database ?? AppDatabase.instance,
       _client = client ?? http.Client(),
       _directoryProvider = directoryProvider ?? _defaultDirectory;

  static final ItemImageCacheService instance = ItemImageCacheService();
  static const _timeout = Duration(seconds: 20);

  final AppDatabase _database;
  final http.Client _client;
  final Future<Directory> Function() _directoryProvider;
  final Map<String, Future<File?>> _inFlight = {};
  int _generation = 0;

  Future<void> reconcile() async {
    final urls = await _storedRemoteUrls();
    final directory = await _directoryProvider();
    await directory.create(recursive: true);

    // Bound concurrency so a large Bootstrap response does not saturate the
    // radio, file descriptors, or image server.
    final pending = urls.toList(growable: false);
    const parallelDownloads = 3;
    for (var start = 0; start < pending.length; start += parallelDownloads) {
      final end = (start + parallelDownloads).clamp(0, pending.length);
      await Future.wait(pending.sublist(start, end).map(cacheFileForUrl));
    }

    final expectedNames = urls.map(_fileName).toSet();
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (!expectedNames.contains(name)) {
        try {
          await entity.delete();
        } on FileSystemException catch (error) {
          _log('Could not delete unused $name: ${error.message}');
        }
      }
    }
    _log('Cache reconciled urls=${urls.length}');
  }

  Future<File?> localFileForUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return null;
    final normalized = url.trim();
    final directory = await _directoryProvider();
    final file = File(p.join(directory.path, _fileName(normalized)));
    try {
      if (!await file.exists()) return null;
      if (await file.length() > 0) return file;
      // A process interruption can leave an unusable empty cache entry. It is
      // not a valid cache hit and must be downloaded again.
      await file.delete();
    } on FileSystemException catch (error) {
      _log('Could not validate cached image: ${error.message}');
    }
    return null;
  }

  Future<void> clear() async {
    _generation++;
    final directory = await _directoryProvider();
    if (await directory.exists()) await directory.delete(recursive: true);
    _inFlight.clear();
  }

  /// Downloads [url] when missing and returns only the persistent local file.
  /// Concurrent callers for the same URL share one download.
  Future<File?> cacheFileForUrl(String? url) {
    if (!_isRemoteUrl(url)) return Future<File?>.value(null);
    final normalized = url!.trim();
    final active = _inFlight[normalized];
    if (active != null) return active;

    late final Future<File?> operation;
    final generation = _generation;
    operation = _cacheFile(normalized, generation).whenComplete(() {
      if (identical(_inFlight[normalized], operation)) {
        _inFlight.remove(normalized);
      }
    });
    _inFlight[normalized] = operation;
    return operation;
  }

  /// Seeds the persistent cache from an already-uploaded local photo, avoiding
  /// an unnecessary download of the same bytes from the remote URL.
  Future<File?> storeLocalFileForUrl(String? url, File source) async {
    if (!_isRemoteUrl(url) || !await source.exists()) return null;
    final generation = _generation;
    final directory = await _directoryProvider();
    await directory.create(recursive: true);
    final destination = File(p.join(directory.path, _fileName(url!.trim())));
    final existing = await localFileForUrl(url);
    if (existing != null) return existing;

    final temporary = File('${destination.path}.tmp');
    try {
      await source.openRead().pipe(temporary.openWrite());
      if (generation != _generation) {
        await temporary.delete();
        return null;
      }
      await temporary.rename(destination.path);
      return destination;
    } on FileSystemException catch (error) {
      _log('Could not cache uploaded image: ${error.message}');
      if (await temporary.exists()) await temporary.delete();
      return null;
    }
  }

  Future<File?> _cacheFile(String url, int generation) async {
    final existing = await localFileForUrl(url);
    if (existing != null) return existing;
    final directory = await _directoryProvider();
    await directory.create(recursive: true);
    final destination = File(p.join(directory.path, _fileName(url)));
    final downloaded = await _download(url, destination);
    if (!downloaded) return null;
    if (generation == _generation) return destination;
    if (await destination.exists()) await destination.delete();
    return null;
  }

  Future<bool> _download(String url, File destination) async {
    File? temporary;
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme) return false;
      final request = http.Request('GET', uri);
      final response = await _client.send(request).timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _log('Download HTTP ${response.statusCode}: $url');
        return false;
      }
      temporary = File('${destination.path}.tmp');
      await response.stream.timeout(_timeout).pipe(temporary.openWrite());
      await temporary.rename(destination.path);
      _log('Downloaded ${p.basename(destination.path)}');
      return true;
    } catch (error) {
      _log('Download failed; will retry after next Bootstrap: $error');
      if (temporary != null && await temporary.exists()) {
        await temporary.delete();
      }
      return false;
    }
  }

  Future<Set<String>> _storedRemoteUrls() async {
    final urls = <String>{};

    Future<void> addColumn(String table, String column) async {
      final rows = await _database.query(
        table,
        columns: [column],
        where: '$column IS NOT NULL AND TRIM($column) <> \'\'',
      );
      for (final value in rows.map((row) => row[column])) {
        _addValueUrls(urls, value);
      }
    }

    await addColumn(DatabaseTables.items, 'image_url');
    await addColumn(DatabaseTables.mrfPeople, 'photo_url');
    await addColumn(DatabaseTables.ragpickers, 'photo_url');
    await addColumn(DatabaseTables.collections, 'handover_photo_urls');
    await addColumn(DatabaseTables.collectionItems, 'photo_urls');
    await addColumn(DatabaseTables.expenses, 'receipt_photo_urls');
    await addColumn(DatabaseTables.transfers, 'vehicle_photo_urls');
    await addColumn(DatabaseTables.transfers, 'weighbridge_photo_urls');
    await addColumn(DatabaseTables.tasks, 'photo_urls');
    await addColumn(DatabaseTables.tasks, 'reference_photo_urls');
    await addColumn(DatabaseTables.requests, 'photo_urls');
    await addColumn(DatabaseTables.photos, 'remote_url');

    final profileUrl = await _database.getSyncMeta('user_photo_url');
    _addValueUrls(urls, profileUrl);
    return urls;
  }

  static void _addValueUrls(Set<String> urls, Object? value) {
    if (value is! String || value.trim().isEmpty) return;
    final normalized = value.trim();
    if (_isRemoteUrl(normalized)) {
      urls.add(normalized);
      return;
    }
    try {
      final decoded = jsonDecode(normalized);
      if (decoded is List) {
        for (final item in decoded.whereType<String>()) {
          if (_isRemoteUrl(item)) urls.add(item.trim());
        }
      }
    } on FormatException {
      // Local file paths and non-JSON values are intentionally ignored.
    }
  }

  static bool _isRemoteUrl(String? value) {
    if (value == null) return false;
    final uri = Uri.tryParse(value.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  static String _fileName(String url) =>
      '${sha256.convert(utf8.encode(url))}.jpg';

  static Future<Directory> _defaultDirectory() async =>
      Directory(p.join(await getDatabasesPath(), 'item_images'));

  static void _log(String message) {
    AppLogger.diagnostic('IMAGE_CACHE', message);
  }
}
