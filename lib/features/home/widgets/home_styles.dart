import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

/// Shared Figma styles used by the independently composed home widgets.
abstract final class HomeStyles {
  static final TextStyle sectionTitle = AppTextStyles.semiboldH7_18.copyWith(
    color: AppColors.neutral950,
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: AppColors.neutral950.withValues(alpha: 0.12),
    blurRadius: 5,
    offset: const Offset(0, 2),
  );
}
