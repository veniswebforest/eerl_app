import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver/data/driver_live_data.dart';
import 'package:pickup_supervisor/features/driver/model/driver_pickup_stop.dart';
import 'package:pickup_supervisor/features/driver/view/driver_collected_stop_detail_screen.dart';
import 'package:pickup_supervisor/features/driver/view/driver_location_flow_screen.dart';
import 'package:pickup_supervisor/features/driver/view/driver_stop_detail_screen.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _homeAssets = 'assets/icons/driver/home_v2';
const _package = 'pickup_supervisor';

class DriverStopsScreen extends StatelessWidget {
  const DriverStopsScreen({super.key, this.tripId});

  static const routeName = 'driver-stops';

  /// The live trip; null shows the design preview.
  final String? tripId;

  @override
  Widget build(BuildContext context) {
    final id = tripId;
    return DriverLocalizationScope(
      child: id == null
          ? const _DriverStopsView()
          : OutboundLiveBuilder<_LiveTripStops>(
              load: (session) => _LiveTripStops.load(session, id),
              fallback: const _DriverStopsView(),
              builder: (context, data, _) => _LiveStopsView(data: data),
            ),
    );
  }
}

class _LiveTripStops {
  const _LiveTripStops(this.trip, this.stops);

  final DriverTripLive? trip;
  final List<DriverStopLive> stops;

  static Future<_LiveTripStops> load(
    OutboundLiveSession session,
    String tripId,
  ) async {
    final row = await session.queries.driverTrip(tripId);
    return _LiveTripStops(
      row == null ? null : DriverTripLive.fromRow(row),
      await loadDriverTripStops(session, tripId),
    );
  }
}

/// Trip stops from SQLite: the next stop, the ones still to collect, then
/// the stops done (outbound doc, Driver screens · Trip stops).
class _LiveStopsView extends StatelessWidget {
  const _LiveStopsView({required this.data});

  final _LiveTripStops data;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final open = data.stops.where((s) => s.isOpen).toList();
    final done = data.stops.where((s) => !s.isOpen).toList();
    final trip = data.trip;
    String material(DriverStopLive s) => s.pickupType == DriverPickupType.sorted
        ? l10n.sortedMaterial
        : l10n.mixedMaterial;
    Widget openCard(DriverStopLive stop, {required bool isNext}) =>
        _FullStopCard(
          key: ValueKey('driver-stop-${stop.id}'),
          title: l10n.stopCardTitle(stop.sourceName, material(stop)),
          position: l10n.stopPosition(stop.stopOrder, data.stops.length),
          location: stop.address,
          schedule: stop.window ?? l10n.liveAnyTime,
          contact: stop.contact,
          isNext: isNext,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DriverStopDetailScreen(
                pickupType: stop.pickupType,
                stopId: stop.id,
                tripId: stop.tripId,
              ),
            ),
          ),
        );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: DriverColors.background,
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              key: const Key('driver-stops-list'),
              padding: EdgeInsets.fromLTRB(
                20,
                topInset + 18,
                20,
                math.max(MediaQuery.paddingOf(context).bottom, 20),
              ),
              children: [
                DriverStopsPageHeader(
                  title: trip?.routeName ?? l10n.tripOneStops,
                  backAsset: 'assets/icons/driver/stops_v2/back.svg',
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 24),
                _TripHeaderCard(live: trip),
                if (open.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SectionLabel(l10n.nextStop),
                  const SizedBox(height: 12),
                  openCard(open.first, isNext: true),
                ],
                if (open.length > 1) ...[
                  const SizedBox(height: 12),
                  _SectionLabel(l10n.stillToCollect(open.length - 1)),
                  for (final stop in open.skip(1)) ...[
                    const SizedBox(height: 12),
                    openCard(stop, isNext: false),
                  ],
                ],
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SectionLabel(l10n.doneStops(done.length)),
                  for (final stop in done) ...[
                    const SizedBox(height: 8),
                    _liveDoneCard(context, stop, material(stop)),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _liveDoneCard(
    BuildContext context,
    DriverStopLive stop,
    String material,
  ) {
    final l10n = DriverLocalizations.of(context);
    final (status, value, type) = switch (stop.status) {
      'COLLECTED' => (
        l10n.collectedLabel,
        l10n.liveKg(formatKg(stop.totalKg ?? _linesKg(stop))),
        _DoneType.collected,
      ),
      'NOT_COLLECTED' => (l10n.zeroKg, l10n.nothingToCollect, _DoneType.zero),
      'AT_GATE' => (l10n.gateTeamWillEnter, '', _DoneType.zero),
      _ => (l10n.cancelledBySource, '', _DoneType.cancelled),
    };
    return _DoneStopCard(
      key: ValueKey('driver-done-stop-${stop.id}'),
      title: l10n.stopCardTitle(stop.sourceName, material),
      position: l10n.stopNumber(stop.stopOrder),
      status: status,
      value: value,
      type: type,
      onTap: stop.status == 'COLLECTED'
          ? () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    DriverCollectedStopDetailScreen(stopId: stop.id),
              ),
            )
          : null,
    );
  }

  static double _linesKg(DriverStopLive stop) {
    var total = 0.0;
    for (final line in stop.entryLines) {
      if (line is Map && line['unit'] == 'KG') {
        total += (line['quantity'] as num?)?.toDouble() ?? 0;
      }
    }
    return total;
  }
}

