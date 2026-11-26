import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_danger_button.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_mock_data.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_stop_widgets.dart';
import 'package:pickup_supervisor/features/stop_detail/view/extra_pickup_screen.dart';
import 'package:pickup_supervisor/features/stop_detail/view/skip_source_screen.dart';
import 'package:pickup_supervisor/features/stop_detail/widgets/stop_detail_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M04 Stop detail.
///
/// * Pending / Next stop on an on-route trip: outcome box and a note that the
///   driver records the stop (no skip once a trip has started).
/// * Pending on a planned trip: "Skip this pickup" opens the skip form.
/// * Collected, 0 kg, missed, cancelled and paused stops show what was
///   recorded; 0 kg, missed and cancelled can add an extra pickup.
///
/// Pops with `true` once the pickup has been skipped.
class StopDetailScreen extends StatelessWidget {
  const StopDetailScreen({
    super.key,
    required this.stop,
    this.tripState = TripState.onRoute,
    this.summary = RouteDetailMockData.todaySummary,
    this.stopNumber = 1,
    this.totalStops = 1,
    this.tripDate = RouteDetailMockData.plannedTripDate,
  });

  final RouteStop stop;
  final TripState tripState;
  final RouteSummary summary;
  final int stopNumber;
  final int totalStops;

  /// Day of a planned trip ("Fri 23 Oct").
  final String tripDate;

  @override
  Widget build(BuildContext context) =>
      DriverLocalizationScope(child: _StopDetailView(screen: this));
}

class _StopDetailView extends StatelessWidget {
  const _StopDetailView({required this.screen});

  final StopDetailScreen screen;

  RouteStop get stop => screen.stop;
  RouteSummary get summary => screen.summary;
  StopRecord get record => stop.record ?? const StopRecord();
  bool get _planned => screen.tripState == TripState.planned;
  bool get _pending => stop.status == StopStatus.pending;
  bool get _next => stop.status == StopStatus.nextStop;
  bool get _canSkip => _planned && _pending;

  /// Mock "tomorrow" (the day after the on-route trip).
  static final _extraDate = DateTime(2026, 10, 23);

