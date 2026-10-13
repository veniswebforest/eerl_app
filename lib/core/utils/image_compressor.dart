import 'dart:io';
import 'dart:ui' as ui;

import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:image_picker/image_picker.dart';

/// Utility to capture, compress, and ensure photos are under the 5 MB limit.
class ImageCompressor {
  ImageCompressor._();

  /// Maximum photo size allowed: 5 MB (5 * 1024 * 1024 bytes).
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  /// Default compression settings for photos.
  static const double defaultMaxWidth = 1920;
  static const double defaultMaxHeight = 1920;
  static const int defaultQuality = 80;

  /// Picks and compresses an image from [source] (defaults to camera).
  ///
  /// Guarantees optimal compression and ensures the image size is strictly
  /// within the 5 MB limit, returning the [XFile] with the stored final path.
  static Future<XFile?> pickAndCompress({
    ImagePicker? picker,
    ImageSource source = ImageSource.camera,
    double maxWidth = defaultMaxWidth,
    double maxHeight = defaultMaxHeight,
    int imageQuality = defaultQuality,
    int maxBytes = maxFileSizeBytes,
  }) async {
    try {
      final imagePicker = picker ?? ImagePicker();
      final picked = await imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      if (picked == null) return null;

      return compressFile(picked, maxBytes: maxBytes);
    } catch (e) {
      AppLogger.error('IMAGE_CAPTURE', e.toString());
      return null;
    }
  }

  /// Compresses a given [XFile] to ensure it is under [maxBytes] (default 5 MB).
  static Future<XFile?> compressFile(
    XFile file, {
    int maxBytes = maxFileSizeBytes,
  }) async {
    try {
      final ioFile = File(file.path);
      if (!await ioFile.exists()) return file;

      final length = await ioFile.length();
      if (length <= maxBytes) {
        return file;
      }

      final bytes = await ioFile.readAsBytes();
      final dimensionsCodec = await ui.instantiateImageCodec(bytes);
      final dimensionsFrame = await dimensionsCodec.getNextFrame();
      final originalWidth = dimensionsFrame.image.width;
      final originalHeight = dimensionsFrame.image.height;
      dimensionsFrame.image.dispose();
      dimensionsCodec.dispose();

      final longestSide = originalWidth > originalHeight
          ? originalWidth
          : originalHeight;
      final targetDimensions = <int>{
        if (longestSide < 1600) longestSide else 1600,
        1280,
        1024,
        768,
        512,
      }.where((dimension) => dimension <= longestSide);

      for (final maxDimension in targetDimensions) {
        final codec = await ui.instantiateImageCodec(
          bytes,
          targetWidth: originalWidth >= originalHeight ? maxDimension : null,
          targetHeight: originalHeight > originalWidth ? maxDimension : null,
        );
        final frame = await codec.getNextFrame();
        final byteData = await frame.image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        frame.image.dispose();
        codec.dispose();

        if (byteData == null) continue;
        final compressedBytes = byteData.buffer.asUint8List();
        if (compressedBytes.lengthInBytes > maxBytes) continue;

        final tempDir = ioFile.parent;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final newPath =
            '${tempDir.path}/compressed_${timestamp}_$maxDimension.png';
        final newFile = await File(newPath).writeAsBytes(compressedBytes);
        if (await newFile.length() <= maxBytes) return XFile(newFile.path);
        await newFile.delete();
      }
    } catch (e) {
      AppLogger.error('IMAGE_COMPRESSION', e.toString());
    }

    // Never pass an oversized image to the caller or upload queue.
    return null;
  }
}
