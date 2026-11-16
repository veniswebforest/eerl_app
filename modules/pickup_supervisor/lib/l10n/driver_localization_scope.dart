import 'package:flutter/widgets.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

class DriverLocalizationScope extends StatelessWidget {
  const DriverLocalizationScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      delegates: const [DriverLocalizations.delegate],
      child: child,
    );
  }
}
