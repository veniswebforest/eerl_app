import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_assets.dart';

/// "Are you sure?" confirmation popup. Resolves to `true` on confirm.
Future<bool> showDriverLabourConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  required Color confirmColor,
  double confirmRadius = 14,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: Colors.black.withValues(alpha: .6),
    pageBuilder: (dialogContext, _, _) => Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: const SizedBox.expand(),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 335),
              child: Material(
                color: DriverColors.neutral50,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: DriverTextStyles.bold24.copyWith(
                          color: DriverColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 247),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: DriverTextStyles.medium14.copyWith(
                            color: DriverColors.neutral600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: FilledButton(
                                key: const Key('driver-labour-dialog-cancel'),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                style: FilledButton.styleFrom(
                                  backgroundColor: DriverColors.cool200,
                                  foregroundColor: DriverColors.neutral950,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: DriverTextStyles.semibold16,
                                ),
                                child: Text(cancelLabel),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: FilledButton(
                                key: const Key('driver-labour-dialog-confirm'),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: confirmColor,
                                  foregroundColor: DriverColors.neutral50,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      confirmRadius,
                                    ),
                                  ),
                                  textStyle: DriverTextStyles.bold16,
                                ),
                                child: Text(confirmLabel),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

enum DriverLabourToastKind { success, error }

/// Top banner toast (Deactivated / Reactive Successfully).
abstract final class DriverLabourToast {
  static void show(
    BuildContext context, {
    required DriverLabourToastKind kind,
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

  final DriverLabourToastKind kind;
  final String title;
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final success = kind == DriverLabourToastKind.success;
    return Material(
      key: const Key('driver-labour-toast'),
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
                    success
                        ? DriverLabourAssets.successTick
                        : DriverLabourAssets.toastErrorMark,
                    package: DriverLabourAssets.package,
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
              key: const Key('driver-labour-toast-close'),
              onTap: onClose,
              child: SvgPicture.asset(
                DriverLabourAssets.toastClose,
                package: DriverLabourAssets.package,
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
