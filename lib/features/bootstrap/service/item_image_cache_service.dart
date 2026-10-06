import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Keeps server-managed material thumbnails available while the phone is
/// offline. The URL is immutable content identity: when an admin replaces an
/// image, the new URL naturally gets a new cache file.
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

  Future<void> reconcile() async {
    final rows = await _database.query(
      DatabaseTables.items,
      columns: const ['image_url'],
      where: "image_url IS NOT NULL AND TRIM(image_url) <> ''",
    );
    final urls = rows
        .map((row) => row['image_url'])
        .whereType<String>()
        .toSet();
    final directory = await _directoryProvider();
    await directory.create(recursive: true);

    for (final url in urls) {
      final file = File(p.join(directory.path, _fileName(url)));
      if (await file.exists()) continue;
      await _download(url, file);
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
    final directory = await _directoryProvider();
    final file = File(p.join(directory.path, _fileName(url)));
    return await file.exists() ? file : null;
  }

  Future<void> _download(String url, File destination) async {
    File? temporary;
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme) return;
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _log('Download HTTP ${response.statusCode}: $url');
        return;
      }
      temporary = File('${destination.path}.tmp');
      await temporary.writeAsBytes(response.bodyBytes, flush: true);
      await temporary.rename(destination.path);
      _log('Downloaded ${p.basename(destination.path)}');
    } catch (error) {
      _log('Download failed; will retry after next Bootstrap: $error');
      if (temporary != null && await temporary.exists()) {
        await temporary.delete();
      }
    }
  }

  static String _fileName(String url) =>
      '${sha256.convert(utf8.encode(url))}.jpg';

  static Future<Directory> _defaultDirectory() async =>
      Directory(p.join(await getDatabasesPath(), 'item_images'));

  static void _log(String message) {
    if (kDebugMode) debugPrint('🖼️ [EERL_ITEM_IMAGE_CACHE] $message');
  }
}
