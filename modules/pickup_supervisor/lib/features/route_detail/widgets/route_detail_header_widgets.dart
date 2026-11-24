import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/widgets/module_tag.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_assets.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

Widget routeDetailIcon(String asset, double size) => SvgPicture.asset(
  asset,
  package: RouteDetailAssets.package,
  width: size,
  height: size,
);

/// Back button on the left and the three-dots menu on the right.
class RouteDetailTopBar extends StatelessWidget {
  const RouteDetailTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const ModuleBackButton(),
        InkResponse(
          key: const Key('route-detail-more'),
          radius: 24,
          onTap: () {},
          child: routeDetailIcon(RouteDetailAssets.more, 28),
        ),
      ],
    );
  }
}

/// Route name, status, vehicle, shift, sources, warehouse, driver and labour.
class RouteDetailHeaderCard extends StatelessWidget {
  const RouteDetailHeaderCard({super.key, required this.summary});

  final RouteSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final sources = summary.pausedSources > 0
        ? l10n.rdAssignedSourcesPaused(
            summary.assignedSources,
            summary.pausedSources,
          )
        : l10n.rdAssignedSources(summary.assignedSources);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  summary.name,
                  style: DriverTextStyles.bold16.copyWith(
                    color: DriverColors.neutral900,
                  ),
                ),
              ),
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: DriverColors.secondary100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.tpStatusOnRoute,
                  style: DriverTextStyles.semibold14.copyWith(
                    color: DriverColors.secondary500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ModuleTag(
                label: l10n.tpOwnVehicle,
                tone: ModuleTagTone.blue,
                iconAsset: RouteDetailAssets.ownVehicle,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${l10n.tpDaily(summary.daily)} · '
                  '${l10n.tpWeekly(summary.weekly)}',
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.neutral700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _GreenDivider(),
          const SizedBox(height: 12),
          _InfoRow(RouteDetailAssets.plate, summary.plate),
          const SizedBox(height: 6),
          _InfoRow(RouteDetailAssets.clock, l10n.rdShift(summary.shiftTime)),
          const SizedBox(height: 6),
          _InfoRow(RouteDetailAssets.sources, sources),
          const SizedBox(height: 6),
          _InfoRow(RouteDetailAssets.warehouse, summary.warehouse),
          const SizedBox(height: 6),
          _InfoRow(
            RouteDetailAssets.driver,
            l10n.rdDriverLine(summary.driverName, summary.driverPhone),
          ),
          const SizedBox(height: 6),
          _InfoRow(
            RouteDetailAssets.labour,
            l10n.rdLabourLine(summary.labourName),
          ),
          const SizedBox(height: 12),
          const _GreenDivider(),
        ],
      ),
    );
  }
}

class _GreenDivider extends StatelessWidget {
  const _GreenDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: DriverColors.primary500);
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: DriverColors.primary100,
            shape: BoxShape.circle,
          ),
          child: routeDetailIcon(icon, 20),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
        ),
      ],
    );
  }
}
