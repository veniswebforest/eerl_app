import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/driver/data/driver_live_data.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/core/widgets/module_choice_chip.dart';
import 'package:pickup_supervisor/core/widgets/module_modal.dart';
import 'package:pickup_supervisor/core/widgets/module_selection_rows.dart';
import 'package:pickup_supervisor/core/widgets/module_text_fields.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/widgets/pickup_supervisor_approval_widgets.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_mock_data.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_models.dart';
import 'package:pickup_supervisor/features/route_actions/widgets/route_actions_widgets.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_stop_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M04 Move stops: send some stops of a planned trip to another Planned
/// trip of the same day and warehouse. Pops with the names of the moved
/// stops once "3 Stops Moved" is closed.
class MoveStopsScreen extends StatelessWidget {
  const MoveStopsScreen({
    super.key,
    required this.routeName,
    required this.stops,
    this.tripDate = RouteActionsMockData.tripDate,
    this.tripId,
  });

  final String routeName;
  final List<RouteStop> stops;
  final String tripDate;

  /// The live trip the stops leave; null shows the design preview.
  final String? tripId;

  @override
  Widget build(BuildContext context) {
    final id = tripId;
    return DriverLocalizationScope(
      child: id == null
          ? _MoveStopsView(screen: this)
          : OutboundLiveBuilder<List<MoveTargetTrip>>(
              load: (session) => _targets(session, id),
              fallback: _MoveStopsView(screen: this),
              builder: (context, targets, _) =>
                  _MoveStopsView(screen: this, liveTargets: targets),
            ),
    );
  }

  /// Another of my Planned trips, the same day and warehouse.
  static Future<List<MoveTargetTrip>> _targets(
    OutboundLiveSession session,
    String tripId,
  ) async => [
    for (final t in await session.queries.moveStopsTargets(tripId))
      MoveTargetTrip(
        id: t['id']! as String,
        name: t['route_name'] as String? ?? '',
        plate: t['vehicle'] as String? ?? '',
        driver: t['driver_name'] as String? ?? '',
        time: formatClock(t['shift_start'] as String? ?? ''),
      ),
  ];
}

class _MoveStopsView extends StatefulWidget {
  const _MoveStopsView({required this.screen, this.liveTargets});

  final MoveStopsScreen screen;

  /// Live move targets; null shows the design samples.
  final List<MoveTargetTrip>? liveTargets;

  @override
  State<_MoveStopsView> createState() => _MoveStopsViewState();
}

class _MoveStopsViewState extends State<_MoveStopsView> {
  MoveReason? _reason = MoveReason.breakdown;
  List<MoveTargetTrip> get _targets =>
      widget.liveTargets ?? RouteActionsMockData.moveTargets;
  late MoveTargetTrip? _target = _targets.isEmpty ? null : _targets.first;
  late final Set<String> _ticked = {
    if (widget.liveTargets == null)
      for (final s in widget.screen.stops)
        if (RouteActionsMockData.initiallyMoved.contains(s.name)) s.name,
  };
  bool _saving = false;

  bool get _canMove =>
      !_saving && _reason != null && _target != null && _ticked.isNotEmpty;

  static const _reasonCodes = {
    MoveReason.breakdown: 'BREAKDOWN',
    MoveReason.vehicleNotAvailable: 'VEHICLE_UNAVAILABLE',
    MoveReason.driverAbsent: 'ABSENT',
    MoveReason.other: 'OTHER',
  };

  String _names(DriverLocalizations l10n, List<String> names) =>
      names.length < 2
      ? names.join()
      : l10n.msAnd(names.sublist(0, names.length - 1).join(', '), names.last);

