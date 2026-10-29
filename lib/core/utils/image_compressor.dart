import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility to capture, compress, and ensure photos are under the 5 MB limit.
class ImageCompressor {
  ImageCompressor._();

  static const _pendingRecoveryIdKey = 'camera_pending_recovery_id';
  static const _recoveredImagePathKey = 'camera_recovered_image_path';
  static const _recoveredImageIdKey = 'camera_recovered_image_id';
  static XFile? _recoveredImage;
  static String? _recoveredImageId;
  static Future<void>? _recoveryInitialization;

  /// Maximum photo size allowed: 5 MB (5 * 1024 * 1024 bytes).
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  /// Camera photos are kept within a portrait 1080 x 1920 bounding box.
  /// Landscape photos preserve their aspect ratio and therefore use 1080 as
  /// their maximum width.
  static const double defaultMaxWidth = 1080;
  static const double defaultMaxHeight = 1920;
  static const int defaultQuality = 70;
  static const int _minimumQuality = 35;
  static const int _qualityStep = 10;
  static const double _resizeStep = 0.85;

  /// Must run during app startup on Android. The system is allowed to kill the
  /// Flutter process while the external camera activity is in front. In that
  /// case image_picker persists the result and exposes it through
  /// retrieveLostData() in the new process.
  static Future<void> initializeLostDataRecovery({ImagePicker? picker}) {
    return _recoveryInitialization ??= _initializeLostDataRecovery(picker);
  }

  static Future<void> _initializeLostDataRecovery(ImagePicker? picker) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedPath = preferences.getString(_recoveredImagePathKey);
      final savedId = preferences.getString(_recoveredImageIdKey);
      if (savedPath != null && savedId != null) {
        final savedFile = File(savedPath);
        if (await savedFile.exists()) {
          _recoveredImage = XFile(savedPath, mimeType: 'image/jpeg');
          _recoveredImageId = savedId;
          return;
        }
        await _clearRecoveredPreferences(preferences);
      }

      final pendingId = preferences.getString(_pendingRecoveryIdKey);
      final lostData = await (picker ?? ImagePicker())
          .retrieveLostData()
          .timeout(const Duration(seconds: 8));
      if (lostData.exception != null) {
        AppLogger.error('IMAGE_RECOVERY', lostData.exception.toString());
      }
      final files = lostData.files;
      if (pendingId == null || files == null || files.isEmpty) {
        await preferences.remove(_pendingRecoveryIdKey);
        return;
      }

      // image_picker applies the requested 1080x1920/quality constraints in
      // its Android delegate before persisting lost data. Avoid decoding that
      // JPEG again in the freshly restarted, memory-constrained process.
      final recoveredFile = files.first;
      final recoveredSize = await recoveredFile.length();
      final recovered = recoveredSize > 0 && recoveredSize < maxFileSizeBytes
          ? recoveredFile
          : await _compressPickedFile(
              recoveredFile,
              maxWidth: defaultMaxWidth,
              maxHeight: defaultMaxHeight,
              imageQuality: defaultQuality,
              maxBytes: maxFileSizeBytes,
            );
      await preferences.remove(_pendingRecoveryIdKey);
      if (recovered == null) return;

