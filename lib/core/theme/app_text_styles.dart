import 'package:flutter/material.dart';

/// Reusable text style tokens for the EERL App, with sizes appended to the name.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Manrope';

  // ══════════════════════════════════════════════════════════════════
  //  BOLD SHADES (H1_40 - H9_12)
  // ══════════════════════════════════════════════════════════════════

  static const TextStyle boldH1_40 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 44 / 40,
  );

  static const TextStyle boldH2_36 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 40 / 36,
  );

  static const TextStyle boldH3_32 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 36 / 32,
  );

  static const TextStyle boldH4_28 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 32 / 28,
  );

  static const TextStyle boldH5_24 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 28 / 24,
  );

  static const TextStyle boldH6_20 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 24 / 20,
  );

  static const TextStyle boldH7_16 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 20 / 16,
  );

  static const TextStyle boldH8_14 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 18 / 14,
  );

  static const TextStyle boldH9_12 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
  );

  // ══════════════════════════════════════════════════════════════════
  //  SEMIBOLD SHADES (H1_40 - H10_12)
  // ══════════════════════════════════════════════════════════════════

  static const TextStyle semiboldH1_40 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 44 / 40,
  );

  static const TextStyle semiboldH2_36 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 42 / 36,
  );

  static const TextStyle semiboldH3_32 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 36 / 32,
  );

  static const TextStyle semiboldH4_28 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 32 / 28,
  );

  static const TextStyle semiboldH5_24 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 28 / 24,
  );

  static const TextStyle semiboldH6_20 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 24 / 20,
  );

  static const TextStyle semiboldH7_18 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 22 / 18,
  );

  static const TextStyle semiboldH8_16 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
  );

  static const TextStyle semiboldH9_14 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 18 / 14,
  );

  static const TextStyle semiboldH10_12 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
  );

  // ══════════════════════════════════════════════════════════════════
  //  MEDIUM SHADES (SH1_40 - SH9_12)
  // ══════════════════════════════════════════════════════════════════

  static const TextStyle mediumSH1_40 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w500,
    height: 44 / 40,
  );

  static const TextStyle mediumSH2_36 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w500,
    height: 40 / 36,
  );

  static const TextStyle mediumSH3_32 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 36 / 32,
  );

  static const TextStyle mediumSH4_28 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 32 / 28,
  );

  static const TextStyle mediumSH5_24 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 28 / 24,
  );

  static const TextStyle mediumSH6_20 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 24 / 20,
  );

  static const TextStyle mediumSH6_18 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 22 / 18,
  );

  static const TextStyle mediumSH7_16 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 20 / 16,
  );

  static const TextStyle mediumSH8_14 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 18 / 14,
  );

  static const TextStyle mediumSH9_12 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
  );

  // ══════════════════════════════════════════════════════════════════
  //  REGULAR SHADES (B1_40 - B8_12)
  // ══════════════════════════════════════════════════════════════════

  static const TextStyle regularB1_40 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w400,
    height: 44 / 40,
  );

  static const TextStyle regularB2_36 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 40 / 36,
  );

  static const TextStyle regularB3_32 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 36 / 32,
  );

  static const TextStyle regularB4_28 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 32 / 28,
  );

  static const TextStyle regularB5_24 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 28 / 24,
  );

  static const TextStyle regularB6_20 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 24 / 20,
  );

  static const TextStyle regularB6_18 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 22 / 18,
  );

  static const TextStyle regularB7_16 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 20 / 16,
  );

  static const TextStyle regularB7_14 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 22 / 14,
  );

  static const TextStyle regularB8_12 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
  );

  // ══════════════════════════════════════════════════════════════════
  //  COMPATIBILITY PROPERTIES MAPPED TO NEW CUSTOM DESIGN SYSTEM
  // ══════════════════════════════════════════════════════════════════

  static const TextStyle displayLarge = boldH1_40;
  static const TextStyle displayMedium = boldH2_36;
  static const TextStyle displaySmall = boldH3_32;

  static const TextStyle headlineLarge = semiboldH4_28;
  static const TextStyle headlineMedium = semiboldH5_24;
  static const TextStyle headlineSmall = semiboldH6_20;

  static const TextStyle titleLarge = mediumSH7_16;
  static const TextStyle titleMedium = mediumSH8_14;
  static const TextStyle titleSmall = mediumSH9_12;

  static const TextStyle bodyLarge = regularB7_16;
  static const TextStyle bodyMedium = regularB7_14;
  static const TextStyle bodySmall = regularB8_12;

  static const TextStyle labelLarge = mediumSH8_14;
  static const TextStyle labelMedium = mediumSH9_12;
  static const TextStyle labelSmall = regularB8_12;

  /// Build a complete [TextTheme] from the tokens above.
  static TextTheme get textTheme => const TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
