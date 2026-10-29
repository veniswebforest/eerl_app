import 'dart:io';

import 'package:eerl_app/core/utils/image_compressor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'eerl_image_compressor_test_',
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('resizes a portrait photo within 1080x1920 and below 5 MB', () async {
    final source = img.Image(width: 1800, height: 3200);
    img.fill(source, color: img.ColorRgb8(20, 140, 90));
    final sourceFile = File('${tempDirectory.path}/portrait.png');
    await sourceFile.writeAsBytes(img.encodePng(source));

    final compressed = await ImageCompressor.compressFile(
      XFile(sourceFile.path),
    );

    expect(compressed, isNotNull);
    final outputFile = File(compressed!.path);
    expect(outputFile.path, endsWith('.jpg'));
    expect(
      await outputFile.length(),
      lessThan(ImageCompressor.maxFileSizeBytes),
    );
    final outputImage = img.decodeImage(await outputFile.readAsBytes());
    expect(outputImage, isNotNull);
    expect(outputImage!.width, lessThanOrEqualTo(1080));
    expect(outputImage.height, lessThanOrEqualTo(1920));
    expect(outputImage.width / outputImage.height, closeTo(1800 / 3200, 0.01));
  });

  test('keeps landscape aspect ratio inside the same bounds', () async {
    final source = img.Image(width: 2400, height: 1200);
    img.fill(source, color: img.ColorRgb8(80, 110, 210));
    final sourceFile = File('${tempDirectory.path}/landscape.jpg');
    await sourceFile.writeAsBytes(img.encodeJpg(source, quality: 95));

    final compressed = await ImageCompressor.compressFile(
      XFile(sourceFile.path),
    );

    expect(compressed, isNotNull);
    final outputImage = img.decodeImage(
      await File(compressed!.path).readAsBytes(),
    );
    expect(outputImage, isNotNull);
    expect(outputImage!.width, 1080);
    expect(outputImage.height, 540);
  });

  test('rejects corrupt image data instead of passing it to upload', () async {
    final sourceFile = File('${tempDirectory.path}/broken.jpg');
    await sourceFile.writeAsString('not an image');

    final compressed = await ImageCompressor.compressFile(
      XFile(sourceFile.path),
    );

    expect(compressed, isNull);
  });
}
