import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/core/widgets/module_info_note.dart';
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

/// Back button, the "Trip details" title and the ⋮ menu (hidden when
/// [onMore] is null, e.g. on a read-only approved trip).
class RouteDetailTopBar extends StatelessWidget {
  const RouteDetailTopBar({super.key, required this.title, this.onMore});

  final String title;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ModuleBackButton(),
        const SizedBox(width: 16),
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
        if (onMore != null)
          InkResponse(
            key: const Key('route-detail-more'),
            radius: 24,
            onTap: onMore,
            child: routeDetailIcon(RouteDetailAssets.more, 28),
          ),
      ],
    );
  }
}

/// Route name, status, vehicle, shift, sources, warehouse, driver and labour.
class RouteDetailHeaderCard extends StatelessWidget {
  const RouteDetailHeaderCard({
    super.key,
    required this.summary,
    this.state = TripState.onRoute,
    this.showStarted = false,
    this.badge,
    this.change,
    this.alert,
  });

  /// Shown under the tags (e.g. "Driver not using app").
  final Widget? alert;

  final RouteSummary summary;
  final TripState state;

  /// Cancelled trip or switched-off route: replaces the state badge.
  final TripBadge? badge;

  /// A driver swap for this trip only ("Changed for today").
  final TripTeamChange? change;

  /// On-route trips show "Started … (Start trip)" on the This trip tab.
  final bool showStarted;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final sources = summary.pausedSources > 0
        ? l10n.rdAssignedSourcesPaused(
            summary.assignedSources,
            summary.pausedSources,
          )
        : l10n.rdAssignedSources(summary.assignedSources);
    final (String statusLabel, Color statusBg, Color statusFg) = switch ((
      badge,
      state,
    )) {
      (TripBadge.cancelled, _) => (
        l10n.rdStatusCancelled,
        DriverColors.red100,
        DriverColors.red600,
      ),
      (TripBadge.notStarted, _) => (
        l10n.tpStatusPlanned,
        DriverColors.tagGrey,
        DriverColors.pdfMuted,
      ),
      (TripBadge.switchedOff, _) => (
        l10n.rdStatusSwitchedOff,
        DriverColors.cool200,
        DriverColors.cool600,
      ),
      (null, TripState.onRoute) => (
        l10n.tpStatusOnRoute,
        DriverColors.secondary100,
        DriverColors.secondary500,
      ),
      (null, TripState.planned) => (
        l10n.tpStatusPlanned,
        DriverColors.tagGrey,
        DriverColors.pdfMuted,
      ),
      (null, TripState.approved) => (
        l10n.rdStatusApprovedTrip,
        DriverColors.primary50,
        DriverColors.primary500,
      ),
    };
    final frequencies = [
      if (summary.daily > 0) l10n.tpDaily(summary.daily),
      if (summary.weekly > 0) l10n.tpWeekly(summary.weekly),
      if (summary.biWeekly > 0) l10n.tpBiWeekly(summary.biWeekly),
      if (summary.monthly > 0) l10n.tpMonthly(summary.monthly),
      if (summary.onCall > 0) l10n.tpOnCall(summary.onCall),
    ].join(' · ');
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
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  key: const Key('route-detail-status'),
                  style: DriverTextStyles.semibold14.copyWith(color: statusFg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ModuleTag(
                label: summary.contractVehicle
                    ? l10n.tpContractVehicle
                    : l10n.tpOwnVehicle,
                tone: summary.contractVehicle
                    ? ModuleTagTone.pink
                    : ModuleTagTone.blue,
                iconAsset: summary.contractVehicle
                    ? RouteDetailAssets.contractVehicle
                    : RouteDetailAssets.ownVehicle,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  frequencies,
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.neutral700,
                  ),
                ),
              ),
            ],
          ),
          if (alert != null) ...[const SizedBox(height: 12), alert!],
          if (change != null) ...[
            const SizedBox(height: 12),
            ModuleInfoNote(
              key: const Key('route-detail-changed'),
              icon: RouteDetailAssets.changed,
              title: l10n.tpChangedForToday,
              message: state == TripState.onRoute
                  ? l10n.rdChangedTomorrow(change!.driver, change!.replaces)
                  : l10n.rdChangedOnlyTrip(change!.driver, change!.replaces),
            ),
          ],
          const SizedBox(height: 12),
          const _GreenDivider(),
          const SizedBox(height: 12),
          _InfoRow(RouteDetailAssets.plate, summary.plate),
          const SizedBox(height: 6),
          _InfoRow(
            RouteDetailAssets.clock,
            summary.shift == RouteShift.evening
                ? l10n.rdShiftEvening(summary.shiftTime)
                : l10n.rdShift(summary.shiftTime),
          ),
          if (showStarted && summary.startedAt != null) ...[
            const SizedBox(height: 6),
            _InfoRow(
              RouteDetailAssets.clock,
              l10n.rdStarted(summary.startedAt!),
            ),
          ],
          const SizedBox(height: 6),
          _InfoRow(RouteDetailAssets.sources, sources),
          const SizedBox(height: 6),
          _InfoRow(RouteDetailAssets.warehouse, summary.warehouse),
          const SizedBox(height: 6),
          _InfoRow(
            RouteDetailAssets.driver,
            change == null
                ? l10n.rdDriverLine(summary.driverName, summary.driverPhone)
                : l10n.rdDriverLine(
                    change!.driver,
                    state == TripState.onRoute
                        ? l10n.rdTodayForPerson(change!.replaces)
                        : l10n.rdForPerson(change!.replaces),
                  ),
          ),
          const SizedBox(height: 6),
          _InfoRow(
            RouteDetailAssets.labour,
            l10n.rdLabourLine(
              summary.hasLabour ? summary.labourName : l10n.rdLabourNone,
            ),
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

/// "At the warehouse" result on an approved trip.
class RouteDetailWarehouseCard extends StatelessWidget {
  const RouteDetailWarehouseCard({super.key, required this.result});

  final WarehouseResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    Widget line(String label, String value) => Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(color: DriverColors.pdfMuted),
          ),
          TextSpan(text: ' $value'),
        ],
      ),
      style: DriverTextStyles.medium14.copyWith(
        color: DriverColors.neutral950,
        height: 1.37,
      ),
    );
    return Container(
      key: const Key('route-detail-warehouse'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.rdAtWarehouse,
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.neutral950,
              height: 1.37,
            ),
          ),
          const SizedBox(height: 8),
          line(l10n.rdWeighbridge, l10n.tpWeightKg(result.netKg)),
          const SizedBox(height: 8),
          line(
            l10n.rdDriversTotal,
            l10n.rdDriversTotalValue(
              result.driverKg,
              result.differenceKg,
              result.differencePct,
            ),
          ),
          const SizedBox(height: 8),
          line(l10n.rdBagsReceived, '${result.bags}'),
          const SizedBox(height: 8),
          line(
            l10n.rdApprovedBy,
            l10n.rdApprovedByValue(result.approvedBy, result.approvedAt),
          ),
        ],
      ),
    );
  }
}

