import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

/// Shared dimensions used by every in-page screen header.
abstract final class AppScreenHeaderMetrics {
  static const double height = 45;
  static const double topInset = 0;
  static const double horizontalInset = 20;
  static const double iconSize = 24;
  static const double actionSize = 45;
}

/// A fixed-height header that prevents title and action alignment from
/// changing while navigating between screens.
class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppScreenHeaderMetrics.height,
      child: Row(
        children: [
          if (leading != null) ...[
            SizedBox(
              width: AppScreenHeaderMetrics.actionSize,
              height: AppScreenHeaderMetrics.actionSize,
              child: Center(child: leading),
            ),
            const SizedBox(width: 12),
          ],
          if (title != null || subtitle != null)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semiboldH6_20.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                  if (title != null && subtitle != null)
                    const SizedBox(height: 3),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                ],
              ),
            )
          else
            const Spacer(),
          if (actions.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < actions.length; index++) ...[
                  if (index > 0) const SizedBox(width: 8),
                  SizedBox(
                    width: AppScreenHeaderMetrics.actionSize,
                    height: AppScreenHeaderMetrics.actionSize,
                    child: Center(child: actions[index]),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
