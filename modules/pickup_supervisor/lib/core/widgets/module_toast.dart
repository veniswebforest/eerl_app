import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';

const _successTick = 'assets/icons/supervisor/add_route/success_tick.svg';
const _errorMark = 'assets/icons/driver_labour/toast_error_mark.svg';
const _close = 'assets/icons/driver_labour/toast_close.svg';

enum ModuleToastKind { success, error }

/// Top banner toast (Deactivated, Reactive, Source Skipped …).
abstract final class ModuleToast {
  static void show(
    BuildContext context, {
    required ModuleToastKind kind,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    Timer? timer;
    var removed = false;
    void remove() {
      if (removed) return;
      removed = true;
      timer?.cancel();
      entry.remove();
    }

    entry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        top: MediaQuery.paddingOf(overlayContext).top + 14,
        left: 20,
        right: 20,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _ToastCard(
              kind: kind,
              title: title,
              message: message,
              onClose: remove,
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    timer = Timer(duration, remove);
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.kind,
    required this.title,
    required this.message,
    required this.onClose,
  });

  final ModuleToastKind kind;
  final String title;
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final success = kind == ModuleToastKind.success;
    return Material(
      key: const Key('module-toast'),
      color: success ? DriverColors.primary50 : DriverColors.red50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: DriverColors.cool300),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: success
                        ? DriverColors.primary400
                        : DriverColors.red500,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    success ? _successTick : _errorMark,
                    package: 'pickup_supervisor',
                    width: success ? 30 : 19.5,
                    height: success ? 30 : 19.5,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: DriverTextStyles.semibold16.copyWith(
                            color: DriverColors.neutral950,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          style: DriverTextStyles.medium14.copyWith(
                            color: DriverColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 11,
            child: GestureDetector(
              key: const Key('module-toast-close'),
              onTap: onClose,
              child: SvgPicture.asset(
                _close,
                package: 'pickup_supervisor',
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
