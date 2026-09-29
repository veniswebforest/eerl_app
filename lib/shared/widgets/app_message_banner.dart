import 'dart:async';

import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

/// Shared notification/status banner used for success, warning, and error UI.
/// Automatically hides after 3 seconds by default when [onClose] or [autoDismiss] is enabled.
class AppMessageBanner extends StatefulWidget {
  const AppMessageBanner({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    this.subtitle,
    this.onClose,
    this.autoDismiss = true,
    this.autoDismissDuration = const Duration(seconds: 3),
    this.backgroundColor,
    this.borderColor,
    this.closeIcon,
    this.height,
    this.padding = const EdgeInsets.fromLTRB(10, 10, 8, 10),
    this.borderRadius = 12,
    this.iconBackgroundColor,
    this.iconPadding = EdgeInsets.zero,
    this.titleStyle,
    this.subtitleStyle,
    this.subtitleMaxLines = 2,
    this.gradient,
    this.boxShadow,
    this.borderWidth = 1,
    this.leadingGap = 8,
  });

  final String title;
  final String? subtitle;
  final Color color;
  final Widget icon;
  final VoidCallback? onClose;
  final bool autoDismiss;
  final Duration? autoDismissDuration;
  final Color? backgroundColor;
  final Color? borderColor;
  final Widget? closeIcon;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? iconBackgroundColor;
  final EdgeInsetsGeometry iconPadding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final int subtitleMaxLines;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final double borderWidth;
  final double leadingGap;

  @override
  State<AppMessageBanner> createState() => _AppMessageBannerState();
}

class _AppMessageBannerState extends State<AppMessageBanner> {
  Timer? _dismissTimer;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant AppMessageBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title ||
        oldWidget.subtitle != widget.subtitle ||
        oldWidget.key != widget.key) {
      _dismissTimer?.cancel();
      _isVisible = true;
      _startTimerIfNeeded();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _startTimerIfNeeded() {
    if (widget.onClose != null &&
        widget.autoDismiss &&
        widget.autoDismissDuration != null &&
        widget.autoDismissDuration! > Duration.zero) {
      _dismissTimer?.cancel();
      _dismissTimer = Timer(widget.autoDismissDuration!, () {
        if (!mounted) return;
        setState(() {
          _isVisible = false;
        });
        widget.onClose?.call();
      });
    }
  }

  void _handleDismiss() {
    _dismissTimer?.cancel();
    if (mounted) {
      setState(() {
        _isVisible = false;
      });
    }
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    final hasSubtitle = widget.subtitle != null && widget.subtitle!.isNotEmpty;
    final leading = widget.iconBackgroundColor == null
        ? widget.icon
        : Container(
            padding: widget.iconPadding,
            decoration: BoxDecoration(
              color: widget.iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: widget.icon,
          );

    return Container(
      constraints: widget.height == null
          ? null
          : BoxConstraints(minHeight: widget.height!),
      padding: widget.padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.gradient == null
            ? widget.backgroundColor ?? widget.color.withValues(alpha: 0.08)
            : null,
        gradient: widget.gradient,
        border: Border.all(
          color: widget.borderColor ?? widget.color,
          width: widget.borderWidth,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.boxShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          SizedBox(width: widget.leadingGap),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: widget.titleStyle ??
                      AppTextStyles.semiboldH8_16.copyWith(
                        color: AppColors.neutral950,
                      ),
                ),
                if (hasSubtitle) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    maxLines: widget.subtitleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: widget.subtitleStyle ??
                        AppTextStyles.regularB7_14.copyWith(
                          color: AppColors.neutral600,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.onClose != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: _handleDismiss,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: widget.closeIcon ??
                    const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.neutral600,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
