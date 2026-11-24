import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_pickup_form_widgets.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _package = 'pickup_supervisor';
const _assets = 'assets/icons/driver/trip_summary';

enum DriverWarehouseHandoverStatus { form, waiting, received }

class DriverTripSummaryScreen extends StatelessWidget {
  const DriverTripSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverLocalizationScope(child: _TripSummaryView());
  }
}

class _TripSummaryView extends StatelessWidget {
  const _TripSummaryView();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return _DriverWarehousePage(
      scrollKey: const Key('driver-trip-summary'),
      title: l10n.tripOneSummary,
      onBack: () => Navigator.of(context).pop(),
      children: [
        const _TripStatusCard(status: _TripVisualStatus.done, showCounts: true),
        const SizedBox(height: 16),
        _MaterialTotalsCard(
          label: l10n.collectedOnTrip,
          total: l10n.tripCollectedTotal,
          rows: _tripMaterialRows(l10n),
        ),
        const SizedBox(height: 16),
        const _WarehouseCard(),
        const SizedBox(height: 16),
        const _NotCollectedCard(),
        const SizedBox(height: 16),
        DriverPrimaryButton(
          key: const Key('driver-handover-at-warehouse'),
          label: l10n.handOverAtWarehouse,
          icon: SvgPicture.asset('$_assets/check_white.svg', package: _package),
          radius: 12,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const DriverWarehouseHandoverScreen(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _FooterHint(text: l10n.warehouseGateInstruction),
      ],
    );
  }
}

class DriverWarehouseHandoverScreen extends StatelessWidget {
  const DriverWarehouseHandoverScreen({
    super.key,
    this.initialStatus = DriverWarehouseHandoverStatus.form,
  });

  final DriverWarehouseHandoverStatus initialStatus;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: _WarehouseHandoverView(initialStatus: initialStatus),
    );
  }
}

class _WarehouseHandoverView extends StatefulWidget {
  const _WarehouseHandoverView({required this.initialStatus});

  final DriverWarehouseHandoverStatus initialStatus;

  @override
  State<_WarehouseHandoverView> createState() => _WarehouseHandoverViewState();
}

