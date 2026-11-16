import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/driver/model/driver_pickup_stop.dart';
import 'package:pickup_supervisor/driver/view/driver_stop_detail_screen.dart';
import 'package:pickup_supervisor/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

class DriverStopsScreen extends StatelessWidget {
  const DriverStopsScreen({super.key});

  static const routeName = 'driver-stops';

  @override
  Widget build(BuildContext context) {
    return const DriverLocalizationScope(child: _DriverStopsView());
  }
}

class _DriverStopsView extends StatelessWidget {
  const _DriverStopsView();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final stops = [
      DriverPickupStop(
        name: l10n.abcTextileMills,
        materialType: l10n.sortedMaterial,
        location: l10n.industrialAreaSurat,
        schedule: l10n.pickupSchedule,
        status: DriverStopStatus.pending,
        pickupType: DriverPickupType.sorted,
        useRegularScheduleStyle: true,
      ),
      DriverPickupStop(
        name: l10n.shreeSaiDairy,
        materialType: l10n.mixedMaterial,
        location: l10n.lpSavaniRoadSurat,
        schedule: l10n.pickupSchedule,
        status: DriverStopStatus.pending,
        pickupType: DriverPickupType.mixed,
      ),
      DriverPickupStop(
        name: l10n.xyzTextileMills,
        materialType: l10n.sortedMaterial,
        location: l10n.industrialAreaSurat,
        schedule: l10n.noSchedule,
        status: DriverStopStatus.skipped,
        pickupType: DriverPickupType.sorted,
      ),
    ];
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: DriverColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final pageWidth = math.min(constraints.maxWidth, 480.0);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: pageWidth,
                height: constraints.maxHeight,
                child: CustomScrollView(
                  key: const Key('driver-stops-list'),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        topInset + 18,
                        20,
                        math.max(MediaQuery.paddingOf(context).bottom, 20),
                      ),
                      sliver: SliverList.list(
                        children: [
                          DriverStopsPageHeader(
                            title: l10n.pendingPickupStops,
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 24),
                          for (
                            var index = 0;
                            index < stops.length;
                            index++
                          ) ...[
                            DriverStopCard(
                              key: ValueKey('driver-stop-$index'),
                              stop: stops[index],
                              title: l10n.stopCardTitle(
                                stops[index].name,
                                stops[index].materialType,
                              ),
                              statusLabel:
                                  stops[index].status ==
                                      DriverStopStatus.pending
                                  ? l10n.pendingStatus
                                  : l10n.skippedStatus,
                              onTap:
                                  stops[index].status ==
                                      DriverStopStatus.skipped
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => DriverStopDetailScreen(
                                          pickupType: stops[index].pickupType,
                                        ),
                                      ),
                                    ),
                            ),
                            if (index != stops.length - 1)
                              const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
