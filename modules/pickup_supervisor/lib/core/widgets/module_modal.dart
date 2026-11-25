import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';

const _barrierColor = Color(0x99000000);

/// Blurred, dimmed backdrop used behind module popups and sheets (Figma:
/// black 60% with a 5px background blur).
class _BlurBarrier extends StatelessWidget {
  const _BlurBarrier({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: FadeTransition(
      opacity: animation,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: const ColoredBox(color: _barrierColor, child: SizedBox.expand()),
      ),
    ),
  );
}

/// Centered rounded popup (radius 24, 16px padding) over a blurred backdrop.
Future<T?> showModulePopup<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, _, _) => SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Material(
              color: DriverColors.neutral50,
              borderRadius: BorderRadius.circular(24),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: builder(dialogContext),
              ),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (_, animation, _, child) => Stack(
      children: [
        Positioned.fill(child: _BlurBarrier(animation: animation)),
        FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: .96, end: 1).animate(animation),
            child: child,
          ),
        ),
      ],
    ),
  );
}

/// Bottom sheet with a drag handle and 24px top corners over a blurred
/// backdrop. It moves up with the keyboard.
Future<T?> showModuleSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool showHandle = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (sheetContext, _, _) => Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Material(
          color: DriverColors.neutral50,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, showHandle ? 12 : 24, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showHandle) ...[
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: DriverColors.sheetHandle,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  builder(sheetContext),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (_, animation, _, child) => Stack(
      children: [
        Positioned.fill(child: _BlurBarrier(animation: animation)),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ],
    ),
  );
}
