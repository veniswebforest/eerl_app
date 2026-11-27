import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
import 'package:eerl_app/features/outbound/data/outbound_writes.dart';
import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/driver/data/driver_live_data.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/utils/module_date_format.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/core/widgets/module_choice_chip.dart';
import 'package:pickup_supervisor/core/widgets/module_date_range_sheet.dart';
import 'package:pickup_supervisor/core/widgets/module_info_note.dart';
import 'package:pickup_supervisor/core/widgets/module_modal.dart';
import 'package:pickup_supervisor/core/widgets/module_text_fields.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/widgets/pickup_supervisor_approval_widgets.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_mock_data.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_models.dart';
import 'package:pickup_supervisor/features/route_actions/widgets/route_actions_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M01 Ask the Collection Head: a vehicle, labour or pickup point request.
/// Opens from the trip sheet, Home and the drawer; nothing changes until the
/// Collection Head approves.
class AskCollectionHeadScreen extends StatelessWidget {
  const AskCollectionHeadScreen({super.key, this.routeName});

  /// The trip it was opened from (pre-selects For).
  final String? routeName;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: OutboundLiveBuilder<_LiveAsk>(
      load: _LiveAsk.load,
      fallback: _AskView(routeName: routeName),
      builder: (context, live, _) => _AskView(routeName: routeName, live: live),
    ),
  );
}

/// Your routes and pickup points for "For", today, and who answers
/// (outbound doc, Requests · Ask the Collection Head).
class _LiveAsk {
  const _LiveAsk({
    required this.routes,
    required this.points,
    required this.today,
    required this.headId,
    required this.headName,
  });

  final List<AskTarget> routes;
  final List<AskTarget> points;
  final DateTime today;
  final String? headId;
  final String? headName;

  static Future<_LiveAsk> load(OutboundLiveSession session) async {
    final q = session.queries;
    final head = await q.collectionHead();
    final headId = await q.collectionHeadId();
    return _LiveAsk(
      routes: [
        for (final r in await q.routeCards())
          if (r['is_active'] == 1)
            AskTarget(
              id: r['id']! as String,
              name: r['name'] as String? ?? '',
              detail: '',
              plate: r['vehicle'] as String? ?? '',
              contract: r['rented'] == 1,
              time: formatClock(r['start_time'] as String? ?? ''),
            ),
      ],
      points: [
        for (final s in await q.supervisorPickupPoints())
          AskTarget(
            id: s['id']! as String,
            name: s['name'] as String? ?? '',
            detail: s['area_name'] as String? ?? '',
          ),
      ],
      today: DateTime.parse(session.clock.today),
      headId: headId,
      headName: head?['name'] as String?,
    );
  }
}

class _AskView extends StatefulWidget {
  const _AskView({this.routeName, this.live});

  final String? routeName;

  /// Live choices; null shows the design samples.
  final _LiveAsk? live;

  @override
  State<_AskView> createState() => _AskViewState();
}

class _AskViewState extends State<_AskView> {
  List<AskTarget> get _routes =>
      widget.live?.routes ?? RouteActionsMockData.askRoutes;
  List<AskTarget> get _points =>
      widget.live?.points ?? RouteActionsMockData.askPoints;
  DateTime get _today => widget.live?.today ?? RouteActionsMockData.askToday;

  AskNeed _need = AskNeed.vehicle;
  late AskTarget? _target = _routes.isEmpty
      ? null
      : _routes.firstWhere(
          (r) => r.name == (widget.routeName ?? _routes.first.name),
          orElse: () => _routes.first,
        );
  late DateTimeRange _dates = widget.live != null
      ? DateTimeRange(start: _today, end: _today)
      : DateTimeRange(
          start: RouteActionsMockData.askRange.$1,
          end: RouteActionsMockData.askRange.$2,
        );
  bool _saving = false;

