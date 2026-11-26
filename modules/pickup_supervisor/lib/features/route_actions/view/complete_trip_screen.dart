import 'package:flutter/material.dart';
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
  });

  final String routeName;
  final String tripDate;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
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
