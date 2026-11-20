import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';
import 'package:pickup_supervisor/supervisor/view/supervisor_dashboard_shell.dart';

void main() => runApp(const PickupSupervisorApp());

class PickupSupervisorApp extends StatelessWidget {
  const PickupSupervisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        DriverLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: DriverLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Manrope',
        scaffoldBackgroundColor: DriverColors.background,
      ),
      home: const SupervisorDashboardShell(),
    );
  }
}
