import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class AddNewRagpickerBottomSheet extends StatefulWidget {
  const AddNewRagpickerBottomSheet({super.key, required this.onSave});

  final ValueChanged<String> onSave;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onSave,
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
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  XFile? _photo;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() => _photo = image);
      }
    } catch (_) {}
  }

  void _handleSave() {
    final name = _fullNameController.text.trim();
    if (name.isNotEmpty) {
      widget.onSave(name);
      Navigator.pop(context);
    } else {
      widget.onSave('Ramesh');
      Navigator.pop(context);
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
            Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cool400),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+91',
                    style: AppTextStyles.mediumSH7_16.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildTextField(
                    controller: _mobileController,
                    hintText: l10n.enterMobileNumber,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
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
                      onPressed: _handleSave,
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
    return Text(
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

  Widget _buildPhotoPicker(BuildContext context) {
    if (_photo != null) {
      return Container(
        height: 82,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary500),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(_photo!.path), fit: BoxFit.cover),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _photo = null),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
}
