import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_pickup_form_widgets.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_assets.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_common_widgets.dart';

BoxDecoration _fieldDecoration() => BoxDecoration(
  color: DriverColors.neutral50,
  border: Border.all(color: DriverColors.cool400),
  borderRadius: BorderRadius.circular(10),
);

/// Label (optionally with a red asterisk) above a 55px text field.
class DriverLabourTextField extends StatelessWidget {
  const DriverLabourTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.required = false,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool required;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, required: required),
        const SizedBox(height: 8),
        _InputBox(
          controller: controller,
          hint: hint,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
        ),
      ],
    );
  }
}

/// Country code box + mobile number field.
class DriverLabourMobileField extends StatelessWidget {
  const DriverLabourMobileField({
    super.key,
    required this.label,
    required this.countryCode,
    required this.hint,
    required this.controller,
    this.required = false,
  });

  final String label;
  final String countryCode;
  final String hint;
  final TextEditingController controller;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, required: required),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 55,
              height: 55,
              alignment: Alignment.center,
              decoration: _fieldDecoration(),
              child: Text(
                countryCode,
                style: DriverTextStyles.medium14.copyWith(
                  color: DriverColors.neutral900,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _InputBox(
                controller: controller,
                hint: hint,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.required});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) => required
      ? DriverRequiredLabel(label: label)
      : Text(
          label,
          style: DriverTextStyles.medium14.copyWith(
            color: DriverColors.neutral950,
          ),
        );
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _fieldDecoration(),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: DriverTextStyles.regular14.copyWith(
          color: DriverColors.neutral950,
        ),
        decoration: driverLabourBareInputDecoration(
          hint: hint,
          hintColor: DriverColors.cool500,
        ),
      ),
    );
  }
}

/// Uploaded photo tile with the white remove (X) button, shown when editing.
class DriverLabourPhotoTile extends StatelessWidget {
  const DriverLabourPhotoTile({
    super.key,
    required this.asset,
    required this.onRemove,
  });

  final String asset;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            asset == DriverLabourAssets.profilePhoto
                ? const DriverLabourProfilePhoto()
                : Image.asset(
                    asset,
                    package: DriverLabourAssets.package,
                    fit: BoxFit.cover,
                  ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                key: Key('driver-labour-remove-$asset'),
                onTap: onRemove,
                child: SvgPicture.asset(
                  DriverLabourAssets.photoRemove,
                  package: DriverLabourAssets.package,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
