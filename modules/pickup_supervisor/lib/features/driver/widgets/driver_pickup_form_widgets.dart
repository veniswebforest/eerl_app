import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/forms/module_input_rules.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';

const driverPickupIconRoot = 'assets/icons/driver/pickup';
const driverPickupImageRoot = 'assets/images/driver/pickup';
const driverAssetPackage = 'pickup_supervisor';

class DriverPickupStopSummary extends StatelessWidget {
  const DriverPickupStopSummary({
    super.key,
    required this.title,
    required this.subtitle,
    required this.locationLabel,
    this.locationMatched = true,
  });

  final String title;
  final String subtitle;
  final String locationLabel;
  final bool locationMatched;

  @override
  Widget build(BuildContext context) {
    final accent = locationMatched
        ? DriverColors.primary500
        : DriverColors.yellow700;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: locationMatched
                  ? DriverColors.primary50
                  : const Color(0xFFFFF4DF),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/driver/pickup_success_v2/pin.svg',
                  package: driverAssetPackage,
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                ),
                const SizedBox(width: 4),
                Text(
                  locationLabel,
                  style: DriverTextStyles.semibold12.copyWith(color: accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DriverLocationMismatchNotice extends StatelessWidget {
  const DriverLocationMismatchNotice({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        border: Border.all(color: const Color(0xFFF3C96B)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: DriverTextStyles.medium12.copyWith(
          color: const Color(0xFF6E4C00),
        ),
      ),
    );
  }
}

class DriverRequiredLabel extends StatelessWidget {
  const DriverRequiredLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label '),
          const TextSpan(
            text: '*',
            style: TextStyle(color: DriverColors.red600),
          ),
        ],
      ),
      style: DriverTextStyles.medium14.copyWith(color: DriverColors.neutral950),
    );
  }
}

class DriverValueField extends StatelessWidget {
  const DriverValueField({
    super.key,
    required this.prefix,
    required this.value,
    this.isPlaceholder = false,
    this.height = 44,
  });

  final String prefix;
  final String value;
  final bool isPlaceholder;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        border: Border.all(color: DriverColors.cool400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            prefix,
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DriverTextStyles.regular14.copyWith(
                color: isPlaceholder
                    ? DriverColors.cool500
                    : DriverColors.neutral950,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DriverEditableValueField extends StatelessWidget {
  const DriverEditableValueField({
    super.key,
    required this.controller,
    required this.prefix,
    required this.placeholder,
    this.allowDecimal = true,
    this.height = 44,
  });

  final TextEditingController controller;
  final String prefix;
  final String placeholder;
  final bool allowDecimal;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        border: Border.all(color: DriverColors.cool400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            prefix,
            key: ValueKey('driver-value-unit-$prefix'),
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(
                decimal: allowDecimal,
              ),
              inputFormatters: [
                allowDecimal
                    ? const ModuleDecimalFormatter(2)
                    : FilteringTextInputFormatter.digitsOnly,
              ],
              textInputAction: TextInputAction.next,
              textAlignVertical: TextAlignVertical.center,
              style: DriverTextStyles.regular14.copyWith(
                color: DriverColors.neutral950,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: DriverTextStyles.regular14.copyWith(
                  color: DriverColors.cool500,
                ),
                isDense: true,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DriverSupervisorNoteField extends StatelessWidget {
  const DriverSupervisorNoteField({
    super.key,
    required this.controller,
    required this.hint,
    required this.limitLabel,
  });

  final TextEditingController controller;
  final String hint;
  final String limitLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: 96,
          child: TextField(
            key: const Key('driver-supervisor-note'),
            controller: controller,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 150,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: DriverTextStyles.regular14.copyWith(
              color: DriverColors.neutral950,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: DriverTextStyles.regular14.copyWith(
                color: DriverColors.cool500,
              ),
              counterText: '',
              filled: true,
              fillColor: DriverColors.surface,
              contentPadding: const EdgeInsets.all(16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: DriverColors.cool400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: DriverColors.primary500),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          limitLabel,
          style: DriverTextStyles.regular12.copyWith(
            color: DriverColors.neutral400,
          ),
        ),
      ],
    );
  }
}

class DriverCaptureArea extends StatelessWidget {
  const DriverCaptureArea({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    this.iconSize = 24,
    this.onTap,
    this.captureKey = const Key('driver-capture-photo'),
  });

  final String label;
  final String icon;
  final bool active;
  final double iconSize;
  final VoidCallback? onTap;
  final Key captureKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: captureKey,
      onTap: active ? onTap : null,
      child: CustomPaint(
        painter: _DashedRoundedBorderPainter(
          color: active ? DriverColors.primary500 : DriverColors.cool400,
          radius: 9,
        ),
        child: Container(
          width: double.infinity,
          height: 82,
          decoration: BoxDecoration(
            color: active ? DriverColors.primary50 : DriverColors.cool100,
            borderRadius: BorderRadius.circular(active ? 10 : 8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                package: driverAssetPackage,
                width: iconSize,
                height: iconSize,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style:
                    (active
                            ? DriverTextStyles.semibold14
                            : DriverTextStyles.medium14)
                        .copyWith(
                          color: active
                              ? DriverColors.neutral900
                              : DriverColors.neutral400,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DriverPhotoThumbnail extends StatelessWidget {
  const DriverPhotoThumbnail({
    super.key,
    this.image,
    this.filePath,
    required this.removeIcon,
    this.overlayImage,
    this.width = 109,
    this.height = 70,
    this.onRemove,
    this.onPreview,
  }) : assert(image != null || filePath != null);

  final String? image;
  final String? filePath;
  final String? overlayImage;
  final String removeIcon;
  final double width;
  final double height;
  final VoidCallback? onRemove;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Material(
              color: DriverColors.cool100,
              child: InkWell(
                onTap: onPreview,
                child: filePath != null
                    ? Image.file(File(filePath!), fit: BoxFit.cover)
                    : Image.asset(
                        image!,
                        package: driverAssetPackage,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            if (overlayImage != null)
              Image.asset(
                overlayImage!,
                package: driverAssetPackage,
                fit: BoxFit.cover,
              ),
            if (onRemove != null)
              Positioned(
                top: 8,
                right: 8,
                width: 24,
                height: 24,
                child: GestureDetector(
                  key: const Key('driver-remove-photo'),
                  onTap: onRemove,
                  child: SvgPicture.asset(
                    removeIcon,
                    package: driverAssetPackage,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DriverPhotoPreviewDialog {
  const DriverPhotoPreviewDialog._();

  static Future<void> show(BuildContext context, String filePath) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(filePath), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                onPressed: () => Navigator.of(dialogContext).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverFormButton extends StatelessWidget {
  const DriverFormButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        key: const Key('driver-save-pickup'),
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: DriverColors.primary500,
          disabledBackgroundColor: DriverColors.neutral400,
          foregroundColor: DriverColors.surface,
          disabledForegroundColor: DriverColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: DriverTextStyles.bold16,
        ),
        child: Text(label),
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final metrics = path.computeMetrics();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
