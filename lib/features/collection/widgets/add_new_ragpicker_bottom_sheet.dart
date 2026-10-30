import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_required_text.dart';
import 'package:eerl_app/shared/widgets/app_mobile_number_field.dart';
import 'package:eerl_app/core/utils/image_compressor.dart';
import 'package:eerl_app/shared/widgets/app_image_preview_dialog.dart';
import 'package:eerl_app/shared/widgets/app_snackbar.dart';
import 'package:eerl_app/shared/widgets/in_app_camera_screen.dart';

class NewRagpickerInput {
  const NewRagpickerInput({
    required this.name,
    required this.phone,
    this.idNumber,
    this.localPhotoPath,
    this.localPhotoPaths = const [],
  });

  final String name;
  final String phone;
  final String? idNumber;
  final String? localPhotoPath;
  final List<String> localPhotoPaths;

  List<String> get effectivePhotoPaths {
    if (localPhotoPaths.isNotEmpty) return localPhotoPaths;
    if (localPhotoPath != null && localPhotoPath!.isNotEmpty) {
      return [localPhotoPath!];
    }
    return const [];
  }
}

class AddNewRagpickerBottomSheet extends StatefulWidget {
  const AddNewRagpickerBottomSheet({super.key, required this.onSave});

  final Future<void> Function(NewRagpickerInput) onSave;

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function(NewRagpickerInput) onSave,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (context) => Dialog(
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 335,
            maxHeight: MediaQuery.sizeOf(context).height - 40,
          ),
          child: AddNewRagpickerBottomSheet(onSave: onSave),
        ),
      ),
    );
  }

  @override
  State<AddNewRagpickerBottomSheet> createState() =>
      _AddNewRagpickerBottomSheetState();
}

class _AddNewRagpickerBottomSheetState
    extends State<AddNewRagpickerBottomSheet> {
  static const _cameraRecoveryId = 'collection.ragpicker.add';
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final List<XFile> _photos = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _restoreCameraResult();
  }

  Future<void> _restoreCameraResult() async {
    final image = await ImageCompressor.claimRecoveredImage(_cameraRecoveryId);
    if (image == null || !mounted) return;
    setState(() {
      if (_photos.length < 2) {
        _photos.add(image);
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_photos.length >= 2) return;
    try {
      final image = await InAppCameraScreen.capture(
        context,
        picker: _imagePicker,
        recoveryId: _cameraRecoveryId,
        title: 'Capture Ragpicker Photo',
      );
      if (image != null && mounted) {
        setState(() => _photos.add(image));
      }
    } catch (_) {}
  }

  Future<void> _handleSave() async {
    final name = _fullNameController.text.trim();
    final phone = _mobileController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (name.isEmpty) {
      AppSnackbar.error(context, message: context.l10n.ragpickerNameRequired);
      return;
    }
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
      AppSnackbar.error(context, message: context.l10n.invalidMobileNumber);
      return;
    }
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final photoPaths = _photos.map((p) => p.path).toList();
      await widget.onSave(
        NewRagpickerInput(
          name: name,
          phone: phone,
          idNumber: _aadharController.text.trim().isEmpty
              ? null
              : _aadharController.text.trim(),
          localPhotoPath: photoPaths.isEmpty ? null : photoPaths.first,
          localPhotoPaths: photoPaths,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(16, 24, 16, 16 + bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildDialogTitle(l10n.addNewRagpicker)),
            const SizedBox(height: 24),

            // Full Name *
            _buildLabel(l10n.fullNameRequired),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _fullNameController,
              hintText: l10n.enterFullName,
            ),
            const SizedBox(height: 24),

            // Mobile Number *
            _buildLabel(l10n.mobileNumberRequired),
            const SizedBox(height: 8),
            AppMobileNumberField(
              controller: _mobileController,
              hintText: l10n.enterMobileNumber,
            ),
            const SizedBox(height: 24),

            // Aadhar Card Number
            _buildLabel(l10n.aadharCardNumber),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _aadharController,
              hintText: l10n.aadhaarVoterIdPlaceholder,
            ),
            const SizedBox(height: 24),

            // Profile Photo / ID Proof
            _buildLabel(l10n.profilePhotoIdProof),
            const SizedBox(height: 8),
            _buildPhotoPicker(context),
            const SizedBox(height: 6),
            Text(
              l10n.collectionVehiclePhotoHint,
              style: AppTextStyles.regularB8_12.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 24),

            // Buttons: Cancel & Save & Select
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.cool200,
                        foregroundColor: AppColors.neutral950,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: AppTextStyles.mediumSH7_16.copyWith(
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.saveAndSelect,
                        style: AppTextStyles.semiboldH8_16.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogTitle(String title) {
    final splitIndex = title.lastIndexOf(' ');
    if (splitIndex < 0) {
      return Text(
        title,
        textAlign: TextAlign.center,
        style: AppTextStyles.boldH5_24.copyWith(color: AppColors.primary500),
      );
    }

    return Text.rich(
      TextSpan(
        text: title.substring(0, splitIndex + 1),
        children: [
          TextSpan(
            text: title.substring(splitIndex + 1),
            style: const TextStyle(color: AppColors.primary500),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: AppTextStyles.boldH5_24.copyWith(color: AppColors.neutral950),
    );
  }

  Widget _buildLabel(String text) {
    return AppRequiredText(
      text,
      style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    const borderSide = BorderSide(color: AppColors.cool400);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: borderSide,
    );

    return SizedBox(
      height: 55,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.regularB7_14.copyWith(color: AppColors.neutral950),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.neutral50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16.5,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          disabledBorder: border,
          errorBorder: border,
          focusedErrorBorder: border,
          hintText: hintText,
          hintStyle: AppTextStyles.regularB7_14.copyWith(
            color: AppColors.cool400,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoTile(BuildContext context, int index, XFile file) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary500),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            InkWell(
              key: Key('new-ragpicker-photo-preview-$index'),
              onTap: () => AppImagePreviewDialog.showSource(context, file.path),
              child: Image.file(File(file.path), fit: BoxFit.cover),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                key: Key('new-ragpicker-remove-photo-$index'),
                onTap: () => setState(() => _photos.removeAt(index)),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureBox(BuildContext context) {
    return DottedBorder(
      options: const RoundedRectDottedBorderOptions(
        radius: Radius.circular(10),
        color: AppColors.primary500,
        dashPattern: [5, 4],
        strokeWidth: 1,
      ),
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          height: 82,
          color: const Color(0xFFF2FCF4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/collection/capture_camera.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary500,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.collectionCapturePhoto,
                textAlign: TextAlign.center,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker(BuildContext context) {
    if (_photos.isEmpty) {
      return _buildCaptureBox(context);
    }
    return Row(
      children: [
        for (var i = 0; i < _photos.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _buildPhotoTile(context, i, _photos[i])),
        ],
        if (_photos.length < 2) ...[
          const SizedBox(width: 10),
          Expanded(child: _buildCaptureBox(context)),
        ],
      ],
    );
  }
}