class _WarehouseHandoverViewState extends State<_WarehouseHandoverView> {
  late DriverWarehouseHandoverStatus _status = widget.initialStatus;
  late final TextEditingController _bagsController = TextEditingController(
    text: DriverLocalizations.of(context).bagsCount,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bagsController.text.isEmpty) {
      _bagsController.text = DriverLocalizations.of(context).bagsCount;
    }
  }

  @override
  void dispose() {
    _bagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return switch (_status) {
      DriverWarehouseHandoverStatus.form => _buildForm(l10n),
      DriverWarehouseHandoverStatus.waiting => _buildWaiting(l10n),
      DriverWarehouseHandoverStatus.received => _buildReceived(l10n),
    };
  }

  Widget _buildForm(DriverLocalizations l10n) {
    return _DriverWarehousePage(
      scrollKey: const Key('driver-warehouse-handover-form'),
      title: l10n.handOverTripOne,
      onBack: () => Navigator.of(context).pop(),
      children: [
        const _TripStatusCard(status: _TripVisualStatus.done),
        const SizedBox(height: 16),
        _MaterialTotalsCard(
          label: l10n.yourCountFromStops,
          total: l10n.tripCollectedTotal,
          rows: _tripMaterialRows(l10n),
        ),
        const SizedBox(height: 16),
        const _WarehouseCard(),
        const SizedBox(height: 16),
        _SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DriverRequiredLabel(label: l10n.numberOfBags),
              const SizedBox(height: 10),
              DriverEditableValueField(
                key: const Key('driver-bags-field'),
                controller: _bagsController,
                prefix: l10n.bagsUnit,
                placeholder: l10n.bagsCount,
                allowDecimal: false,
                height: 48,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.bagsHelp,
                style: DriverTextStyles.medium12.copyWith(
                  color: DriverColors.neutral500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DriverPrimaryButton(
          key: const Key('driver-confirm-handover'),
          label: l10n.handOver,
          icon: SvgPicture.asset('$_assets/check_white.svg', package: _package),
          radius: 12,
          onPressed: () =>
              setState(() => _status = DriverWarehouseHandoverStatus.waiting),
        ),
        const SizedBox(height: 12),
        _FooterHint(text: l10n.warehouseWeighInstruction),
      ],
    );
  }

  Widget _buildWaiting(DriverLocalizations l10n) {
    return _DriverWarehousePage(
      scrollKey: const Key('driver-warehouse-waiting'),
      title: l10n.tripAtWarehouse,
      onBack: () => Navigator.of(context).pop(),
      children: [
        const _TripStatusCard(status: _TripVisualStatus.waiting),
        const SizedBox(height: 16),
        _MaterialTotalsCard(
          label: l10n.youHandedOver,
          total: l10n.handedOverTotal,
          rows: _tripMaterialRows(l10n),
        ),
        const SizedBox(height: 16),
        const _WarehouseCard(),
        const SizedBox(height: 16),
        DriverPrimaryButton(
          key: const Key('driver-waiting-back-home'),
          label: l10n.backToHome,
          radius: 12,
          onPressed: () => _backHome(context),
        ),
        const SizedBox(height: 16),
        _FooterHint(text: l10n.waitingWarehouseInstruction),
      ],
    );
  }

  Widget _buildReceived(DriverLocalizations l10n) {
    return _DriverWarehousePage(
      scrollKey: const Key('driver-warehouse-received'),
      title: l10n.tripReceived,
      onBack: () => Navigator.of(context).pop(),
      children: [
        const _TripStatusCard(status: _TripVisualStatus.received),
        const SizedBox(height: 16),
        _MaterialTotalsCard(
          label: l10n.weighbridgeEnteredByWarehouse,
          total: l10n.warehouseReceivedTotal,
          rows: [
            (l10n.withLoadGross, l10n.weight8940Kg),
            (l10n.emptyVehicle, l10n.weight7700Kg),
            (l10n.netWeight, l10n.weight1240Kg),
            (l10n.bagsReceived, l10n.bagsCount),
            (l10n.eWasteCounted, l10n.count25Pcs),
          ],
        ),
        const SizedBox(height: 16),
        _ComparisonCard(l10n: l10n),
        const SizedBox(height: 16),
        DriverPrimaryButton(
          key: const Key('driver-received-back-home'),
          label: l10n.backToHome,
          radius: 12,
          onPressed: () => _backHome(context),
        ),
        const SizedBox(height: 16),
        _FooterHint(text: l10n.receivedWarehouseInstruction),
      ],
    );
  }

  void _backHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

enum _TripVisualStatus { done, waiting, received }

class _DriverWarehousePage extends StatelessWidget {
  const _DriverWarehousePage({
    required this.scrollKey,
    required this.title,
    required this.onBack,
    required this.children,
  });

  final Key scrollKey;
  final String title;
  final VoidCallback onBack;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: DriverColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min(constraints.maxWidth, 480.0);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: CustomScrollView(
                  key: scrollKey,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        padding.top + 18,
                        20,
                        math.max(padding.bottom, 20),
                      ),
                      sliver: SliverList.list(
                        children: [
                          DriverStopsPageHeader(
                            title: title,
                            onBack: onBack,
                            backAsset: '$_assets/back.svg',
                          ),
                          const SizedBox(height: 24),
                          ...children,
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

class _TripStatusCard extends StatelessWidget {
  const _TripStatusCard({required this.status, this.showCounts = false});

  final _TripVisualStatus status;
  final bool showCounts;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final isWaiting = status == _TripVisualStatus.waiting;
    final isReceived = status == _TripVisualStatus.received;
    final chipLabel = isWaiting
        ? l10n.waitingStatus
        : isReceived
        ? l10n.receivedStatus
        : l10n.allStopsDone;
    final chipColor = isWaiting
        ? DriverColors.yellow700
        : DriverColors.primary500;
    final chipIcon = isWaiting
        ? '$_assets/check_waiting.svg'
        : isReceived
        ? '$_assets/check_received.svg'
        : '$_assets/check_green.svg';
    final vehicle = isWaiting
        ? l10n.vehicleAtWarehouseSince
        : isReceived
        ? l10n.vehicleAtWarehouse
        : l10n.vehicleCrew;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.morningTripWindow,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isWaiting
                      ? const Color(0xFFFFF6E0)
                      : DriverColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(chipIcon, package: _package),
                    const SizedBox(width: 6),
                    Text(
                      chipLabel,
                      style: DriverTextStyles.semibold12.copyWith(
                        color: chipColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SvgPicture.asset('$_assets/truck.svg', package: _package),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vehicle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.medium14.copyWith(
                    color: DriverColors.neutral900,
                  ),
                ),
              ),
            ],
          ),
          if (showCounts) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _CountTile(
                  value: '5',
                  label: l10n.collected,
                  background: DriverColors.primary50,
                  valueColor: DriverColors.primary500,
                ),
                const SizedBox(width: 6),
                _CountTile(
                  value: '0',
                  label: l10n.pendingStatus,
                  background: DriverColors.yellow50,
                  valueColor: DriverColors.yellow700,
                ),
                const SizedBox(width: 6),
                _CountTile(
                  value: '1',
                  label: l10n.zeroKg,
                  background: DriverColors.cool300,
                  valueColor: DriverColors.neutral800,
                ),
                const SizedBox(width: 6),
                _CountTile(
                  value: '1',
                  label: l10n.cancelled,
                  background: DriverColors.purple50,
                  valueColor: DriverColors.purple600,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.value,
    required this.label,
    required this.background,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color background;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: DriverTextStyles.bold16.copyWith(color: valueColor),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DriverTextStyles.medium12.copyWith(
                color: DriverColors.neutral700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialTotalsCard extends StatelessWidget {
  const _MaterialTotalsCard({
    required this.label,
    required this.total,
    required this.rows,
  });

  final String label;
  final String total;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            total,
            style: DriverTextStyles.bold24.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          for (final row in rows) _ValueRow(label: row.$1, value: row.$2),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.label,
    required this.value,
    this.valueColor = DriverColors.neutral950,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DriverColors.cool300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: DriverTextStyles.medium14.copyWith(
                color: DriverColors.neutral900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: DriverTextStyles.semibold14.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _WarehouseCard extends StatelessWidget {
  const _WarehouseCard();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return _SurfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DriverColors.primary50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  '$_assets/warehouse.svg',
                  package: _package,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dropAt,
                      style: DriverTextStyles.semibold12.copyWith(
                        color: DriverColors.primary500,
                      ),
                    ),
                    Text(
                      l10n.warehouseName,
                      style: DriverTextStyles.semibold18.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                    Text(
                      l10n.warehouseAddressDistance,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DriverTextStyles.medium12.copyWith(
                        color: DriverColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _WarehouseAction(
                  key: const Key('driver-open-warehouse-map'),
                  label: l10n.openInMaps,
                  asset: '$_assets/navigation.svg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WarehouseAction(
                  key: const Key('driver-call-warehouse'),
                  label: l10n.callWarehouse,
                  asset: '$_assets/phone.svg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WarehouseAction extends StatelessWidget {
  const _WarehouseAction({super.key, required this.label, required this.asset});

  final String label;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: SvgPicture.asset(asset, package: _package),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: DriverColors.primary500,
          side: const BorderSide(color: DriverColors.primary500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: DriverTextStyles.bold14,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }
}

class _NotCollectedCard extends StatelessWidget {
  const _NotCollectedCard();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notCollectedTwo,
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 10),
          _NotCollectedStop(
            title: l10n.cityBakery,
            chip: l10n.zeroKg,
            reason: l10n.noMaterialToday,
            asset: '$_assets/scale.svg',
            background: DriverColors.cool300,
            foreground: DriverColors.neutral800,
          ),
          const SizedBox(height: 10),
          _NotCollectedStop(
            title: l10n.xyzTextileMills,
            chip: l10n.cancelledBySource,
            reason: l10n.closedForStockTaking,
            asset: '$_assets/cancelled.svg',
            background: DriverColors.purple50,
            foreground: DriverColors.purple600,
          ),
        ],
      ),
    );
  }
}

class _NotCollectedStop extends StatelessWidget {
  const _NotCollectedStop({
    required this.title,
    required this.chip,
    required this.reason,
    required this.asset,
    required this.background,
    required this.foreground,
  });

  final String title;
  final String chip;
  final String reason;
  final String asset;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: DriverTextStyles.semibold14.copyWith(
            color: DriverColors.neutral900,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(asset, package: _package),
                  const SizedBox(width: 6),
                  Text(
                    chip,
                    style: DriverTextStyles.semibold12.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                reason,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DriverTextStyles.medium12.copyWith(
                  color: DriverColors.neutral700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.yourCountVsWeighbridge,
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 10),
          _ValueRow(label: l10n.yourCount, value: l10n.weight1260Kg),
          _ValueRow(label: l10n.weighbridgeNet, value: l10n.weight1240Kg),
          _ValueRow(
            label: l10n.difference,
            value: l10n.weightDifference,
            valueColor: DriverColors.yellow700,
          ),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: DriverColors.shadow,
            offset: Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FooterHint extends StatelessWidget {
  const _FooterHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DriverTextStyles.medium12.copyWith(color: DriverColors.neutral500),
    );
  }
}

List<(String, String)> _tripMaterialRows(DriverLocalizations l10n) => [
  (l10n.mixedWaste, l10n.weight635Kg),
  (l10n.petBottles, l10n.weight270Kg),
  (l10n.hdpeRigid, l10n.weight270Kg),
  (l10n.cardboard, l10n.weight85Kg),
  (l10n.eWaste, l10n.count25Pcs),
];
