import 'dart:io';

import 'package:eerl_app/features/bootstrap/service/item_image_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory cacheDirectory;

  setUp(() async {
    cacheDirectory = await Directory.systemTemp.createTemp(
      'item_image_cache_test_',
    );
  });

  tearDown(() async {
    if (await cacheDirectory.exists()) {
      await cacheDirectory.delete(recursive: true);
    }
  });

  test('does not download an image again when its cache file exists', () async {
    var downloadCount = 0;
    final service = ItemImageCacheService(
      directoryProvider: () async => cacheDirectory,
      client: MockClient((request) async {
        downloadCount++;
        return http.Response.bytes(const [1, 2, 3, 4], 200);
      }),
    );
    const url = 'https://images.example.test/material.jpg';

    final first = await service.cacheFileForUrl(url);
    final second = await service.cacheFileForUrl(url);

    expect(first, isNotNull);
    expect(second?.path, first?.path);
    expect(downloadCount, 1);
    expect(await second!.readAsBytes(), const [1, 2, 3, 4]);
  });

  test('re-downloads only when an existing cache file is empty', () async {
    var downloadCount = 0;
    final service = ItemImageCacheService(
      directoryProvider: () async => cacheDirectory,
      client: MockClient((request) async {
        downloadCount++;
        return http.Response.bytes(const [5, 6, 7], 200);
      }),
    );
    const url = 'https://images.example.test/profile.jpg';

    final cached = await service.cacheFileForUrl(url);
    await cached!.writeAsBytes(const []);
    final repaired = await service.cacheFileForUrl(url);

    expect(downloadCount, 2);
    expect(await repaired!.readAsBytes(), const [5, 6, 7]);
  });
}