  Future<void> _skip(BuildContext context) async {
    final skipped = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SkipSourceScreen(sourceName: stop.name),
      ),
    );
    if (skipped == true && context.mounted) Navigator.of(context).pop(true);
  }

  void _addExtra(BuildContext context) => Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => ExtraPickupScreen(
        stopName: stop.name,
        address: stop.address,
        time: (record.regularSchedule ?? stop.schedule).time,
        routeName: summary.name,
        initialDate: _extraDate,
      ),
    ),
  );

  String _role(DriverLocalizations l10n, ContactRole role) => switch (role) {
    ContactRole.owner => l10n.sdRoleOwner,
    ContactRole.manager => l10n.sdRoleManager,
    ContactRole.storeManager => l10n.sdRoleStoreManager,
    ContactRole.office => l10n.sdRoleOffice,
  };

  String _routeLine(DriverLocalizations l10n) {
    if (_planned) {
      return l10n.sdRoutePlanned(summary.name, screen.tripDate, summary.plate);
    }
    final vehicle = summary.contractVehicle
        ? l10n.sdContractVehicleLower
        : l10n.sdOwnVehicleLower;
    if (stop.status == StopStatus.missed && summary.contractVehicle) {
      return l10n.sdRouteVehicleTransport(
        summary.name,
        summary.plate,
        vehicle,
        _transport,
      );
    }
    return l10n.sdRouteVehicle(summary.name, summary.plate, vehicle);
  }

  /// The approved mock trip keeps the transporter in `driverPhone`.
  String get _transport => summary.driverPhone;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final contact = stop.contact ?? RouteDetailMockData.defaultContact;
    final schedule = record.regularSchedule ?? stop.schedule;
    final showNote =
        screen.tripState == TripState.onRoute && (_pending || _next);
    return ModulePage(
      key: const Key('stop-detail-screen'),
      bottom: _canSkip
          ? ModuleDangerButton(
              key: const Key('stop-detail-skip'),
              label: l10n.sdSkipThisPickup,
              onPressed: () => _skip(context),
            )
          : null,
      child: ListView(
        clipBehavior: Clip.none,
        key: const Key('stop-detail-scroll'),
        padding: EdgeInsets.zero,
        children: [
          Row(
            children: [
              const ModuleBackButton(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.sdTitle,
                  style: DriverTextStyles.semibold20.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          StopInfoCard(
            title: routeStopTitle(l10n, stop),
            frequency: stop.frequency == null
                ? null
                : routeStopFrequencyLabel(l10n, stop.frequency!),
            rows: [
              (l10n.sdAddress, stop.address),
              (l10n.sdSchedule, routeStopScheduleText(l10n, schedule)),
              (l10n.sdRoute, _routeLine(l10n)),
              (
                l10n.sdPersonAtPickup,
                l10n.sdContactLine(
                  contact.name,
                  _role(l10n, contact.role),
                  contact.phone,
                ),
              ),
              (
                l10n.sdIecExecutive,
                l10n.sdIecLine(
                  RouteDetailMockData.iecName,
                  RouteDetailMockData.iecPhone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ..._statusContent(context, l10n),
          if (showNote) ...[
            const SizedBox(height: 32),
            Text(
              l10n.sdTripStartedNote,
              textAlign: TextAlign.center,
              style: DriverTextStyles.medium13.copyWith(
                color: DriverColors.slate600,
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<Widget> _statusContent(BuildContext context, DriverLocalizations l10n) {
    final call = StopCallButton(label: l10n.sdCallPerson);
    final addExtra = StopActionButton(
      key: const Key('stop-detail-add-extra'),
      label: l10n.sxAddExtra,
      icon: StopDetailAssets.add,
      onPressed: () => _addExtra(context),
    );
    return switch (stop.status) {
      StopStatus.pending ||
      StopStatus.nextStop => [_dueBox(l10n), const SizedBox(height: 24), call],
      StopStatus.collected => _collected(l10n),
      StopStatus.zeroKg => [
        StopOutcomeCard(
          tone: StopOutcomeTone.zero,
          title: l10n.sxZeroTitle,
          children: [
            StopRecordRow(
              label: l10n.sxVisitedAt,
              value: l10n.sxAtDate(record.time, record.date),
            ),
            ..._entryAndGps(l10n, tag: false),
            if (record.voice != null)
              StopRecordRow(
                label: l10n.sxNoteFromDriver,
                valueWidget: StopVoiceNote(
                  duration: record.voice!,
                  expand: true,
                ),
              ),
            if (record.hasPhoto)
              StopPhotoPlaceholder(label: l10n.sxPhotoFromDriver),
          ],
        ),
        const SizedBox(height: 24),
        call,
        const SizedBox(height: 12),
        addExtra,
      ],
      StopStatus.missed => [
        StopOutcomeCard(
          tone: StopOutcomeTone.missed,
          title: l10n.sxMissedTitle,
          children: [
            StopRecordRow(
              label: l10n.sxWhatHappened,
              value: l10n.sxMissedBody(record.warehouse, record.reachedAt),
            ),
            StopRecordRow(
              label: l10n.sxVehicleDriver,
              value: l10n.sxVehicleDriverValue(
                summary.plate,
                summary.driverName,
                _transport,
                record.driverPhone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        StopActionButton(
          key: const Key('stop-detail-call-driver'),
          label: l10n.sxCallDriver,
          icon: StopDetailAssets.callWhite,
          filled: true,
        ),
        const SizedBox(height: 12),
        StopActionButton(
          key: const Key('stop-detail-add-extra'),
          label: l10n.sxAddExtraTomorrow,
          icon: StopDetailAssets.add,
          onPressed: () => _addExtra(context),
        ),
      ],
      StopStatus.cancelledBySource => [
        StopOutcomeCard(
          tone: StopOutcomeTone.cancelled,
          title: routeStopStatusLabel(l10n, stop.status),
          children: [
            StopRecordRow(
              label: l10n.sxReason,
              value: _noteLabel(l10n) ?? l10n.rdNoteClosedStocktaking,
            ),
            StopRecordRow(
              label: l10n.sxCalledOffBy,
              value: l10n.sxCalledOffValue(
                record.calledOffBy,
                RouteDetailMockData.iecName,
                record.calledOffAt,
              ),
            ),
            StopRecordRow(
              label: l10n.sxNextPickup,
              value: l10n.sdDueOn(record.nextPickup, stop.schedule.time),
            ),
          ],
        ),
        const SizedBox(height: 24),
        addExtra,
      ],
      StopStatus.inactive => [
        StopOutcomeCard(
          tone: StopOutcomeTone.paused,
          title: l10n.sxPausedTitle(record.pausedRange),
          children: [
            StopRecordRow(label: l10n.sxReason, value: l10n.sxReasonRenovation),
            StopRecordRow(
              label: l10n.sxAskedBy,
              value: l10n.sxAskedByValue(
                record.askedOn,
                RouteDetailMockData.iecName,
              ),
            ),
            StopRecordRow(
              label: l10n.sxWhatHappens,
              value: l10n.sxPausedBody(record.nextPickup),
            ),
          ],
        ),
        const SizedBox(height: 24),
        StopActionButton(
          key: const Key('stop-detail-restart'),
          label: l10n.sxAskRestart,
          icon: StopDetailAssets.restart,
        ),
      ],
    };
  }

  String? _noteLabel(DriverLocalizations l10n) => switch (stop.note) {
    StopNote.closedForStocktaking => l10n.rdNoteClosedStocktaking,
    StopNote.askedToSkipToday => l10n.rdNoteAskedToSkip,
    _ => null,
  };

  Widget _dueBox(DriverLocalizations l10n) => StopOutcomeBox(
    next: _next,
    title: _next ? l10n.rdStatusNextStop : l10n.rdStatusPending,
    rows: [
      (
        l10n.sdDue,
        _planned
            ? l10n.sdDueOn(screen.tripDate, stop.schedule.time)
            : l10n.sdDueToday(stop.schedule.time),
      ),
      (
        l10n.sdOnTrip,
        _next && stop.distanceKm != null
            ? l10n.sdStopOfDistance(
                '${screen.stopNumber}',
                '${screen.totalStops}',
                stop.distanceKm!,
              )
            : l10n.sdStopOf('${screen.stopNumber}', '${screen.totalStops}'),
      ),
    ],
  );

  /// Data entry and GPS rows shared by the collected and 0 kg cards.
  List<Widget> _entryAndGps(DriverLocalizations l10n, {bool tag = true}) {
    final gate = record.entry == EntrySource.gate;
    final by = record.enteredBy.isEmpty ? summary.driverName : record.enteredBy;
    return [
      StopRecordRow(
        label: l10n.sxDataEntry,
        value: gate
            ? l10n.sxByGate(by, record.enteredAt)
            : l10n.sxByDriverApp(
                by,
                record.enteredAt.isEmpty ? record.time : record.enteredAt,
              ),
        extras: [
          if (tag)
            StopRecordTag(
              icon: gate ? StopDetailAssets.tagGate : StopDetailAssets.tagApp,
              label: gate ? l10n.sxEnteredGate : l10n.sxEnteredApp,
              amber: gate,
            ),
        ],
      ),
      StopRecordRow(
        label: l10n.sxGps,
        value: record.gps == null
            ? l10n.sxGpsNotRecorded
            : l10n.sxGpsValue(record.gps!, record.gpsDistanceM ?? ''),
        muted: record.gps == null,
        extras: [
          if (record.gps != null)
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StopRecordTag(
                  icon: StopDetailAssets.tagLocation,
                  label: l10n.sxLocationMatched,
                ),
                GestureDetector(
                  key: const Key('stop-detail-view-map'),
                  onTap: () {},
                  child: Text(
                    l10n.sxViewOnMap,
                    style: DriverTextStyles.bold12.copyWith(
                      color: DriverColors.primary500,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    ];
  }

  List<Widget> _collected(DriverLocalizations l10n) {
    final kg = record.totalKg ?? stop.amountKg;
    final pcs = record.totalPcs ?? stop.amountPcs;
    final amount = pcs != null && kg != null
        ? l10n.rdAmountKgPcs(stop.amountKg ?? kg, stop.amountPcs ?? pcs)
        : l10n.tpWeightKg(stop.amountKg ?? kg ?? '0');
    final time = record.time.isNotEmpty ? record.time : stop.collectedAt ?? '';
    return [
      StopOutcomeCard(
        tone: StopOutcomeTone.collected,
        title: l10n.sxCollectedTitle(amount),
        children: [
          StopRecordRow(
            label: l10n.sxCollectedAt,
            value: record.fromSlip
                ? l10n.sxFromSlip(time, record.date)
                : record.date.isEmpty
                ? time
                : l10n.sxAtDate(time, record.date),
          ),
          if (stop.record != null) ..._entryAndGps(l10n),
          if (record.note != null)
            StopRecordRow(
              label: l10n.sxNoteFromDriver,
              value: l10n.sxQuoted(record.note!),
              extras: [
                if (record.voice != null)
                  StopVoiceNote(duration: record.voice!),
              ],
            ),
        ],
      ),
      if (record.items.isNotEmpty) ...[
        const SizedBox(height: 24),
        StopCollectedItemsCard(
          title: l10n.sxCollectedItems,
          collectedLabel: l10n.sxCollected,
          items: [
            for (final it in record.items)
              (
                it.name,
                it.unit == CollectedUnit.kg ? l10n.sxKg : l10n.sxPcs,
                it.amount,
                it.thumb,
                it.photos,
                it.unit == CollectedUnit.pcs,
              ),
          ],
        ),
      ],
      if (record.totalKg != null || record.totalPcs != null) ...[
        const SizedBox(height: 24),
        StopTotalsCard(
          blocks: [
            if (kg != null)
              (l10n.sxKgBlock, l10n.sxTotalCollected, l10n.sxTotalKg(kg)),
            if (pcs != null)
              (l10n.sxPcsBlock, l10n.sxTotalCollected, l10n.sxTotalPcs(pcs)),
          ],
        ),
      ],
    ];
  }
}

/// Green-outlined "Call the person at the pickup point" button.
class StopCallButton extends StatelessWidget {
  const StopCallButton({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    width: double.infinity,
    child: OutlinedButton(
      key: const Key('stop-detail-call'),
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        backgroundColor: DriverColors.neutral50,
        foregroundColor: DriverColors.primary500,
        side: const BorderSide(color: DriverColors.primary500),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            StopDetailAssets.callOutline,
            package: StopDetailAssets.package,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DriverTextStyles.bold14.copyWith(
                fontSize: 15,
                color: DriverColors.primary500,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