  Future<void> _move() async {
    final l10n = DriverLocalizations.of(context);
    final navigator = Navigator.of(context);
    final moved = [
      for (final s in widget.screen.stops)
        if (_ticked.contains(s.name)) s.name,
    ];
    final target = _target!;
    final session = OutboundLiveSession.of(context);
    final fromTrip = widget.screen.tripId;
    if (session != null && fromTrip != null && target.id != null) {
      setState(() => _saving = true);
      try {
        await session.change(
          () => session.writes.moveStops(
            tripId: fromTrip,
            toTripId: target.id!,
            duePickupIds: [
              for (final s in widget.screen.stops)
                if (_ticked.contains(s.name) && s.id != null) s.id!,
            ],
            reason: _reasonCodes[_reason],
          ),
        );
      } on LocalWriteValidationException catch (error) {
        if (mounted) {
          setState(() => _saving = false);
          ScaffoldMessenger.maybeOf(
            context,
          )?.showSnackBar(SnackBar(content: Text(error.message)));
        }
        return;
      }
      if (!mounted) return;
    }
    await showModulePopup<void>(
      context,
      builder: (popupContext) => DriverLocalizationScope(
        child: ApprovalSuccessPopup(
          key: const Key('move-stops-done'),
          title: l10n.msMovedTitle(moved.length),
          message: l10n.msMovedBody(
            _names(l10n, moved),
            target.name,
            widget.screen.tripDate,
          ),
          primaryLabel: l10n.msOpenTrip(target.name),
          secondaryLabel: l10n.msBackToTrip,
          // Static: both return to this trip without the moved stops.
          onPrimary: () => Navigator.of(popupContext).pop(),
          onSecondary: () => Navigator.of(popupContext).pop(),
        ),
      ),
    );
    if (mounted) navigator.pop(moved.toSet());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final s = widget.screen;
    return Scaffold(
      key: const Key('move-stops-screen'),
      backgroundColor: DriverColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              key: const Key('move-stops-scroll'),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                RouteActionsHeader(
                  title: l10n.msTitle,
                  subtitle: l10n.taSheetTitle(s.routeName, s.tripDate),
                ),
                const SizedBox(height: 20),
                ModuleFieldLabel(l10n.msWhy, required: true),
                const SizedBox(height: 8),
                ModuleChoiceWrap<MoveReason>(
                  keyPrefix: 'move-reason',
                  values: MoveReason.values,
                  labelOf: (r) => switch (r) {
                    MoveReason.breakdown => l10n.msBreakdown,
                    MoveReason.vehicleNotAvailable => l10n.msVehicleNa,
                    MoveReason.driverAbsent => l10n.msDriverAbsent,
                    MoveReason.other => l10n.ctOther,
                  },
                  isSelected: (r) => r == _reason,
                  onTap: (r) => setState(() => _reason = r),
                ),
                const SizedBox(height: 20),
                ModuleFieldLabel(l10n.msMoveTo, required: true),
                const SizedBox(height: 8),
                for (final (i, t) in _targets.indexed) ...[
                  if (i > 0) const SizedBox(height: 8),
                  ModuleRadioCard(
                    key: Key('move-target-$i'),
                    selected: _target == t,
                    title: t.name,
                    subtitle: l10n.msTripLine(t.plate, t.driver, t.time),
                    trailing: MoveTargetTag(contract: t.contract),
                    onTap: () => setState(() => _target = t),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  l10n.msStopsToMove(_ticked.length),
                  style: DriverTextStyles.medium14.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 8),
                for (final (i, stop) in s.stops.indexed) ...[
                  ModuleCheckRow(
                    key: Key('move-stop-$i'),
                    checked: _ticked.contains(stop.name),
                    label: l10n.msStopLine(
                      stop.name,
                      stop.frequency == null
                          ? ''
                          : routeStopFrequencyLabel(l10n, stop.frequency!),
                      stop.schedule.time,
                    ),
                    onTap: () => setState(() {
                      if (!_ticked.remove(stop.name)) _ticked.add(stop.name);
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  l10n.msHint,
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.neutral400,
                  ),
                ),
                const SizedBox(height: 20),
                Opacity(
                  opacity: _canMove ? 1 : .5,
                  child: ModuleButton(
                    key: const Key('move-stops-submit'),
                    label: l10n.msMove(_ticked.length),
                    height: 52,
                    onPressed: _canMove ? _move : null,
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
