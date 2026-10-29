import 'dart:io';

import 'package:flutter/material.dart';

abstract final class AppImagePreviewDialog {
  static const double backgroundOpacity = 0.78;

  static Future<void> show<T extends Object>(
    BuildContext context, {
    required ImageProvider<T> imageProvider,
  }) {
    return showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).closeButtonTooltip,
      barrierColor: Colors.black.withValues(alpha: backgroundOpacity),
      transitionDuration: const Duration(milliseconds: 180),
      transitionBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, _, _) => Material(
        key: const Key('app-image-preview-dialog'),
        type: MaterialType.transparency,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  key: const Key('app-image-preview-background'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
                  child: InteractiveViewer(
                    key: const Key('app-image-preview-zoom'),
                    minScale: 0.8,
                    maxScale: 5,
                    boundaryMargin: const EdgeInsets.all(24),
                    child: Center(
                      child: Image(
                        key: const Key('app-image-preview-image'),
                        image: imageProvider,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.broken_image_outlined,
                          size: 56,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 8,
                end: 12,
                child: IconButton.filled(
                  key: const Key('app-image-preview-close'),
                  tooltip: MaterialLocalizations.of(
                    dialogContext,
                  ).closeButtonTooltip,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.48),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showSource(BuildContext context, String source) {
    final value = source.trim();
    if (value.isEmpty) return Future<void>.value();
    if (value.startsWith('assets/')) {
      return show(context, imageProvider: AssetImage(value));
    }
    final uri = Uri.tryParse(value);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return show(context, imageProvider: NetworkImage(value));
    }
    return show(context, imageProvider: FileImage(File(value)));
  }
}
