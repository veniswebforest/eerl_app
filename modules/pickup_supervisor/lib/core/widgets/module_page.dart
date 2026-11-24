import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';

/// Shared page frame for module screens: Figma background, safe area, 20px
/// side padding and an optional pinned [bottom] area (action buttons).
class ModulePage extends StatelessWidget {
  const ModulePage({super.key, required this.child, this.bottom});

  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: child),
                  if (bottom != null) ...[const SizedBox(height: 16), bottom!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Green 40px square back button used by the module's detail screens.
class ModuleBackButton extends StatelessWidget {
  const ModuleBackButton({super.key});

  static const _asset = 'assets/icons/driver_labour/back.svg';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: DriverColors.primary500,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: const Key('module-back-button'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).maybePop(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              _asset,
              package: 'pickup_supervisor',
              width: 20,
              height: 20,
            ),
          ),
        ),
      ),
    );
  }
}
