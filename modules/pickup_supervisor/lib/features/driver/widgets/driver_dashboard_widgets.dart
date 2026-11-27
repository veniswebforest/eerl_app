import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';

const _assetPackage = 'pickup_supervisor';

class DriverSvgTile extends StatelessWidget {
  const DriverSvgTile({
    super.key,
    required this.asset,
    required this.backgroundColor,
    this.radius = 8,
  });

  final String asset;
  final Color backgroundColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SvgPicture.asset(asset, package: _assetPackage),
    );
  }
}

class DriverSurfaceCard extends StatelessWidget {
  const DriverSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.shadowBlurRadius = 5,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double shadowBlurRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DriverColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: DriverColors.shadow,
            offset: const Offset(0, 2),
            blurRadius: shadowBlurRadius,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class DriverPrimaryButton extends StatelessWidget {
  const DriverPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 52,
    this.radius = 14,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double radius;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: DriverColors.primary500,
          foregroundColor: DriverColors.surface,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: DriverTextStyles.bold16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverSectionTitle extends StatelessWidget {
  const DriverSectionTitle({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: DriverTextStyles.semibold18.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
