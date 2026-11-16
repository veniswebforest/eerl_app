import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/driver/model/driver_pickup_stop.dart';

const driverStopsAssetRoot = 'assets/icons/driver/stops';
const _assetPackage = 'pickup_supervisor';

class DriverStopsPageHeader extends StatelessWidget {
  const DriverStopsPageHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.gap = 12,
    this.backAsset = '$driverStopsAssetRoot/back.svg',
  });

  final String title;
  final VoidCallback onBack;
  final double gap;
  final String backAsset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            key: const Key('driver-stops-back'),
            onPressed: onBack,
            padding: const EdgeInsets.all(10),
            style: IconButton.styleFrom(
              backgroundColor: DriverColors.primary500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: SvgPicture.asset(backAsset, package: _assetPackage),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DriverTextStyles.semibold20.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
        ),
      ],
    );
  }
}

class DriverStopStatusChip extends StatelessWidget {
  const DriverStopStatusChip({
    super.key,
    required this.status,
    required this.label,
    this.pendingAsset = '$driverStopsAssetRoot/pending.svg',
  });

  final DriverStopStatus status;
  final String label;
  final String pendingAsset;

  @override
  Widget build(BuildContext context) {
    final isPending = status == DriverStopStatus.pending;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isPending ? DriverColors.yellow50 : DriverColors.red100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            isPending ? pendingAsset : '$driverStopsAssetRoot/skipped.svg',
            package: _assetPackage,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: DriverTextStyles.semibold12.copyWith(
              color: isPending ? DriverColors.yellow600 : DriverColors.red600,
            ),
          ),
        ],
      ),
    );
  }
}

class DriverStopCard extends StatelessWidget {
  const DriverStopCard({
    super.key,
    required this.stop,
    required this.title,
    required this.statusLabel,
    this.onTap,
  });

  final DriverPickupStop stop;
  final String title;
  final String statusLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DriverColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: DriverColors.shadow,
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DriverTextStyles.semibold18.copyWith(
                          color: DriverColors.neutral900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DriverColors.cool100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _StopInfoRow(
                            asset: '$driverStopsAssetRoot/location.svg',
                            text: stop.location,
                          ),
                          const SizedBox(height: 8),
                          _StopInfoRow(
                            asset: '$driverStopsAssetRoot/schedule.svg',
                            text: stop.schedule,
                            regular: stop.useRegularScheduleStyle,
                            size: 32,
                            padding: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DriverStopStatusChip(
                      status: stop.status,
                      label: statusLabel,
                    ),
                  ],
                ),
                if (onTap != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SvgPicture.asset(
                      '$driverStopsAssetRoot/open_detail.svg',
                      package: _assetPackage,
                      width: 12,
                      height: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StopInfoRow extends StatelessWidget {
  const _StopInfoRow({
    required this.asset,
    required this.text,
    this.regular = false,
    this.size = 30,
    this.padding = 5,
  });

  final String asset;
  final String text;
  final bool regular;
  final double size;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(padding),
          decoration: const BoxDecoration(
            color: DriverColors.surface,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(asset, package: _assetPackage),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                (regular
                        ? DriverTextStyles.regular14
                        : DriverTextStyles.medium14)
                    .copyWith(
                      color: regular
                          ? DriverColors.neutral950
                          : DriverColors.neutral700,
                    ),
          ),
        ),
      ],
    );
  }
}
