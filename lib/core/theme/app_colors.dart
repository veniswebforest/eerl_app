import 'package:flutter/material.dart';
import 'app_palette.dart';

/// Proper color palette names matching design assets exactly.
class AppColors {
  AppColors._();

  // ── Background Color ──────────────────────────────────────────────
  static const Color backgroundColor = Color(0xFFFAFAF8);
  static const Color backgroundColorDark = Color(0xFF121212);

  // ── Primary Color ─────────────────────────────────────────────────
  static const Color primary950 = Color(0xFF0B2812);
  static const Color primary900 = Color(0xFF1D4A28);
  static const Color primary800 = Color(0xFF215A2D);
  static const Color primary700 = Color(0xFF247134);
  static const Color primary600 = Color(0xFF2E9E45);
  static const Color primary500 = Color(0xFF39AE51); // Main
  static const Color primary400 = Color(0xFF5FC974);
  static const Color primary300 = Color(0xFF95E0A4);
  static const Color primary200 = Color(0xFFC3EFCB);
  static const Color primary100 = Color(0xFFE0F8E4);
  static const Color primary50 = Color(0xFFF2FBF3);
  static const Color walletGradientStart = Color(0xFF48A35A);
  static const Color walletGradientEnd = Color(0xFF001832);

  // ── Secondary Color ───────────────────────────────────────────────
  static const Color secondary950 = Color(0xFF13243E);
  static const Color secondary900 = Color(0xFF1E3A5F);
  static const Color secondary800 = Color(0xFF1D426F);
  static const Color secondary700 = Color(0xFF1F4C85);
  static const Color secondary600 = Color(0xFF255FA4);
  static const Color secondary500 = Color(0xFF357AC2); // Secondary Color
  static const Color secondary400 = Color(0xFF5A97D6);
  static const Color secondary300 = Color(0xFF93BAE6);
  static const Color secondary200 = Color(0xFFC6DAF1);
  static const Color secondary100 = Color(0xFFE5EDF9);
  static const Color secondary50 = Color(0xFFF3F7FC);

  // ── Cool Color ────────────────────────────────────────────────────
  static const Color cool950 = Color(0xFF333B42);
  static const Color cool900 = Color(0xFF4E5864);
  static const Color cool800 = Color(0xFF5E6B79);
  static const Color cool700 = Color(0xFF718090);
  static const Color cool600 = Color(0xFF8494A3);
  static const Color cool500 = Color(0xFF92A3B0);
  static const Color cool400 = Color(0xFFB9C5CC);
  static const Color cool300 = Color(0xFFD3DBDF);
  static const Color cool200 = Color(0xFFE6EBEE);
  static const Color cool100 = Color(0xFFF2F5F5);
  static const Color cool50 = Color(0xFFF8FAFA);

  // ── Neutral Color ─────────────────────────────────────────────────

  static const Color neutral950 = Color(0xFF111213);
  static const Color neutral900 = Color(0xFF3D3D3D);
  static const Color neutral800 = Color(0xFF454545);
  static const Color neutral700 = Color(0xFF4F4F4F);
  static const Color neutral600 = Color(0xFF5D5D5D);
  static const Color neutral500 = Color(0xFF6D6D6D);
  static const Color neutral400 = Color(0xFF888888);
  static const Color neutral300 = Color(0xFFB0B0B0);
  static const Color neutral200 = Color(0xFFD1D1D1);
  static const Color neutral100 = Color(0xFFF6F6F6);
  static const Color neutral50 = Color(0xFFFFFFFF);

  // ── Red Shade ─────────────────────────────────────────────────────
  static const Color red600 = Color(0xFFE22424);
  static const Color red500 = Color(0xFFF43F3F);
  static const Color red400 = Color(0xFFFC6D6D);
  static const Color red300 = Color(0xFFFFA2A2);
  static const Color red200 = Color(0xFFFFC8C8);
  static const Color red100 = Color(0xFFFFE1E1);
  static const Color red50 = Color(0xFFFEF2F2);

  // ── Yellow Shade ──────────────────────────────────────────────────
  static const Color yellow600 = Color(0xFFF9AE00);
  static const Color yellow400 = Color(0xFFFFBF29);
  static const Color yellow300 = Color(0xFFFFD14A);
  static const Color yellow200 = Color(0xFFFFE588);
  static const Color yellow100 = Color(0xFFFFF2C6);
  static const Color yellow50 = Color(0xFFFFFBEB);

  // ── Green Shade ───────────────────────────────────────────────────
  static const Color green700 = Color(0xFF028D3D);
  static const Color green600 = Color(0xFF00BC4F);
  static const Color green500 = Color(0xFF05E262);
  static const Color green400 = Color(0xFF30F883);
  static const Color green300 = Color(0xFF73FFAD);
  static const Color green200 = Color(0xFFB0FFD0);
  static const Color green100 = Color(0xFFD6FFE6);

