import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_assets.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_common_widgets.dart';

/// White (or muted grey when deactivated) surface used by every detail card.
class DriverLabourSurface extends StatelessWidget {
  const DriverLabourSurface({
    super.key,
    required this.child,
    this.muted = false,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final bool muted;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: muted ? DriverColors.cool100 : DriverColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [driverLabourCardShadow],
      ),
      child: child,
    );
  }
}

/// Single line card with a green icon chip (driver code, warehouse).
class DriverLabourChipCard extends StatelessWidget {
  const DriverLabourChipCard({
    super.key,
    required this.iconAsset,
    required this.text,
    this.muted = false,
  });

  final String iconAsset;
  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return DriverLabourSurface(
      muted: muted,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DriverColors.primary100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              iconAsset,
              package: DriverLabourAssets.package,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DriverTextStyles.semibold16.copyWith(
                color: muted
                    ? DriverColors.neutral600
                    : DriverColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DriverLabourInfoRowData {
  const DriverLabourInfoRowData(this.label, this.value);

  final String label;
  final String value;
}

/// Labelled bullet values separated by dividers (name, mobile, ID, date).
class DriverLabourInfoCard extends StatelessWidget {
  const DriverLabourInfoCard({
    super.key,
    required this.rows,
    this.muted = false,
  });

  final List<DriverLabourInfoRowData> rows;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final labelColor = DriverColors.neutral600;
    final valueColor = muted
        ? DriverColors.neutral600
        : DriverColors.neutral950;
    return DriverLabourSurface(
      muted: muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Text(
              rows[i].label,
              style: DriverTextStyles.semibold14.copyWith(color: labelColor),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: DriverTextStyles.semibold14.copyWith(
                    color: valueColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rows[i].value,
                    style: DriverTextStyles.semibold14.copyWith(
                      color: valueColor,
                    ),
                  ),
                ),
              ],
            ),
            if (i != rows.length - 1) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: DriverColors.cool400),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

/// Profile photo + ID proof thumbnails.
class DriverLabourProofCard extends StatelessWidget {
  const DriverLabourProofCard({
    super.key,
    required this.title,
    this.muted = false,
  });

  final String title;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    Widget thumb(Widget image) => Flexible(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 109),
        child: AspectRatio(
          aspectRatio: 109 / 70,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: image,
          ),
        ),
      ),
    );
    return DriverLabourSurface(
      muted: muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DriverTextStyles.semibold18.copyWith(
              color: muted ? DriverColors.neutral600 : DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              thumb(const DriverLabourProfilePhoto()),
              const SizedBox(width: 12),
              thumb(
                Image.asset(
                  DriverLabourAssets.idCard,
                  package: DriverLabourAssets.package,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