class _DriverStopsView extends StatelessWidget {
  const _DriverStopsView();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
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
                            title: l10n.tripOneStops,
                            backAsset: 'assets/icons/driver/stops_v2/back.svg',
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 24),
                          const _TripHeaderCard(),
                          const SizedBox(height: 12),
                          _SectionLabel(l10n.nextStop),
                          const SizedBox(height: 12),
                          _FullStopCard(
                            key: const ValueKey('driver-stop-0'),
                            title: l10n.stopCardTitle(
                              l10n.abcTextileMills,
                              l10n.sortedMaterial,
                            ),
                            position: l10n.stopPosition(6, 7),
                            location: l10n.industrialAreaSurat,
                            schedule: l10n.pickupSchedule,
                            contact: l10n.rakeshStoreManager,
                            isNext: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const DriverLocationFlowScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SectionLabel(l10n.stillToCollect(1)),
                          const SizedBox(height: 12),
                          _FullStopCard(
                            key: const ValueKey('driver-stop-1'),
                            title: l10n.stopCardTitle(
                              l10n.shreeSaiDairy,
                              l10n.mixedMaterial,
                            ),
                            position: l10n.stopPosition(7, 7),
                            location: l10n.lpSavaniRoadSurat,
                            schedule: l10n.pickupSchedule9to11,
                            contact: l10n.maheshOwner,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const DriverStopDetailScreen(
                                  pickupType: DriverPickupType.mixed,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SectionLabel(l10n.doneStops(5)),
                          const SizedBox(height: 12),
                          _DoneStopCard(
                            key: const ValueKey('driver-collected-stop-1'),
                            title: l10n.stopCardTitle(
                              l10n.greenParkSociety,
                              l10n.mixedMaterial,
                            ),
                            position: l10n.stopNumber(1),
                            status: l10n.collectedLabel,
                            value: l10n.greenParkWeight,
                            type: _DoneType.collected,
                            onTap: () => _openCollected(context),
                          ),
                          const SizedBox(height: 8),
                          _DoneStopCard(
                            key: const ValueKey('driver-collected-stop-2'),
                            title: l10n.stopCardTitle(
                              l10n.hotelRajdhani,
                              l10n.sortedMaterial,
                            ),
                            position: l10n.stopNumber(2),
                            status: l10n.collectedLabel,
                            value: l10n.hotelRajdhaniWeight,
                            type: _DoneType.collected,
                            onTap: () => _openCollected(context),
                          ),
                          const SizedBox(height: 8),
                          _DoneStopCard(
                            key: const ValueKey('driver-collected-stop-3'),
                            title: l10n.stopCardTitle(
                              l10n.navratriGroundEvent,
                              l10n.mixedMaterial,
                            ),
                            position: l10n.stopNumber(3),
                            status: l10n.collectedLabel,
                            value: l10n.navratriGroundWeight,
                            type: _DoneType.collected,
                            onTap: () => _openCollected(context),
                          ),
                          const SizedBox(height: 8),
                          _DoneStopCard(
                            title: l10n.stopCardTitle(
                              l10n.cityBakery,
                              l10n.sortedMaterial,
                            ),
                            position: l10n.stopNumber(4),
                            status: l10n.zeroKg,
                            value: l10n.noMaterialToday,
                            type: _DoneType.zero,
                          ),
                          const SizedBox(height: 8),
                          _DoneStopCard(
                            key: const ValueKey('driver-stop-4'),
                            title: l10n.stopCardTitle(
                              l10n.xyzTextileMills,
                              l10n.sortedMaterial,
                            ),
                            position: l10n.stopNumber(5),
                            status: l10n.cancelledBySource,
                            value: l10n.stockTakingReason,
                            type: _DoneType.cancelled,
                          ),
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

  void _openCollected(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const DriverCollectedStopDetailScreen(),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: DriverTextStyles.semibold16.copyWith(color: DriverColors.neutral950),
  );
}

class _TripHeaderCard extends StatelessWidget {
  const _TripHeaderCard({this.live});

  /// The live trip; null shows the design sample.
  final DriverTripLive? live;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      radius: 12,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  live != null
                      ? l10n.liveTripTime(
                          formatClock(live!.shiftStart),
                          formatClock(live!.shiftEnd),
                          live!.stops,
                        )
                      : l10n.morningTripWindow,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                live != null
                    ? '${live!.done}/${live!.stops}'
                    : l10n.fiveOfSevenDone,
                style: DriverTextStyles.semibold14.copyWith(
                  color: DriverColors.primary500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: DriverColors.cool100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _InfoLine(
                  asset: '$_homeAssets/vehicle.svg',
                  text: live?.crew ?? l10n.vehicleCrew,
                ),
                const SizedBox(height: 8),
                _InfoLine(
                  asset: '$_homeAssets/warehouse.svg',
                  text: live != null
                      ? l10n.liveDropAt(live!.warehouseName)
                      : l10n.dropMagdalla,
                  strong: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Count(
                live?.collected ?? 3,
                l10n.collectedLabel,
                DriverColors.primary50,
                DriverColors.primary500,
              ),
              const SizedBox(width: 6),
              _Count(
                live?.pending ?? 2,
                l10n.pendingStatus,
                DriverColors.yellow50,
                DriverColors.yellow700,
              ),
              const SizedBox(width: 6),
              _Count(
                live?.zeroKg ?? 1,
                l10n.zeroKg,
                DriverColors.cool300,
                DriverColors.neutral800,
              ),
              const SizedBox(width: 6),
              _Count(
                live?.cancelled ?? 1,
                l10n.cancelled,
                DriverColors.purple50,
                DriverColors.purple600,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.collectedOnTrip,
                  style: DriverTextStyles.medium14.copyWith(
                    color: DriverColors.neutral700,
                  ),
                ),
              ),
              Text(
                live != null
                    ? l10n.liveKg(formatKg(live!.collectedKg))
                    : l10n.weight420Kg,
                style: DriverTextStyles.bold16.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.value, this.label, this.background, this.foreground);
  final int value;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: DriverTextStyles.bold16.copyWith(color: foreground),
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

class _FullStopCard extends StatelessWidget {
  const _FullStopCard({
    super.key,
    required this.title,
    required this.position,
    required this.location,
    required this.schedule,
    required this.contact,
    required this.onTap,
    this.isNext = false,
  });

  final String title;
  final String position;
  final String location;
  final String schedule;
  final String contact;
  final VoidCallback onTap;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DriverColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isNext
            ? Border.all(color: DriverColors.primary500, width: 2)
            : null,
        boxShadow: const [
          BoxShadow(
            color: DriverColors.shadow,
            offset: Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: DriverTextStyles.semibold18.copyWith(
                      color: DriverColors.neutral900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  position,
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.neutral500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DriverColors.cool100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _InfoLine(asset: '$_homeAssets/pin.svg', text: location),
                  const SizedBox(height: 8),
                  _InfoLine(
                    asset: '$_homeAssets/schedule.svg',
                    text: schedule,
                    regular: true,
                  ),
                  const SizedBox(height: 8),
                  _InfoLine(
                    asset: '$_homeAssets/contact.svg',
                    text: contact,
                    strong: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (isNext)
                  _Chip(
                    label: l10n.nextStop,
                    background: DriverColors.primary500,
                    foreground: DriverColors.surface,
                  ),
                _Chip(
                  label: l10n.pendingStatus,
                  background: DriverColors.yellow50,
                  foreground: DriverColors.yellow700,
                  asset: '$_homeAssets/chip_clock.svg',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      '$_homeAssets/phone_green.svg',
                      package: _package,
                      width: 20,
                      height: 20,
                    ),
                    label: Text(l10n.call),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: DriverColors.primary500,
                      side: const BorderSide(color: DriverColors.primary500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: DriverTextStyles.bold16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: FilledButton.icon(
                      key: isNext ? const Key('driver-enter-collection') : null,
                      onPressed: isNext ? onTap : null,
                      icon: isNext
                          ? SvgPicture.asset(
                              '$_homeAssets/pencil.svg',
                              package: _package,
                              width: 20,
                              height: 20,
                            )
                          : null,
                      label: Text(
                        isNext ? l10n.enterCollection : l10n.opensAfterStop(6),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: DriverColors.primary500,
                        disabledBackgroundColor: DriverColors.cool300,
                        disabledForegroundColor: DriverColors.neutral800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: DriverTextStyles.bold16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!isNext) ...[
              const SizedBox(height: 8),
              Text(
                l10n.unlockStopMessage,
                style: DriverTextStyles.medium12.copyWith(
                  color: DriverColors.neutral800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.asset,
    required this.text,
    this.strong = false,
    this.regular = false,
  });
  final String asset;
  final String text;
  final bool strong;
  final bool regular;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 28,
        height: 28,
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: DriverColors.surface,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(asset, package: _package),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              (strong
                      ? DriverTextStyles.semibold14
                      : regular
                      ? DriverTextStyles.regular14
                      : DriverTextStyles.medium14)
                  .copyWith(
                    color: strong || regular
                        ? DriverColors.neutral950
                        : DriverColors.neutral700,
                  ),
        ),
      ),
    ],
  );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
    this.asset,
    this.constrained = false,
  });
  final String label;
  final Color background;
  final Color foreground;
  final String? asset;
  final bool constrained;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: constrained ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (asset != null) ...[
          SvgPicture.asset(asset!, package: _package, width: 16, height: 16),
          const SizedBox(width: 6),
        ],
        if (constrained)
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DriverTextStyles.semibold12.copyWith(color: foreground),
            ),
          )
        else
          Text(
            label,
            style: DriverTextStyles.semibold12.copyWith(color: foreground),
          ),
      ],
    ),
  );
}

