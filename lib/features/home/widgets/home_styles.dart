import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

/// Shared Figma styles used by the independently composed home widgets.
abstract final class HomeStyles {
  static final TextStyle sectionTitle = AppTextStyles.semiboldH7_18.copyWith(
    color: AppColors.neutral950,
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1F111213),
    blurRadius: 2,
    offset: Offset(0, 5),
  );
}