  // ── Icons Color ───────────────────────────────────────────────────
  static const Color orchid = Color(0xFFCB5ED5);
  static const Color orchidLight = Color(0xFFFFE4FF);
  static const Color purple = Color(0xFF6644DD);
  static const Color purpleLight = Color(0xFFE4E3F3);
  static const Color orange = Color(0xFFFF7B33);
  static const Color orangeLight = Color(0xFFFFE9E3);

  static Color get primaryLight => AppPalette.light.primary500;

  static Color get primaryDark => AppPalette.dark.primary500;

  static Color get onPrimaryLight => AppPalette.light.neutral50;

  static Color get onPrimaryDark => AppPalette.dark.primary950;

  static Color get secondaryLight => AppPalette.light.primary50;

  static Color get secondaryDark => AppPalette.dark.primary900;

  static Color get onSecondaryLight => AppPalette.light.primary900;

  static Color get onSecondaryDark => AppPalette.dark.primary200;

  static Color get tertiaryLight => AppPalette.light.primary700;

  static Color get tertiaryDark => AppPalette.dark.primary300;

  static Color get onTertiaryLight => AppPalette.light.neutral50;

  static Color get onTertiaryDark => AppPalette.dark.primary950;

  static Color get backgroundLight => AppPalette.light.backgroundColor;

  static Color get backgroundDark => AppPalette.dark.backgroundColor;

  static Color get surfaceLight => AppPalette.light.neutral50;

  static Color get surfaceDark => AppPalette.dark.neutral900;

  static Color get surfaceVariantLight => AppPalette.light.neutral100;

  static Color get surfaceVariantDark => AppPalette.dark.neutral800;

  static Color get surfaceContainerLight => AppPalette.light.neutral50;

  static Color get surfaceContainerDark => AppPalette.dark.neutral800;

  static Color get textPrimaryLight => AppPalette.light.neutral900;

  static Color get textPrimaryDark => AppPalette.dark.neutral200;

  static Color get textSecondaryLight => AppPalette.light.neutral600;

  static Color get textSecondaryDark => AppPalette.dark.neutral400;

  static Color get textDisabledLight => AppPalette.light.neutral300;

  static Color get textDisabledDark => AppPalette.dark.neutral600;

  static Color get borderLight => AppPalette.light.neutral200;

  static Color get borderDark => AppPalette.dark.neutral700;

  static Color get dividerLight => AppPalette.light.neutral100;

  static Color get dividerDark => AppPalette.dark.neutral800;

  static Color get success => AppPalette.light.green500;

  static Color get successLight => AppPalette.light.green100;

  static Color get successDark => AppPalette.dark.green500;

  static Color get error => AppPalette.light.red500;

  static Color get errorDark => AppPalette.dark.red500;

  static Color get warning => AppPalette.light.yellow400;

  static Color get warningLight => AppPalette.light.yellow50;

  static Color get warningDark => AppPalette.dark.yellow400;

  static Color get info => AppPalette.light.secondary500;

  static Color get infoLight => AppPalette.light.secondary100;

  static Color get infoDark => AppPalette.dark.secondary500;

  static Color get shadowLight => const Color(0x0F000000);

  static Color get shadowDark => const Color(0x40000000);

  static Color get shimmerBaseLight => AppPalette.light.neutral200;

  static Color get shimmerHighlightLight => AppPalette.light.neutral100;

  static Color get shimmerBaseDark => AppPalette.dark.neutral800;

  static Color get shimmerHighlightDark => AppPalette.dark.neutral700;

  static Color get disabled => AppPalette.light.neutral300;

  static ColorScheme get lightColorScheme => ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.light.primary500,
    onPrimary: AppPalette.light.neutral50,
    secondary: AppPalette.light.primary50,
    onSecondary: AppPalette.light.primary900,
    tertiary: AppPalette.light.primary700,
    onTertiary: AppPalette.light.neutral50,
    error: AppPalette.light.red500,
    onError: Colors.white,
    surface: AppPalette.light.neutral50,
    onSurface: AppPalette.light.neutral900,
    surfaceContainerHighest: AppPalette.light.neutral100,
    onSurfaceVariant: AppPalette.light.neutral600,
    outline: AppPalette.light.neutral200,
    outlineVariant: AppPalette.light.neutral100,
    shadow: const Color(0x0F000000),
  );

  static ColorScheme get darkColorScheme => ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.dark.primary500,
    onPrimary: AppPalette.dark.primary950,
    secondary: AppPalette.dark.primary900,
    onSecondary: AppPalette.dark.primary200,
    tertiary: AppPalette.dark.primary300,
    onTertiary: AppPalette.dark.primary950,
    error: AppPalette.dark.red500,
    onError: Colors.black,
    surface: AppPalette.dark.neutral900,
    onSurface: AppPalette.dark.neutral200,
    surfaceContainerHighest: AppPalette.dark.neutral800,
    onSurfaceVariant: AppPalette.dark.neutral400,
    outline: AppPalette.dark.neutral700,
    outlineVariant: AppPalette.dark.neutral800,
    shadow: const Color(0x40000000),
  );
}