enum _DoneType { collected, zero, cancelled }

class _DoneStopCard extends StatelessWidget {
  const _DoneStopCard({
    super.key,
    required this.title,
    required this.position,
    required this.status,
    required this.value,
    required this.type,
    this.onTap,
  });
  final String title;
  final String position;
  final String status;
  final String value;
  final _DoneType type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = type == _DoneType.collected
        ? DriverColors.primary50
        : type == _DoneType.zero
        ? DriverColors.cool300
        : DriverColors.purple50;
    final foreground = type == _DoneType.collected
        ? DriverColors.primary500
        : type == _DoneType.zero
        ? DriverColors.neutral800
        : DriverColors.purple600;
    final asset = type == _DoneType.collected
        ? '$_homeAssets/check.svg'
        : type == _DoneType.zero
        ? '$_homeAssets/scale.svg'
        : '$_homeAssets/cancelled.svg';
    return Material(
      color: DriverColors.surface,
      borderRadius: BorderRadius.circular(12),
      shadowColor: DriverColors.shadow,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DriverTextStyles.semibold16.copyWith(
                        color: DriverColors.neutral900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    position,
                    style: DriverTextStyles.medium12.copyWith(
                      color: DriverColors.neutral500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: _Chip(
                      label: status,
                      background: background,
                      foreground: foreground,
                      asset: asset,
                      constrained: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style:
                          (type == _DoneType.collected
                                  ? DriverTextStyles.bold16
                                  : DriverTextStyles.medium12)
                              .copyWith(
                                color: type == _DoneType.collected
                                    ? DriverColors.neutral950
                                    : DriverColors.neutral700,
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
