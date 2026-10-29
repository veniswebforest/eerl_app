import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/utils/image_compressor.dart';

/// Full-screen in-app camera screen that allows capturing photos directly
/// within the application, previewing the shot, retaking, and returning
/// a compressed [XFile] ready for local storage and display.
class InAppCameraScreen extends StatefulWidget {
  const InAppCameraScreen({
    super.key,
    this.cameras,
    this.title,
    this.recoveryId,
  });

  final List<CameraDescription>? cameras;
  final String? title;
  final String? recoveryId;

  /// Helper to launch the in-app camera or gracefully fall back to
  /// [ImageCompressor.pickAndCompress] if camera hardware is unavailable.
  static Future<XFile?> capture(
    BuildContext context, {
    String? recoveryId,
    String? title,
    ImagePicker? picker,
    List<CameraDescription>? cameras,
  }) async {
    try {
      final available = cameras ?? await availableCameras();
      if (available.isEmpty) {
        return await ImageCompressor.pickAndCompress(
          source: ImageSource.camera,
          recoveryId: recoveryId ?? 'camera.inapp',
          picker: picker,
        );
      }
      if (!context.mounted) return null;
      return await Navigator.of(context).push<XFile>(
        MaterialPageRoute<XFile>(
          builder: (context) => InAppCameraScreen(
            cameras: available,
            title: title,
            recoveryId: recoveryId,
          ),
          fullscreenDialog: true,
        ),
      );
    } catch (e, st) {
      AppLogger.error('IN_APP_CAMERA', '$e\n$st');
      if (!context.mounted) return null;
      return await ImageCompressor.pickAndCompress(
        source: ImageSource.camera,
        recoveryId: recoveryId ?? 'camera.inapp',
        picker: picker,
      );
    }
  }

  @override
  State<InAppCameraScreen> createState() => _InAppCameraScreenState();
}

class _InAppCameraScreenState extends State<InAppCameraScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = const [];
  int _selectedCameraIndex = 0;
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _errorMessage;
  FlashMode _flashMode = FlashMode.off;
  XFile? _capturedPhoto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraController(_cameras[_selectedCameraIndex]);
    }
  }

  Future<void> _initCameras() async {
    try {
      if (widget.cameras != null) {
        _cameras = widget.cameras!;
      } else {
        _cameras = await availableCameras();
      }

      if (_cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'No camera found on this device.';
        });
        return;
      }

      // Default to the first back camera if present.
      final backIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _selectedCameraIndex = backIndex != -1 ? backIndex : 0;
      await _initCameraController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Unable to initialize camera: $e';
      });
    }
  }

  Future<void> _initCameraController(CameraDescription description) async {
    final oldController = _controller;
    if (oldController != null) {
      await oldController.dispose();
    }

    final newController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    setState(() {
      _controller = newController;
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      await newController.initialize();
      await newController.setFlashMode(_flashMode);
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Camera initialization error: $e';
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final nextMode = switch (_flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      _ => FlashMode.off,
    };

    try {
      await controller.setFlashMode(nextMode);
      setState(() => _flashMode = nextMode);
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _selectedCameraIndex = nextIndex;
    await _initCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isCapturing ||
        controller.value.isTakingPicture) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final file = await controller.takePicture();
      if (mounted) {
        setState(() {
          _capturedPhoto = file;
          _isCapturing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture photo: $e')),
        );
      }
    }
  }

  Future<void> _confirmPhoto() async {
    final photo = _capturedPhoto;
    if (photo == null) return;

    setState(() => _isCapturing = true);
    try {
      // Compress the photo to guarantee < 5 MB and portrait standard dimensions.
      final compressed = await ImageCompressor.compressFile(photo);
      final finalResult = compressed ?? photo;
      if (mounted) {
        Navigator.of(context).pop(finalResult);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(photo);
      }
    }
  }

  void _retakePhoto() {
    setState(() => _capturedPhoto = null);
  }

  Future<void> _fallbackToSystemCamera() async {
    final image = await ImageCompressor.pickAndCompress(
      source: ImageSource.camera,
      recoveryId: widget.recoveryId ?? 'camera.fallback',
    );
    if (image != null && mounted) {
      Navigator.of(context).pop(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview or captured photo review
            if (_capturedPhoto != null)
              _buildCapturedPreview()
            else if (_isInitializing)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary400),
                    SizedBox(height: 16),
                    Text(
                      'Opening camera...',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              )
            else if (_errorMessage != null)
              _buildErrorView()
            else
              _buildLiveCamera(),

            // Top control header
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: _buildTopHeader(),
            ),

            // Bottom control bar
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: _capturedPhoto != null
                  ? _buildReviewBottomBar()
                  : _buildCaptureBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleIconButton(
          icon: Icons.close_rounded,
          onTap: () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
        if (widget.title != null)
          Text(
            widget.title!,
            style: AppTextStyles.semiboldH9_14.copyWith(color: Colors.white),
          ),
        if (_capturedPhoto == null && _controller?.value.isInitialized == true)
          Row(
            children: [
              _circleIconButton(
                icon: switch (_flashMode) {
                  FlashMode.auto => Icons.flash_auto_rounded,
                  FlashMode.always => Icons.flash_on_rounded,
                  _ => Icons.flash_off_rounded,
                },
                onTap: _toggleFlash,
                tooltip: 'Flash',
              ),
              if (_cameras.length > 1) ...[
                const SizedBox(width: 12),
                _circleIconButton(
                  icon: Icons.cameraswitch_rounded,
                  onTap: _switchCamera,
                  tooltip: 'Switch Camera',
                ),
              ],
            ],
          )
        else
          const SizedBox(width: 44),
      ],
    );
  }

  Widget _buildLiveCamera() {
    final controller = _controller!;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1 / controller.value.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(controller),
              // Viewfinder framing guide
              _buildViewfinderGuide(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewfinderGuide() {
    return IgnorePointer(
      child: Container(
        margin: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCapturedPreview() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(_capturedPhoto!.path),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildCaptureBottomBar() {
    final isReady = _controller?.value.isInitialized == true && !_isInitializing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        GestureDetector(
          onTap: isReady && !_isCapturing ? _takePicture : null,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              color: Colors.transparent,
            ),
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isCapturing
                    ? AppColors.primary300
                    : AppColors.primary500,
              ),
              child: _isCapturing
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
            ),
          ),
        ),
        const SizedBox(width: 50),
      ],
    );
  }

  Widget _buildReviewBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Retake button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isCapturing ? null : _retakePhoto,
              icon: const Icon(Icons.refresh_rounded, color: Colors.black),
              label: const Text(
                'Retake',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.white60),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Use Photo button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isCapturing ? null : _confirmPhoto,
              icon: _isCapturing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_rounded, color: Colors.white),
              label: Text(
                _isCapturing ? 'Saving...' : 'Use Photo',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              color: AppColors.red400,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Camera error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fallbackToSystemCamera,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Use System Camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    double size = 44,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: size * 0.52),
          ),
        ),
      ),
    );
  }
}