  static const _kinds = {
    AskNeed.vehicle: 'VEHICLE',
    AskNeed.labour: 'LABOUR',
    AskNeed.changeDetails: 'PICKUP_POINT_CHANGE',
    AskNeed.startPickups: 'START_PICKUPS',
    AskNeed.stopPickups: 'STOP_PICKUPS',
    AskNeed.pausePickups: 'PAUSE_PICKUPS',
  };

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Live: queue the request to the Collection Head (your reporting
  /// manager, else the office). False when the phone's checks refused it.
  Future<bool> _queue() async {
    final live = widget.live;
    final session = OutboundLiveSession.of(context);
    final target = _target;
    if (live == null || session == null || target == null) return true;
    final forTrip = _need.forTrip;
    final dated = _need != AskNeed.changeDetails;
    setState(() => _saving = true);
    try {
      await session.change(
        () => session.writes.askRequest(
          OutboundRequestDraft(
            id: session.newId(),
            kind: _kinds[_need]!,
            raisedAs: 'PICKUP_SUPERVISOR',
            sendTo: 'COLLECTION_HEAD',
            details: _details.text.trim(),
            assigneeId: live.headId,
            assigneeName: live.headName,
            routeId: forTrip ? target.id : null,
            routeName: forTrip ? target.name : null,
            sourceId: forTrip ? null : target.id,
            sourceName: forTrip ? null : target.name,
            fromDate: dated ? _iso(_dates.start) : null,
            toDate: dated && !DateUtils.isSameDay(_dates.start, _dates.end)
                ? _iso(_dates.end)
                : null,
          ),
        ),
      );
      return true;
    } on LocalWriteValidationException catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(error.message)));
      }
      return false;
    }
  }

  final _details = TextEditingController();

  @override
  void initState() {
    super.initState();
    _details.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  bool get _canSend =>
      !_saving && _target != null && _details.text.trim().isNotEmpty;

  void _setNeed(AskNeed need) => setState(() {
    if (need.forTrip != _need.forTrip) {
      _target = need.forTrip && _routes.isNotEmpty ? _routes.first : null;
    }
    _need = need;
  });

  Future<void> _pickTarget() async {
    final chosen = await showModuleSheet<AskTarget>(
      context,
      builder: (_) => DriverLocalizationScope(
        child: AskTargetSheet(
          key: const Key('ask-target-sheet'),
          forTrip: _need.forTrip,
          targets: _need.forTrip ? _routes : _points,
          selected: _target,
        ),
      ),
    );
    if (chosen != null && mounted) setState(() => _target = chosen);
  }

  Future<void> _pickDates() async {
    final today = _today;
    final range = await showModuleDateRangeSheet(
      context,
      initialRange: _dates,
      firstDate: today,
      today: today,
      initialMonth: _dates.start,
      weekdayInSummary: true,
    );
    if (range != null && mounted) setState(() => _dates = range);
  }

  Future<void> _send() async {
    final l10n = DriverLocalizations.of(context);
    final navigator = Navigator.of(context);
    if (!await _queue() || !mounted) return;
    await showModulePopup<void>(
      context,
      builder: (popupContext) => DriverLocalizationScope(
        child: ApprovalSuccessPopup(
          key: const Key('ask-head-sent'),
          title: l10n.ahSentTitle,
          message: l10n.ahSentBody,
          primaryLabel: l10n.ahSeeRequests,
          secondaryLabel: l10n.ahBackHome,
          // No My requests screen yet: both close the form.
          onPrimary: () => Navigator.of(popupContext).pop(),
          onSecondary: () => Navigator.of(popupContext).pop(),
        ),
      ),
    );
    if (mounted) navigator.pop(true);
  }

  String _day(DriverLocalizations l10n, DateTime d) =>
      '${l10n.calWeekdayShort('${d.weekday}')} ${l10n.dayMonth(d)}';

  Widget _group(String text) => Text(
    text,
    style: DriverTextStyles.semibold12.copyWith(color: DriverColors.pdfMuted),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    String need(AskNeed n) => switch (n) {
      AskNeed.vehicle => l10n.ahVehicle,
      AskNeed.labour => l10n.ahLabour,
      AskNeed.changeDetails => l10n.ahChangeDetails,
      AskNeed.startPickups => l10n.ahStartPickups,
      AskNeed.stopPickups => l10n.ahStopPickups,
      AskNeed.pausePickups => l10n.ahPausePickups,
    };
    Widget chips(List<AskNeed> values) => ModuleChoiceWrap<AskNeed>(
      keyPrefix: 'ask-need',
      compact: true,
      values: values,
      labelOf: need,
      isSelected: (n) => n == _need,
      onTap: _setNeed,
    );
    final t = _target;
    final dates = DateUtils.isSameDay(_dates.start, _dates.end)
        ? _day(l10n, _dates.start)
        : l10n.ahDayRange(_day(l10n, _dates.start), _day(l10n, _dates.end));
    return Scaffold(
      key: const Key('ask-head-screen'),
      backgroundColor: DriverColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              key: const Key('ask-head-scroll'),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                RouteActionsHeader(
                  title: l10n.supervisorAskCollectionHead,
                  subtitle: l10n.ahSubtitle,
                ),
                const SizedBox(height: 16),
                ModuleFieldLabel(l10n.ahWhat, required: true),
                const SizedBox(height: 16),
                _group(l10n.ahForTrip),
                const SizedBox(height: 8),
                chips([AskNeed.vehicle, AskNeed.labour]),
                const SizedBox(height: 8),
                _group(l10n.ahForPoint),
                const SizedBox(height: 8),
                chips([
                  AskNeed.changeDetails,
                  AskNeed.startPickups,
                  AskNeed.stopPickups,
                  AskNeed.pausePickups,
                ]),
                const SizedBox(height: 16),
                ModuleFieldLabel(l10n.ahFor, required: true),
                const SizedBox(height: 16),
                ModuleInputBox(
                  fieldKey: const Key('ask-head-for'),
                  value: t == null
                      ? ''
                      : t.isRoute
                      ? l10n.ahRouteLine(t.name, t.plate!)
                      : t.name,
                  trailing: RotatedBox(
                    quarterTurns: 1,
                    child: routeActionsIcon(RouteActionsAssets.dropdown, 24),
                  ),
                  onTap: _pickTarget,
                ),
                const SizedBox(height: 16),
                ModuleFieldLabel(l10n.ahDates, required: true),
                const SizedBox(height: 16),
                ModuleInputBox(
                  fieldKey: const Key('ask-head-dates'),
                  value: dates,
                  trailing: routeActionsIcon(RouteActionsAssets.calendar, 24),
                  onTap: _pickDates,
                ),
                const SizedBox(height: 16),
                ModuleFieldLabel(l10n.ahDetails, required: true),
                const SizedBox(height: 16),
                ModuleTextArea(
                  controller: _details,
                  fieldKey: const Key('ask-head-details'),
                ),
                const SizedBox(height: 16),
                ModuleInfoNote(message: l10n.ahInfo),
                const SizedBox(height: 16),
                Opacity(
                  opacity: _canSend ? 1 : .5,
                  child: ModuleButton(
                    key: const Key('ask-head-send'),
                    label: l10n.ahSend,
                    height: 52,
                    onPressed: _canSend ? _send : null,
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
