import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/core/widgets/module_selection_rows.dart';
import 'package:pickup_supervisor/core/widgets/module_text_fields.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/widgets/module_info_note.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_mock_data.dart';
import 'package:pickup_supervisor/features/route_actions/widgets/route_actions_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M04 Complete trip for the driver: the supervisor finishes a trip the
/// driver can't finish in the app. Opens from "Driver not using app" and
/// the on-route ⋮ sheet.
/// Static shell until its Figma frame is shared.
class CompleteTripScreen extends StatelessWidget {
  const CompleteTripScreen({
    super.key,
    required this.routeName,
    this.tripDate = RouteActionsMockData.todayDate,
    this.tripId,
    this.openStops = const [],
  });

  final String routeName;
  final String tripDate;

  /// The live trip and its open stops; null shows the design shell.
  final String? tripId;
  final List<RouteStop> openStops;

  @override
  Widget build(BuildContext context) {
    final id = tripId;
    if (id != null && OutboundLiveSession.of(context) != null) {
      return DriverLocalizationScope(
        child: _LiveCompleteTrip(screen: this, tripId: id),
      );
    }
    return _shell(context);
  }

  Widget _shell(BuildContext context) => DriverLocalizationScope(
    child: Builder(
      builder: (context) {
        final l10n = DriverLocalizations.of(context);
        return Scaffold(
          key: const Key('complete-trip-screen'),
          backgroundColor: DriverColors.background,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                    RouteActionsHeader(
                      title: l10n.raCompleteTrip,
                      subtitle: l10n.taSheetTitle(routeName, tripDate),
                    ),
                    const SizedBox(height: 20),
                    ModuleInfoNote(message: l10n.raCompleteTripBody),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// Complete trip for a driver not using the app (outbound doc, Pickup
/// Supervisor writes): the ticked stops were not reached and go back to
/// Unassigned; the other open stops wait for the gate team.
class _LiveCompleteTrip extends StatefulWidget {
  const _LiveCompleteTrip({required this.screen, required this.tripId});

  final CompleteTripScreen screen;
  final String tripId;

  @override
  State<_LiveCompleteTrip> createState() => _LiveCompleteTripState();
}

class _LiveCompleteTripState extends State<_LiveCompleteTrip> {
  final _notVisited = <String>{};
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final session = OutboundLiveSession.of(context);
    if (session == null) return;
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      final note = _note.text.trim();
      await session.change(
        () => session.writes.completeTripForDriver(
          tripId: widget.tripId,
          notVisited: _notVisited.toList(),
          note: note.isEmpty ? null : note,
        ),
      );
      navigator.pop(true);
    } on LocalWriteValidationException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final s = widget.screen;
    return Scaffold(
      key: const Key('complete-trip-screen'),
      backgroundColor: DriverColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                RouteActionsHeader(
                  title: l10n.raCompleteTrip,
                  subtitle: l10n.taSheetTitle(s.routeName, s.tripDate),
                ),
                const SizedBox(height: 20),
                ModuleInfoNote(message: l10n.raCompleteTripBody),
                const SizedBox(height: 20),
                Text(
                  l10n.liveNotVisitedHint,
                  style: DriverTextStyles.medium14.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 8),
                for (final stop in s.openStops)
                  if (stop.id != null) ...[
                    ModuleCheckRow(
                      key: Key('complete-not-visited-${stop.id}'),
                      label: stop.name,
                      checked: _notVisited.contains(stop.id),
                      onTap: () => setState(() {
                        if (!_notVisited.remove(stop.id)) {
                          _notVisited.add(stop.id!);
                        }
                      }),
                    ),
                    const SizedBox(height: 8),
                  ],
                const SizedBox(height: 12),
                ModuleRemarksField(
                  fieldKey: const Key('complete-trip-note'),
                  controller: _note,
                  maxChars: 500,
                ),
                const SizedBox(height: 20),
                ModuleButton(
                  key: const Key('complete-trip-submit'),
                  label: l10n.raCompleteTrip,
                  height: 52,
                  onPressed: _saving ? null : _complete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
