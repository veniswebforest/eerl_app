import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// EcoVision logo component used across splash and auth screens.
///
/// Renders the "ECO VISION" branded logo with the leaf icon
/// and optional subtitle text.
class LogoComponent extends StatelessWidget {
  const LogoComponent({
    super.key,
    this.size = LogoSize.medium,
    this.showSubtitle = true,
  });

  final LogoSize size;
  final bool showSubtitle;

  double get _iconSize {
    switch (size) {
      case LogoSize.small:
        return 32;
      case LogoSize.medium:
        return 48;
      case LogoSize.large:
        return 72;
    }
  }

  double get _titleSize {
    switch (size) {
      case LogoSize.small:
        return 20;
      case LogoSize.medium:
        return 28;
      case LogoSize.large:
        return 42;
    }
  }

  double get _subtitleSize {
    switch (size) {
      case LogoSize.small:
        return 7;
      case LogoSize.medium:
        return 9;
      case LogoSize.large:
        return 12;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Logo Mark ──────────────────────────────────────────────
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ECO',
              style: TextStyle(
                fontSize: _titleSize,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                letterSpacing: 2,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                Icons.eco,
                size: _iconSize * 0.7,
                color: AppColors.primaryLight,
              ),
            ),
            Text(
              'VISION',
              style: TextStyle(
                fontSize: _titleSize,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryLight,
                letterSpacing: 2,
                height: 1,
              ),
            ),
          ],
        ),

        // ── Subtitle ──────────────────────────────────────────────
        if (showSubtitle) ...[
          SizedBox(height: size == LogoSize.large ? 8 : 4),
          Text(
            'PLASTIC WASTE MANAGEMENT',
            style: TextStyle(
              fontSize: _subtitleSize,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              letterSpacing: 3,
            ),
          ),
        ],
      ],
    );
  }
}

enum LogoSize { small, medium, large }
