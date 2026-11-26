import 'package:flutter/material.dart';
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
  });

  final String routeName;
  final String tripDate;

  @override
  Widget build(BuildContext context) =>
      DriverLocalizationScope(child: _ChangeTeamView(screen: this));
}

class _ChangeTeamView extends StatefulWidget {
  const _ChangeTeamView({required this.screen});

  final ChangeTeamScreen screen;

  @override
  State<_ChangeTeamView> createState() => _ChangeTeamViewState();
}

class _ChangeTeamViewState extends State<_ChangeTeamView> {
  static const _driver = RouteActionsMockData.routeDriver;
  static const _labour = RouteActionsMockData.routeLabour;

  // Opens as in Figma: the absent driver already replaced.
  TeamPerson? _newDriver = RouteActionsMockData.people.first;
  TeamPerson? _newLabour;
  TeamChangeReason? _reason = TeamChangeReason.absent;

  bool get _canSave =>
      _reason != null && (_newDriver != null || _newLabour != null);

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
          people: RouteActionsMockData.people,
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
                const SizedBox(height: 20),
                Opacity(
                  opacity: _canSave ? 1 : .5,
                  child: ModuleButton(
                    key: const Key('change-team-save'),
                    label: l10n.ctSave,
                    height: 52,
                    onPressed: _canSave
                        ? () => Navigator.of(context).pop(
                            TripTeamChange(
                              driver: (_newDriver ?? _driver).name,
                              replaces: _driver.name,
                            ),
                          )
                        : null,
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
