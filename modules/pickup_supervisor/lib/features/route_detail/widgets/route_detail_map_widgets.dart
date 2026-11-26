import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_assets.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_header_widgets.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Figma draws the map on a 311 x 380 canvas; x positions scale with width.
const _canvasWidth = 311.0;
const _canvasHeight = 380.0;

/// Map card: static map, legend, next-stop line and hint.
class RouteDetailMapCard extends StatelessWidget {
  const RouteDetailMapCard({
    super.key,
    required this.points,
    required this.warehouseName,
    required this.nextNumber,
    required this.nextName,
    required this.nextTime,
    required this.nextDistance,
  });

  final List<MapStopPoint> points;
  final String warehouseName;
  final int nextNumber;
  final String nextName;
  final String nextTime;
  final String nextDistance;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MapCanvas(points: points, warehouseName: warehouseName),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _LegendItem(
                RouteDetailAssets.legendCollected,
                l10n.rdLegendCollected,
              ),
              _LegendItem(RouteDetailAssets.legendZero, l10n.rdLegendZeroKg),
              _LegendItem(
                RouteDetailAssets.legendCancelled,
                l10n.rdLegendCancelled,
              ),
              _LegendItem(RouteDetailAssets.legendNext, l10n.rdLegendNextStop),
              _LegendItem(
                RouteDetailAssets.legendPending,
                l10n.rdLegendPending,
              ),
              _LegendItem(RouteDetailAssets.legendPaused, l10n.rdLegendPaused),
              _LegendItem(
                RouteDetailAssets.legendWarehouse,
                l10n.rdLegendWarehouse,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.rdMapNext(nextNumber, nextName, nextTime, nextDistance),
            style: DriverTextStyles.semibold14.copyWith(
              color: DriverColors.ink900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.rdMapHint,
            style: DriverTextStyles.regular12.copyWith(
              color: DriverColors.slate600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.icon, this.label);

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        routeDetailIcon(icon, 10),
        const SizedBox(width: 6),
        Text(
          label,
          style: DriverTextStyles.medium12.copyWith(
            color: DriverColors.slate600,
          ),
        ),
      ],
    );
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({required this.points, required this.warehouseName});

  final List<MapStopPoint> points;
  final String warehouseName;

  String _stopAsset(StopStatus status) => switch (status) {
    StopStatus.collected => RouteDetailAssets.stopCollected,
    StopStatus.zeroKg => RouteDetailAssets.stopZero,
    StopStatus.cancelledBySource => RouteDetailAssets.stopCancelled,
    StopStatus.nextStop => RouteDetailAssets.stopNext,
    StopStatus.pending || StopStatus.missed => RouteDetailAssets.stopPending,
    StopStatus.inactive => RouteDetailAssets.stopPaused,
  };

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sx = constraints.maxWidth / _canvasWidth;

          /// Places [asset] in its element box, expanded by the Figma insets
          /// ([top], [right], [bottom], [left] as fractions of the box).
          Widget layer(
            String asset,
            double left,
            double top,
            double width,
            double height, {
            double insetTop = 0,
            double insetRight = 0,
            double insetBottom = 0,
            double insetLeft = 0,
          }) {
            final l = left * sx + insetLeft * width * sx;
            final t = top + insetTop * height;
            final w = width * sx * (1 - insetLeft - insetRight);
            final h = height * (1 - insetTop - insetBottom);
            return Positioned(
              left: l,
              top: t,
              width: w,
              height: h,
              child: SvgPicture.asset(
                asset,
                package: RouteDetailAssets.package,
                fit: BoxFit.fill,
              ),
            );
          }

          return Container(
            height: _canvasHeight,
            color: DriverColors.mapBackground,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                layer(
                  RouteDetailAssets.river,
                  0,
                  290,
                  311,
                  18.66,
                  insetTop: -.3568,
                  insetRight: -.0173,
                  insetBottom: -.4286,
                  insetLeft: -.009,
                ),
                layer(
                  RouteDetailAssets.roadH1,
                  0,
                  120,
                  311,
                  20,
                  insetTop: -.1746,
                  insetBottom: -.1746,
                ),
                layer(
                  RouteDetailAssets.roadV1,
                  150,
                  0,
                  20,
                  380,
                  insetRight: -.1748,
                  insetLeft: -.1748,
                ),
                layer(
                  RouteDetailAssets.roadH2,
                  0,
                  210,
                  311,
                  40,
                  insetTop: -.0868,
                  insetRight: -.0014,
                  insetBottom: -.0868,
                  insetLeft: -.0014,
                ),
                layer(
                  RouteDetailAssets.roadDiag,
                  40,
                  0,
                  80,
                  380,
                  insetTop: -.0019,
                  insetRight: -.0428,
                  insetBottom: -.0019,
                  insetLeft: -.0428,
                ),
                layer(
                  RouteDetailAssets.routeDone,
                  55,
                  146,
                  220,
                  204,
                  insetTop: -.0047,
                  insetBottom: -.0098,
                  insetLeft: -.0091,
                ),
                layer(
                  RouteDetailAssets.routeToGo,
                  222,
                  52,
                  53,
                  298,
                  insetTop: -.0127,
                  insetRight: -.0412,
                  insetLeft: -.0414,
                ),
                for (final point in points) _stop(point, sx),
                Positioned(
                  left: 260 * sx,
                  top: 335,
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: DriverColors.ink900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'W',
                      style: DriverTextStyles.bold12.copyWith(
                        color: DriverColors.neutral50,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 114 * sx,
                  top: 320,
                  child: Text(
                    warehouseName,
                    style: DriverTextStyles.semibold12.copyWith(
                      fontSize: 11,
                      color: DriverColors.ink900,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stop(MapStopPoint point, double sx) {
    final next = point.status == StopStatus.nextStop;
    final size = next ? 30.0 : 24.0;
    return Positioned(
      key: Key('route-detail-map-stop-${point.number}'),
      left: point.left * sx,
      top: point.top,
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            _stopAsset(point.status),
            package: RouteDetailAssets.package,
            width: size,
            height: size,
          ),
          Text(
            '${point.number}',
            style: DriverTextStyles.bold12.copyWith(
              color: next ? DriverColors.primary500 : DriverColors.neutral50,
            ),
          ),
        ],
      ),
    );
  }
}
