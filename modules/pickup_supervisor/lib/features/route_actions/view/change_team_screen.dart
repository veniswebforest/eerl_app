import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
import 'package:eerl_app/features/outbound/data/outbound_writes.dart';
import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/core/widgets/module_choice_chip.dart';
import 'package:pickup_supervisor/core/widgets/module_info_note.dart';
import 'package:pickup_supervisor/core/widgets/module_modal.dart';
import 'package:pickup_supervisor/core/widgets/module_tag.dart';
import 'package:pickup_supervisor/core/widgets/module_text_fields.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_mock_data.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_models.dart';
import 'package:pickup_supervisor/features/route_actions/widgets/route_actions_widgets.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M04 Change for this trip: swap the driver or labour on one planned
/// trip. The route keeps its own team. Pops with the [TripTeamChange].
class ChangeTeamScreen extends StatelessWidget {
  const ChangeTeamScreen({
    super.key,
    required this.routeName,
    this.tripDate = RouteActionsMockData.tripDate,
    this.tripId,
  });

  final String routeName;
  final String tripDate;

  /// The live trip; null shows the design preview.
  final String? tripId;

  @override
  Widget build(BuildContext context) {
    final id = tripId;
    return DriverLocalizationScope(
      child: id == null
          ? _ChangeTeamView(screen: this)
          : OutboundLiveBuilder<_LiveTeam?>(
              load: (session) => _LiveTeam.load(session, id),
              fallback: _ChangeTeamView(screen: this),
              builder: (context, team, _) =>
                  _ChangeTeamView(screen: this, live: team),
            ),
    );
  }
}

String _tail(String? phone) {
  final digits = (phone ?? '').replaceAll(RegExp(r'\D'), '');
  return digits.length <= 4 ? digits : digits.substring(digits.length - 4);
}

/// The trip's team and who is free that day and shift, from SQLite
/// (outbound doc, Change Driver or Labour). Online, the free-staff call
/// also sees other supervisors' trips.
class _LiveTeam {
  const _LiveTeam({
    required this.trip,
    required this.driver,
    required this.labour,
    required this.drivers,
    required this.labourers,
    required this.stopIds,
  });

  final Map<String, Object?> trip;
  final TeamPerson driver;
  final TeamPerson? labour;
  final List<TeamPerson> drivers;
  final List<TeamPerson> labourers;

  /// The trip's stops in order: a team change keeps them.
  final List<String> stopIds;

  static Future<_LiveTeam?> load(OutboundLiveSession session, String id) async {
    final q = session.queries;
    final trip = await q.driverTrip(id);
    if (trip == null) return null;
    TeamPerson person(String? id, String? name, String? phone) => TeamPerson(
      id: id,
      phone: phone,
      name: name ?? '',
      phoneTail: _tail(phone),
    );
    return _LiveTeam(
      trip: trip,
      driver: person(
        trip['driver_id'] as String?,
        trip['driver_name'] as String?,
        trip['driver_phone'] as String?,
      ),
      labour: trip['labour_id'] == null
          ? null
          : person(
              trip['labour_id'] as String?,
              trip['labour_name'] as String?,
              trip['labour_phone'] as String?,
            ),
      drivers: [
        for (final d in await q.freeDrivers(id))
          person(
            d['user_id'] as String?,
            d['name'] as String?,
            d['phone'] as String?,
          ),
      ],
      labourers: [
        for (final l in await q.freeLabour(id))
          person(
            l['id'] as String?,
            l['name'] as String?,
            l['phone'] as String?,
          ),
      ],
      stopIds: [
        for (final s in await q.tripStopsWithState(id)) s['id']! as String,
      ],
    );
  }
}

class _ChangeTeamView extends StatefulWidget {
  const _ChangeTeamView({required this.screen, this.live});

  final ChangeTeamScreen screen;
  final _LiveTeam? live;

  @override
  State<_ChangeTeamView> createState() => _ChangeTeamViewState();
}

