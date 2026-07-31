import 'package:flutter/material.dart';

/// Centralized color palette for the EcoVision App.
///
/// All colors used across the application are defined here.
/// This makes it trivial to re-skin the app or tweak individual
/// shades without hunting through widget files.
class AppColors {
  AppColors._();

  // ══════════════════════════════════════════════════════════════════
  //  BRAND / PRIMARY — EcoVision Green
  // ══════════════════════════════════════════════════════════════════

  static const Color primaryLight = Color(0xFF34C759);
  static const Color primaryDark = Color(0xFF4ADE6F);

  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF003D14);

  // ── Secondary ─────────────────────────────────────────────────────

  static const Color secondaryLight = Color(0xFFEAF8EE);
  static const Color secondaryDark = Color(0xFF1A3D24);

  static const Color onSecondaryLight = Color(0xFF1B5E2E);
  static const Color onSecondaryDark = Color(0xFFB8E6C8);

  // ── Tertiary ──────────────────────────────────────────────────────

  static const Color tertiaryLight = Color(0xFF2D8E47);
  static const Color tertiaryDark = Color(0xFF6AD87E);

  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color onTertiaryDark = Color(0xFF003D14);

  // ══════════════════════════════════════════════════════════════════
  //  SURFACES & BACKGROUNDS
  // ══════════════════════════════════════════════════════════════════

  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static const Color surfaceVariantLight = Color(0xFFF5F7F6);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  static const Color surfaceContainerLight = Color(0xFFF8FAF9);
  static const Color surfaceContainerDark = Color(0xFF252525);

  // ══════════════════════════════════════════════════════════════════
  //  TEXT
  // ══════════════════════════════════════════════════════════════════

  static const Color textPrimaryLight = Color(0xFF222222);
  static const Color textPrimaryDark = Color(0xFFE8E8E8);

  static const Color textSecondaryLight = Color(0xFF7A7A7A);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);

  static const Color textDisabledLight = Color(0xFFCFCFCF);
  static const Color textDisabledDark = Color(0xFF555555);

  // ══════════════════════════════════════════════════════════════════
  //  BORDERS & DIVIDERS
  // ══════════════════════════════════════════════════════════════════

  static const Color borderLight = Color(0xFFE6E6E6);
  static const Color borderDark = Color(0xFF3A3A3A);

  static const Color dividerLight = Color(0xFFF0F0F0);
  static const Color dividerDark = Color(0xFF2A2A2A);

  // ══════════════════════════════════════════════════════════════════
  //  STATUS / SEMANTIC
  // ══════════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF34C759);
  static const Color successLight = Color(0xFFEAF8EE);
  static const Color successDark = Color(0xFF4ADE6F);

  static const Color error = Color(0xFFFF4D4F);
  static const Color errorLight = Color(0xFFFFF0F0);
  static const Color errorDark = Color(0xFFFF6B6D);

  static const Color warning = Color(0xFFF5A623);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color warningDark = Color(0xFFFFCA28);

  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color infoDark = Color(0xFF42A5F5);

  // ══════════════════════════════════════════════════════════════════
  //  MISCELLANEOUS
  // ══════════════════════════════════════════════════════════════════

  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowDark = Color(0x40000000);

  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF303030);
  static const Color shimmerHighlightDark = Color(0xFF424242);

  /// Disabled button / input color.
  static const Color disabled = Color(0xFFCFCFCF);

  // ══════════════════════════════════════════════════════════════════
  //  COLOR SCHEME BUILDERS
  // ══════════════════════════════════════════════════════════════════

  /// Light [ColorScheme] built from the palette above.
  static ColorScheme get lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: primaryLight,
        onPrimary: onPrimaryLight,
        secondary: secondaryLight,
        onSecondary: onSecondaryLight,
        tertiary: tertiaryLight,
        onTertiary: onTertiaryLight,
        error: error,
        onError: Colors.white,
        surface: surfaceLight,
        onSurface: textPrimaryLight,
        surfaceContainerHighest: surfaceVariantLight,
        onSurfaceVariant: textSecondaryLight,
        outline: borderLight,
        outlineVariant: dividerLight,
        shadow: shadowLight,
      );

  /// Dark [ColorScheme] built from the palette above.
  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryDark,
        onPrimary: onPrimaryDark,
        secondary: secondaryDark,
        onSecondary: onSecondaryDark,
        tertiary: tertiaryDark,
        onTertiary: onTertiaryDark,
        error: errorDark,
        onError: Colors.black,
        surface: surfaceDark,
        onSurface: textPrimaryDark,
        surfaceContainerHighest: surfaceVariantDark,
        onSurfaceVariant: textSecondaryDark,
        outline: borderDark,
        outlineVariant: dividerDark,
        shadow: shadowDark,
      );
}
