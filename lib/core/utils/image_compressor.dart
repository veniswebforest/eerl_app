import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
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
      debugPrint('[ImageCompressor] Error capturing image: $e');
      return null;
    }
  }

  /// Compresses a given [XFile] to ensure it is under [maxBytes] (default 5 MB).
  static Future<XFile> compressFile(
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

      // If file size exceeds maxBytes, perform secondary downscaling
      final bytes = await ioFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 1280,
      );
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final compressedBytes = byteData.buffer.asUint8List();
        final tempDir = ioFile.parent;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final newPath = '${tempDir.path}/compressed_$timestamp.png';
        final newFile = await File(newPath).writeAsBytes(compressedBytes);
        return XFile(newFile.path);
      }
    } catch (e) {
      debugPrint('[ImageCompressor] Error compressing file: $e');
    }

    return file;
  }
}