class _ChangeTeamViewState extends State<_ChangeTeamView> {
  _LiveTeam? get _live => widget.live;
  TeamPerson get _driver => _live?.driver ?? RouteActionsMockData.routeDriver;
  TeamPerson get _labour =>
      _live?.labour ??
      (_live != null
          ? const TeamPerson(name: '—', phoneTail: '')
          : RouteActionsMockData.routeLabour);

  // Opens as in Figma: the absent driver already replaced. Live: no change.
  late TeamPerson? _newDriver = widget.live != null
      ? null
      : RouteActionsMockData.people.first;
  TeamPerson? _newLabour;
  TeamChangeReason? _reason = TeamChangeReason.absent;
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _note.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _canSave =>
      !_saving &&
      _reason != null &&
      (_newDriver != null || _newLabour != null) &&
      (_live == null ||
          _reason != TeamChangeReason.other ||
          _note.text.trim().isNotEmpty);

  /// Live: Change for today with the new driver or labourer
  /// (`POST /pickup-trips/{id}/change-for-today`), keeping the stops.
  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final change = TripTeamChange(
      driver: (_newDriver ?? _driver).name,
      replaces: _driver.name,
    );
    final live = _live;
    final session = OutboundLiveSession.of(context);
    if (live != null && session != null) {
      final trip = live.trip;
      final driver = _newDriver ?? _driver;
      final labour = _newLabour ?? live.labour;
      final rented = trip['vehicle_kind'] == 'CONTRACT';
      setState(() => _saving = true);
      try {
        await session.change(
          () => session.writes.changeTripForToday(
            tripId: trip['id']! as String,
            team: TripTeam(
              vehicleId: rented ? null : trip['vehicle_id'] as String?,
              vehiclePlate: trip['vehicle_plate'] as String?,
              rented: rented
                  ? RentedVehicle(
                      vehicleNumber:
                          trip['rented_vehicle_number'] as String? ?? '',
                      transporterName: trip['transporter_name'] as String?,
                      driverName: trip['rented_driver_name'] as String?,
                      driverPhone: trip['rented_driver_phone'] as String?,
                      capacityKg: (trip['rented_capacity_kg'] as num?)
                          ?.toDouble(),
                    )
                  : null,
              driverId: driver.id,
              driverName: driver.name,
              driverPhone: driver.phone,
              labourId: labour?.id,
              labourName: labour?.name,
              labourPhone: labour?.phone,
            ),
            stopIds: live.stopIds,
            reason: _reason == TeamChangeReason.absent ? 'ABSENT' : 'OTHER',
            note: _reason == TeamChangeReason.other ? _note.text.trim() : null,
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
    }
    navigator.pop(change);
  }

  Future<void> _pick({required bool driver}) async {
    final l10n = DriverLocalizations.of(context);
    final chosen = await showModuleSheet<TeamPerson>(
      context,
      builder: (_) => DriverLocalizationScope(
        child: TeamPersonSheet(
          key: Key(driver ? 'driver-sheet' : 'labour-sheet'),
          title: driver ? l10n.ctDriverForTrip : l10n.ctLabourForTrip,
          freeOn: l10n.ctFreeOn(
            widget.screen.tripDate,
            RouteActionsMockData.shiftWindow,
          ),
          busyNote: driver ? l10n.ctBusyDriverNote : l10n.ctBusyLabourNote,
          people: _live == null
              ? RouteActionsMockData.people
              : (driver ? _live!.drivers : _live!.labourers),
          selected: driver ? _newDriver : _newLabour,
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    setState(() => driver ? _newDriver = chosen : _newLabour = chosen);
  }

  String _personLine(DriverLocalizations l10n, TeamPerson p) {
    final person = l10n.ctPerson(p.name, p.phoneTail);
    if (p.busy) {
      return l10n.ctPersonNote(
        person,
        l10n.ctBusy(p.busyWith!.$1, p.busyWith!.$2),
      );
    }
    if (p.freeUntil != null) return person;
    return l10n.ctPersonNote(person, l10n.ctFreeToday);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final s = widget.screen;
    final chevron = routeActionsIcon(RouteActionsAssets.chevronDown, 20);
    return Scaffold(
      key: const Key('change-team-screen'),
      backgroundColor: DriverColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              key: const Key('change-team-scroll'),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                RouteActionsHeader(
                  title: l10n.ctTitle,
                  subtitle: l10n.taSheetTitle(s.routeName, s.tripDate),
                ),
                const SizedBox(height: 20),
                ModuleInfoNote(message: l10n.ctInfo),
                const SizedBox(height: 20),
                _OnRouteCard(driver: _driver, labour: _labour),
                const SizedBox(height: 20),
                ModuleFieldLabel(l10n.ctDriverForTrip, required: true),
                const SizedBox(height: 8),
                ModuleSelectBox(
                  key: const Key('change-team-driver'),
                  caption: _newDriver == null
                      ? l10n.ctNoChange
                      : l10n.ctReplaces(_driver.name),
                  value: _personLine(l10n, _newDriver ?? _driver),
                  trailing: chevron,
                  onTap: () => _pick(driver: true),
                ),
                const SizedBox(height: 20),
                ModuleFieldLabel(l10n.ctLabourForTrip),
                const SizedBox(height: 8),
                ModuleSelectBox(
                  key: const Key('change-team-labour'),
                  caption: _newLabour == null
                      ? l10n.ctNoChange
                      : l10n.ctReplaces(_labour.name),
                  value: _newLabour == null
                      ? l10n.ctPerson(_labour.name, _labour.phoneTail)
                      : _personLine(l10n, _newLabour!),
                  trailing: chevron,
                  onTap: () => _pick(driver: false),
                ),
                const SizedBox(height: 20),
                ModuleFieldLabel(l10n.ctReason, required: true),
                const SizedBox(height: 8),
                ModuleChoiceWrap<TeamChangeReason>(
                  keyPrefix: 'change-team-reason',
                  values: TeamChangeReason.values,
                  labelOf: (r) => switch (r) {
                    TeamChangeReason.absent => l10n.ctAbsent,
                    TeamChangeReason.other => l10n.ctOther,
                  },
                  isSelected: (r) => r == _reason,
                  onTap: (r) => setState(() => _reason = r),
                ),
                if (_live != null && _reason == TeamChangeReason.other) ...[
                  const SizedBox(height: 12),
                  ModuleRemarksField(
                    fieldKey: const Key('change-team-note'),
                    controller: _note,
                  ),
                ],
                const SizedBox(height: 20),
                Opacity(
                  opacity: _canSave ? 1 : .5,
                  child: ModuleButton(
                    key: const Key('change-team-save'),
                    label: l10n.ctSave,
                    height: 52,
                    onPressed: _canSave ? _save : null,
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

/// "On the route": the route's own driver (Absent) and labour.
class _OnRouteCard extends StatelessWidget {
  const _OnRouteCard({required this.driver, required this.labour});

  final TeamPerson driver;
  final TeamPerson labour;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    Widget person(String label, TeamPerson p) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DriverTextStyles.medium12.copyWith(
            color: DriverColors.neutral400,
          ),
        ),
        Text(
          l10n.ctPerson(p.name, p.phoneTail),
          style: DriverTextStyles.semibold14.copyWith(
            color: DriverColors.neutral950,
          ),
        ),
      ],
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: DriverColors.shadow,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.ctOnRoute,
            style: DriverTextStyles.semibold14.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: person(l10n.ctDriver, driver)),
              const SizedBox(width: 8),
              ModuleTag(label: l10n.ctAbsent, tone: ModuleTagTone.red),
            ],
          ),
          const SizedBox(height: 10),
          person(l10n.ctLabour, labour),
        ],
      ),
    );
  }
}
