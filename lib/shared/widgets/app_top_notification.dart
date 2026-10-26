import 'dart:async';

import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';

enum AppTopNotificationTone { success, error, info }

/// Displays a transient notification above the current screen without taking
/// part in its layout. Only one notification is visible at a time.
abstract final class AppTopNotification {
  static OverlayEntry? _activeEntry;

  static void show(
    BuildContext context, {
    required String title,
    String? subtitle,
    AppTopNotificationTone tone = AppTopNotificationTone.info,
    Duration duration = const Duration(seconds: 2),
    Key? key,
    Key? closeButtonKey,
    Widget? icon,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    _activeEntry?.remove();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => _AppTopNotificationEntry(
        notificationKey: key,
        title: title,
        subtitle: subtitle,
        tone: tone,
        duration: duration,
        icon: icon,
        closeButtonKey: closeButtonKey,
        onRemoved: () {
          if (entry.mounted) entry.remove();
          if (identical(_activeEntry, entry)) _activeEntry = null;
        },
      ),
    );
    _activeEntry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    _activeEntry?.remove();
    _activeEntry = null;
  }
}

class _AppTopNotificationEntry extends StatefulWidget {
  const _AppTopNotificationEntry({
    required this.notificationKey,
    required this.title,
    required this.subtitle,
    required this.tone,
    required this.duration,
    required this.icon,
    required this.closeButtonKey,
    required this.onRemoved,
  });

  final Key? notificationKey;
  final String title;
  final String? subtitle;
  final AppTopNotificationTone tone;
  final Duration duration;
  final Widget? icon;
  final Key? closeButtonKey;
  final VoidCallback onRemoved;

  @override
  State<_AppTopNotificationEntry> createState() =>
      _AppTopNotificationEntryState();
}

class _AppTopNotificationEntryState extends State<_AppTopNotificationEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _opacity;
  Timer? _timer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 220),
    );
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.35),
      end: Offset.zero,
    ).animate(animation);
    _opacity = Tween<double>(begin: 0, end: 1).animate(animation);
    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _timer?.cancel();
    await _controller.reverse();
    widget.onRemoved();
  }

  @override
  Widget build(BuildContext context) {
    final palette = switch (widget.tone) {
      AppTopNotificationTone.success => (
        color: AppColors.primary500,
        background: AppColors.primary50,
        defaultIcon: Icons.check_rounded,
      ),
      AppTopNotificationTone.error => (
        color: AppColors.red500,
        background: AppColors.red50,
        defaultIcon: Icons.error_outline_rounded,
      ),
      AppTopNotificationTone.info => (
        color: AppColors.secondary500,
        background: AppColors.secondary50,
        defaultIcon: Icons.info_outline_rounded,
      ),
    };
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12,
      left: 16,
      right: 16,
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _opacity,
                child: Material(
                  type: MaterialType.transparency,
                  child: AppMessageBanner(
                    key: widget.notificationKey,
                    title: widget.title,
                    subtitle: widget.subtitle,
                    color: palette.color,
                    backgroundColor: palette.background,
                    borderColor: AppColors.cool400,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x24000000),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                    iconBackgroundColor: palette.color,
                    iconPadding: const EdgeInsets.all(5),
                    icon:
                        widget.icon ??
                        Icon(
                          palette.defaultIcon,
                          size: 18,
                          color: Colors.white,
                        ),
                    autoDismiss: false,
                    closeButtonKey: widget.closeButtonKey,
                    onClose: _dismiss,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