      _recoveredImage = recovered;
      _recoveredImageId = pendingId;
      await preferences.setString(_recoveredImagePathKey, recovered.path);
      await preferences.setString(_recoveredImageIdKey, pendingId);
      AppLogger.diagnostic(
        'IMAGE_RECOVERY',
        'Recovered camera result after Android process death for $pendingId',
      );
    } catch (error, stackTrace) {
      AppLogger.error('IMAGE_RECOVERY', '$error\n$stackTrace');
    }
  }

  /// Returns a camera result recovered after Android killed the app. A result
  /// is consumed only by the form that originally launched the camera.
  static Future<XFile?> claimRecoveredImage(String recoveryId) async {
    final initialization = _recoveryInitialization;
    if (initialization != null) await initialization;
    final preferences = await SharedPreferences.getInstance();
    _recoveredImage ??= _fileFromSavedRecovery(preferences, recoveryId);
    _recoveredImageId ??= preferences.getString(_recoveredImageIdKey);
    if (_recoveredImageId != recoveryId || _recoveredImage == null) return null;

    final result = _recoveredImage;
    _recoveredImage = null;
    _recoveredImageId = null;
    await _clearRecoveredPreferences(preferences);
    return result;
  }

  /// Identifier of the form/field whose camera result survived process death.
  static Future<String?> recoveredImageId() async {
    final initialization = _recoveryInitialization;
    if (initialization != null) await initialization;
    if (_recoveredImageId != null) return _recoveredImageId;
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_recoveredImageIdKey);
  }

  /// Picks and compresses an image from [source] (defaults to camera).
  ///
  /// Guarantees optimal compression and ensures the image size is strictly
  /// within the 5 MB limit, returning the [XFile] with the stored final path.
  static Future<XFile?> pickAndCompress({
    ImagePicker? picker,
    ImageSource source = ImageSource.camera,
    String recoveryId = 'camera.generic',
    double maxWidth = defaultMaxWidth,
    double maxHeight = defaultMaxHeight,
    int imageQuality = defaultQuality,
    int maxBytes = maxFileSizeBytes,
  }) async {
    try {
      final imagePicker = picker ?? ImagePicker();
      final recovered = await claimRecoveredImage(recoveryId);
      if (recovered != null) return recovered;

      final preferences = await SharedPreferences.getInstance();
      if (source == ImageSource.camera) {
        await preferences.setString(_pendingRecoveryIdKey, recoveryId);
      }

      final picked = await imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        requestFullMetadata: false,
      );
      if (source == ImageSource.camera) {
        await preferences.remove(_pendingRecoveryIdKey);
      }
      if (picked == null) return null;

      // image_picker has already resized and compressed this camera result
      // natively. Avoid decoding it again on the UI isolate: older or
      // low-memory devices can otherwise be killed while returning from the
      // camera Activity.
      final pickedSize = await picked.length();
      if (pickedSize > 0 && pickedSize < maxBytes) return picked;

      return _compressPickedFile(
        picked,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        maxBytes: maxBytes,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'IMAGE_CAPTURE',
        '$error\n${StackTrace.fromString(stackTrace.toString())}',
      );
      return null;
    }
  }

  /// Normalizes [file] to an orientation-correct JPEG, keeps it within
  /// [maxWidth] x [maxHeight], and guarantees that it is smaller than
  /// [maxBytes]. The aspect ratio is always preserved.
  static Future<XFile?> compressFile(
    XFile file, {
    int maxWidth = 1080,
    int maxHeight = 1920,
    int imageQuality = defaultQuality,
    int maxBytes = maxFileSizeBytes,
  }) async {
    try {
      final ioFile = File(file.path);
      if (!await ioFile.exists() || maxWidth <= 0 || maxHeight <= 0) {
        return null;
      }
      final outputPath = await Isolate.run(
        () => _compressImageFile(
          sourcePath: file.path,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
          maxBytes: maxBytes,
        ),
      );
      if (outputPath == null) return null;

      final output = File(outputPath);
      final outputSize = await output.length();
      if (outputSize <= 0 || outputSize >= maxBytes) {
        if (await output.exists()) await output.delete();
        return null;
      }

      AppLogger.diagnostic(
        'IMAGE_COMPRESSION',
        '$outputSize bytes stored at $outputPath',
      );
      return XFile(outputPath, mimeType: 'image/jpeg');
    } catch (error, stackTrace) {
      AppLogger.error(
        'IMAGE_COMPRESSION',
        '$error\n${StackTrace.fromString(stackTrace.toString())}',
      );
      return null;
    }
  }

  static XFile? _fileFromSavedRecovery(
    SharedPreferences preferences,
    String recoveryId,
  ) {
    if (preferences.getString(_recoveredImageIdKey) != recoveryId) return null;
    final path = preferences.getString(_recoveredImagePathKey);
    if (path == null || !File(path).existsSync()) return null;
    return XFile(path, mimeType: 'image/jpeg');
  }

  static Future<void> _clearRecoveredPreferences(
    SharedPreferences preferences,
  ) async {
    await preferences.remove(_recoveredImagePathKey);
    await preferences.remove(_recoveredImageIdKey);
  }

  static Future<XFile?> _compressPickedFile(
    XFile file, {
    required double maxWidth,
    required double maxHeight,
    required int imageQuality,
    required int maxBytes,
  }) {
    return compressFile(
      file,
      maxWidth: maxWidth.toInt(),
      maxHeight: maxHeight.toInt(),
      imageQuality: imageQuality,
      maxBytes: maxBytes,
    );
  }
}

String? _compressImageFile({
  required String sourcePath,
  required int maxWidth,
  required int maxHeight,
  required int imageQuality,
  required int maxBytes,
}) {
  final source = File(sourcePath);
  if (!source.existsSync()) return null;

  final decoded = img.decodeImage(source.readAsBytesSync());
  if (decoded == null) return null;

  var working = img.bakeOrientation(decoded);
  final widthScale = maxWidth / working.width;
  final heightScale = maxHeight / working.height;
  final scale = [
    1.0,
    widthScale,
    heightScale,
  ].reduce((smallest, value) => value < smallest ? value : smallest);
  if (scale < 1) {
    working = img.copyResize(
      working,
      width: (working.width * scale).round().clamp(1, maxWidth),
      height: (working.height * scale).round().clamp(1, maxHeight),
      interpolation: img.Interpolation.average,
    );
  }

  var quality = imageQuality.clamp(ImageCompressor._minimumQuality, 95);
  var encoded = img.encodeJpg(working, quality: quality);
  while (encoded.lengthInBytes >= maxBytes) {
    if (quality > ImageCompressor._minimumQuality) {
      quality = (quality - ImageCompressor._qualityStep).clamp(
        ImageCompressor._minimumQuality,
        95,
      );
    } else {
      final nextWidth = (working.width * ImageCompressor._resizeStep).round();
      final nextHeight = (working.height * ImageCompressor._resizeStep).round();
      if (nextWidth < 320 || nextHeight < 320) break;
      working = img.copyResize(
        working,
        width: nextWidth,
        height: nextHeight,
        interpolation: img.Interpolation.average,
      );
      quality = imageQuality.clamp(ImageCompressor._minimumQuality, 95);
    }
    encoded = img.encodeJpg(working, quality: quality);
  }

  if (encoded.lengthInBytes >= maxBytes) return null;

  final outputPath =
      '${source.parent.path}/eerl_photo_${DateTime.now().microsecondsSinceEpoch}.jpg';
  final output = File(outputPath)..writeAsBytesSync(encoded, flush: true);
  if (output.lengthSync() <= 0 || output.lengthSync() >= maxBytes) {
    if (output.existsSync()) output.deleteSync();
    return null;
  }
  return output.path;
}
