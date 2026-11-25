import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_danger_button.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_stop_widgets.dart';
import 'package:pickup_supervisor/features/stop_detail/model/stop_detail_mock_data.dart';
import 'package:pickup_supervisor/features/stop_detail/view/skip_source_screen.dart';
import 'package:pickup_supervisor/features/stop_detail/widgets/stop_detail_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Stop (source) detail opened from the route detail list.
///
/// Pops with `true` once the stop has been skipped for today.
class StopDetailScreen extends StatelessWidget {
  const StopDetailScreen({super.key, required this.stop});

  final RouteStop stop;

  @override
  Widget build(BuildContext context) =>
      DriverLocalizationScope(child: _StopDetailView(stop: stop));
}

class _StopDetailView extends StatelessWidget {
  const _StopDetailView({required this.stop});

  final RouteStop stop;

  Future<void> _skip(BuildContext context) async {
    final skipped = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SkipSourceScreen(sourceName: stop.name),
      ),
    );
    if (skipped == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final info = StopDetailMockData.forStop(stop.name);
    final sorted = stop.type == StopType.sorted;
    return ModulePage(
      bottom: ModuleDangerButton(
        key: const Key('stop-detail-skip'),
        label: l10n.sdSkipForToday,
        onPressed: () => _skip(context),
      ),
      child: ListView(
        key: const Key('stop-detail-scroll'),
        padding: EdgeInsets.zero,
        children: [
          const ModuleBackButton(),
          const SizedBox(height: 24),
          Container(
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
                Text(
                  stop.name,
                  style: DriverTextStyles.semibold18.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const StopDetailDivider(),
                StopDetailSection(
                  label: l10n.sdAddress,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StopDetailValue(info.fullAddress),
                      const SizedBox(height: 8),
                      InkWell(
                        key: const Key('stop-detail-open-maps'),
                        onTap: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            stopDetailIcon(StopDetailAssets.maps, 20),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                l10n.sdOpenMaps,
                                style: DriverTextStyles.bold14.copyWith(
                                  color: DriverColors.primary500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: DriverColors.primary500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const StopDetailDivider(),
                StopDetailSection(
                  label: l10n.sdSchedule,
                  child: StopDetailValue(
                    routeStopScheduleText(l10n, stop.schedule),
                  ),
                ),
                const StopDetailDivider(),
                StopDetailSection(
                  label: l10n.sdPersonAtPickup,
                  child: StopDetailContactRow(
                    callKey: const Key('stop-detail-call-person'),
                    text: l10n.sdContactLine(
                      info.person.name,
                      l10n.sdRoleManager,
                      info.person.phone,
                    ),
                  ),
                ),
                const StopDetailDivider(),
                StopDetailSection(
                  label: l10n.sdIecExecutive,
                  child: StopDetailContactRow(
                    callKey: const Key('stop-detail-call-iec'),
                    text: l10n.sdIecLine(
                      info.iecExecutive.name,
                      info.iecExecutive.phone,
                    ),
                  ),
                ),
                const StopDetailDivider(),
                StopDetailSection(
                  label: l10n.sdPickupCategory,
                  child: StopDetailValue(
                    stop.frequency == StopFrequency.weekly
                        ? l10n.rdFreqWeekly
                        : l10n.rdFreqDaily,
                  ),
                ),
                const StopDetailDivider(),
                StopDetailSection(
                  label: l10n.sdMaterial,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StopDetailTypeChip(
                          label: sorted ? l10n.rdTypeSorted : l10n.rdTypeMixed,
                          background: sorted
                              ? DriverColors.purpleLight
                              : DriverColors.orangeLight,
                          foreground: sorted
                              ? DriverColors.purple
                              : DriverColors.orange,
                        ),
                        if (sorted) StopDetailValue(l10n.sdMaterialsList),
                      ],
                    ),
                  ),
                ),
                const StopDetailDivider(),
                StopDetailSection(
                  label: l10n.sdPickupStatus,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _statusChip(l10n),
                    ),
                  ),
                ),
                const StopDetailDivider(),
                StopDetailSection(
                  label: l10n.sdWarehouse,
                  child: StopDetailValue(info.warehouse),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(DriverLocalizations l10n) => switch (stop.status) {
    StopStatus.collected => RouteStatusChip(
      large: true,
      radius: 8,
      icon: StopDetailAssets.collected,
      label: l10n.rdStatusCollected,
      background: DriverColors.primary100,
      foreground: DriverColors.primary500,
    ),
    StopStatus.nextStop => RouteStatusChip(
      large: true,
      icon: StopDetailAssets.next,
      label: l10n.sdStatusNextStop,
      background: DriverColors.secondary100,
      foreground: DriverColors.secondary500,
    ),
    _ => RouteStatusChip(
      large: true,
      icon: StopDetailAssets.pending,
      label: l10n.rdStatusPending,
      background: DriverColors.yellow50,
      foreground: DriverColors.yellow600,
    ),
  };
}
