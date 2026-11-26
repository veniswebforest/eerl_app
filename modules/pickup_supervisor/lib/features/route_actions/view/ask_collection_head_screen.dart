import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) =>
      DriverLocalizationScope(child: _AskView(routeName: routeName));
}

class _AskView extends StatefulWidget {
  const _AskView({this.routeName});

  final String? routeName;

  @override
  State<_AskView> createState() => _AskViewState();
}

class _AskViewState extends State<_AskView> {
  static const _routes = RouteActionsMockData.askRoutes;
  static const _points = RouteActionsMockData.askPoints;

  AskNeed _need = AskNeed.vehicle;
  late AskTarget? _target = _routes.firstWhere(
    (r) => r.name == (widget.routeName ?? _routes.first.name),
    orElse: () => _routes.first,
  );
  late DateTimeRange _dates = DateTimeRange(
    start: RouteActionsMockData.askRange.$1,
    end: RouteActionsMockData.askRange.$2,
  );
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

  bool get _canSend => _target != null && _details.text.trim().isNotEmpty;

  void _setNeed(AskNeed need) => setState(() {
    if (need.forTrip != _need.forTrip) {
      _target = need.forTrip ? _routes.first : null;
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
    final today = RouteActionsMockData.askToday;
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