/// One row of the ⋮ actions sheet.
class RouteAction {
  const RouteAction({
    required this.keyName,
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.danger = false,
  });

  /// Red title (Cancel this trip, Switch off the route).
  final bool danger;
  final String keyName;
  final String icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
}

/// Body of the ⋮ sheet: trip name and state, a note, the actions and Cancel.
class RouteActionsSheet extends StatelessWidget {
  const RouteActionsSheet({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
    required this.cancelLabel,
  });

  final String title;
  final String message;
  final List<RouteAction> actions;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: DriverTextStyles.semibold18.copyWith(
            color: DriverColors.neutral950,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          message,
          style: DriverTextStyles.medium12.copyWith(
            color: DriverColors.neutral600,
          ),
        ),
        for (final a in actions) ...[
          const SizedBox(height: 12),
          Material(
            color: DriverColors.neutral50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: DriverColors.stopInactiveBorder),
            ),
            child: InkWell(
              key: Key('route-action-${a.keyName}'),
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).pop();
                a.onTap?.call();
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: a.iconBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: routeDetailIcon(a.icon, 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title,
                            style: DriverTextStyles.semibold16.copyWith(
                              color: a.danger
                                  ? DriverColors.red600
                                  : DriverColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            a.subtitle,
                            style: DriverTextStyles.medium12.copyWith(
                              color: DriverColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    routeDetailIcon(RouteDetailAssets.sheetChevron, 20),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        ModuleButton(
          key: const Key('route-actions-cancel'),
          label: cancelLabel,
          variant: ModuleButtonVariant.neutral,
          height: 52,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// Red "Driver not using app" box on an own-vehicle trip whose shift started
/// 30+ minutes ago with nothing recorded in the driver's app.
class DriverNotUsingAppAlert extends StatelessWidget {
  const DriverNotUsingAppAlert({
    super.key,
    required this.driver,
    required this.shiftStart,
    this.onCall,
    this.onComplete,
  });

  final String driver;
  final String shiftStart;
  final VoidCallback? onCall;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    ButtonStyle style({required bool filled}) => TextButton.styleFrom(
      backgroundColor: filled
          ? DriverColors.primary500
          : DriverColors.neutral50,
      foregroundColor: filled
          ? DriverColors.neutral50
          : DriverColors.primary500,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minimumSize: const Size(0, 36),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: filled
            ? BorderSide.none
            : const BorderSide(color: DriverColors.primary500),
      ),
    );
    final label = DriverTextStyles.bold14;
    return Container(
      key: const Key('route-detail-not-using-app'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: DriverColors.missedCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DriverColors.missedCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              routeDetailIcon(RouteDetailAssets.driverApp, 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.tpDriverNotUsingApp,
                  style: DriverTextStyles.semibold14.copyWith(
                    color: DriverColors.red600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.rdNotUsingAppBody(driver, shiftStart),
            style: DriverTextStyles.medium12.copyWith(
              color: DriverColors.notUsingAppText,
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            key: const Key('route-detail-call-driver'),
            onPressed: onCall ?? () {},
            style: style(filled: true),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                routeDetailIcon(RouteDetailAssets.callWhite, 20),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.sxCallDriver,
                    style: label.copyWith(color: DriverColors.neutral50),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            key: const Key('route-detail-complete-for-driver'),
            onPressed: onComplete ?? () {},
            style: style(filled: false),
            child: Text(
              l10n.raCompleteTrip,
              style: label.copyWith(color: DriverColors.primary500),
            ),
          ),
        ],
      ),
    );
  }
}
