import 'package:flutter/material.dart';

/// Pickup Supervisor aliases for the host application's `AppColors` tokens.
///
/// Keep the shared tokens in this class synchronized with
/// `lib/core/theme/app_colors.dart`. The feature module cannot import the host
/// application directly, so the values are mirrored here to keep the module
/// independently buildable.
abstract final class DriverColors {
  // Background colors.
  static const Color backgroundColor = Color(0xFFFAFAF8);
  static const Color backgroundColorDark = Color(0xFF121212);

  // Primary colors.
  static const Color primary950 = Color(0xFF0B2812);
  static const Color primary900 = Color(0xFF1D4A28);
  static const Color primary800 = Color(0xFF215A2D);
  static const Color primary700 = Color(0xFF247134);
  static const Color primary600 = Color(0xFF2E9E45);
  static const Color primary500 = Color(0xFF39AE51);
  static const Color primary400 = Color(0xFF5FC974);
  static const Color primary300 = Color(0xFF95E0A4);
  static const Color primary200 = Color(0xFFC3EFCB);
  static const Color primary100 = Color(0xFFE0F8E4);
  static const Color primary50 = Color(0xFFF2FBF3);
  static const Color walletGradientStart = Color(0xFF48A35A);
  static const Color walletGradientEnd = Color(0xFF001832);

  // Secondary colors.
  static const Color secondary950 = Color(0xFF13243E);
  static const Color secondary900 = Color(0xFF1E3A5F);
  static const Color secondary800 = Color(0xFF1D426F);
  static const Color secondary700 = Color(0xFF1F4C85);
  static const Color secondary600 = Color(0xFF255FA4);
  static const Color secondary500 = Color(0xFF357AC2);
  static const Color secondary400 = Color(0xFF5A97D6);
  static const Color secondary300 = Color(0xFF93BAE6);
  static const Color secondary200 = Color(0xFFC6DAF1);
  static const Color secondary100 = Color(0xFFE5EDF9);
  static const Color secondary50 = Color(0xFFF3F7FC);

  // Cool colors.
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

  // Neutral colors.
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

  // Red shades.
  static const Color red600 = Color(0xFFE22424);
  static const Color red500 = Color(0xFFF43F3F);
  static const Color red400 = Color(0xFFFC6D6D);
  static const Color red300 = Color(0xFFFFA2A2);
  static const Color red200 = Color(0xFFFFC8C8);
  static const Color red100 = Color(0xFFFFE1E1);
  static const Color red50 = Color(0xFFFEF2F2);

  // Yellow shades.
  static const Color yellow600 = Color(0xFFF9AE00);
  static const Color yellow400 = Color(0xFFFFBF29);
  static const Color yellow300 = Color(0xFFFFD14A);
  static const Color yellow200 = Color(0xFFFFE588);
  static const Color yellow100 = Color(0xFFFFF2C6);
  static const Color yellow50 = Color(0xFFFFFBEB);

  // Green shades.
  static const Color green700 = Color(0xFF028D3D);
  static const Color green600 = Color(0xFF00BC4F);
  static const Color green500 = Color(0xFF05E262);
  static const Color green400 = Color(0xFF30F883);
  static const Color green300 = Color(0xFF73FFAD);
  static const Color green200 = Color(0xFFB0FFD0);
  static const Color green100 = Color(0xFFD6FFE6);

  // Icon colors.
  static const Color orchid = Color(0xFFCB5ED5);
  static const Color orchidLight = Color(0xFFFFE4FF);
  static const Color purple = Color(0xFF6644DD);
  static const Color purpleLight = Color(0xFFE4E3F3);
  static const Color orange = Color(0xFFFF7B33);
  static const Color orangeLight = Color(0xFFFFE9E3);

  // Semantic colors mirrored from AppColors/AppPalette.
  static Color get primaryLight => primary500;
  static Color get primaryDark => primary400;
  static Color get onPrimaryLight => neutral50;
  static Color get onPrimaryDark => primary950;
  static Color get secondaryLight => primary50;
  static Color get secondaryDark => primary900;
  static Color get onSecondaryLight => primary900;
  static Color get onSecondaryDark => primary200;
  static Color get tertiaryLight => primary700;
  static Color get tertiaryDark => primary300;
  static Color get onTertiaryLight => neutral50;
  static Color get onTertiaryDark => primary950;
  static Color get backgroundLight => backgroundColor;
  static Color get backgroundDark => backgroundColorDark;
  static Color get surfaceLight => neutral50;
  static Color get surfaceDark => neutral900;
  static Color get surfaceVariantLight => neutral100;
  static Color get surfaceVariantDark => neutral800;
  static Color get surfaceContainerLight => neutral50;
  static Color get surfaceContainerDark => neutral800;
  static Color get textPrimaryLight => neutral900;
  static Color get textPrimaryDark => neutral200;
  static Color get textSecondaryLight => neutral600;
  static Color get textSecondaryDark => neutral400;
  static Color get textDisabledLight => neutral300;
  static Color get textDisabledDark => neutral600;
  static Color get borderLight => neutral200;
  static Color get borderDark => neutral700;
  static Color get dividerLight => neutral100;
  static Color get dividerDark => neutral800;
  static Color get success => green500;
  static Color get successLight => green100;
  static Color get successDark => green400;
  static Color get error => red500;
  static Color get errorDark => red500;
  static Color get warning => yellow400;
  static Color get warningLight => yellow50;
  static Color get warningDark => yellow400;
  static Color get info => secondary500;
  static Color get infoLight => secondary100;
  static Color get infoDark => secondary400;
  static Color get shadowLight => const Color(0x0F000000);
  static Color get shadowDark => const Color(0x40000000);
  static Color get shimmerBaseLight => neutral200;
  static Color get shimmerHighlightLight => neutral100;
  static Color get shimmerBaseDark => neutral800;
  static Color get shimmerHighlightDark => neutral700;
  static Color get disabled => neutral300;

  static ColorScheme get lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary500,
    onPrimary: neutral50,
    secondary: primary50,
    onSecondary: primary900,
    tertiary: primary700,
    onTertiary: neutral50,
    error: red500,
    onError: Colors.white,
    surface: neutral50,
    onSurface: neutral900,
    surfaceContainerHighest: neutral100,
    onSurfaceVariant: neutral600,
    outline: neutral200,
    outlineVariant: neutral100,
    shadow: Color(0x0F000000),
  );

  static ColorScheme get darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: primary400,
    onPrimary: primary950,
    secondary: primary900,
    onSecondary: primary200,
    tertiary: primary300,
    onTertiary: primary950,
    error: red500,
    onError: Colors.black,
    surface: neutral900,
    onSurface: neutral200,
    surfaceContainerHighest: neutral800,
    onSurfaceVariant: neutral400,
    outline: neutral700,
    outlineVariant: neutral800,
    shadow: Color(0x40000000),
  );

  // Existing module aliases retained for backwards compatibility.
  static const Color background = backgroundColor;
  static const Color surface = neutral50;
  static const Color purple600 = Color(0xFF7A3FD1);
  static const Color purple50 = Color(0xFFF1EAFC);
  static const Color slate50 = Color(0xFFEEF1F4);
  static const Color slate600 = Color(0xFF5B6470);
  static const Color ink900 = Color(0xFF1F2933);
  static const Color mapBackground = Color(0xFFE7EEE9);
  static const Color stopZeroBackground = Color(0xFFF6F7F9);
  static const Color stopZeroBorder = Color(0xFFCFD6DC);
  static const Color stopCancelledBackground = Color(0xFFFAF7FF);
  static const Color stopCancelledBorder = Color(0xFFD9C8F4);
  static const Color stopInactiveBackground = Color(0xFFF1F3F5);
  static const Color stopInactiveBorder = Color(0xFFDDE2E6);
  static const Color yellow700 = Color(0xFFE09A00);
  static const Color amber800 = Color(0xFFB26A00);
  static const Color sheetHandle = Color(0xFFCFD6DC);
  static const Color mutedText = Color(0xFF828282);
  static const Color pdfViewer = Color(0xFFE5E9EC);
  static const Color pdfLine = Color(0xFFE3E5E8);
  static const Color pdfMuted = Color(0xFF5C5E63);
  static const Color missedCard = Color(0xFFFFF6F6);
  static const Color missedCardBorder = Color(0xFFF2B8B8);
  static const Color cancelledCard = Color(0xFFFAF7FE);
  static const Color cancelledCardBorder = Color(0xFFE4D8F7);
  static const Color zeroKgCardBorder = Color(0xFFE3E7EC);
  static const Color escalatedBg = Color(0xFFFFF4E0);
  static const Color escalatedText = Color(0xFFC77800);
  static const Color escalatedBorder = Color(0xFFEDA833);
  static const Color resolvedText = Color(0xFF238B3D);
  static const Color tagGrey = Color(0xFFEDF0F2);
  static const Color infoBannerBg = Color(0xFFFFF8E6);
  static const Color infoBannerBorder = Color(0xFFF5D48A);
  static const Color infoBannerText = Color(0xFF5D4300);
  static const Color blue600 = Color(0xFF2F6FDB);
  static const Color pink600 = Color(0xFFC2185B);
  static const Color pink100 = Color(0xFFFDE8F1);
  static const Color border = Color(0xFFD5DDE2);
  static const Color navigation = primary900;
  static const Color summaryBorder = Color(0xFFCFEED6);
  static const Color tripDetails = Color(0xFFF3F6F8);
  static const Color shadow = Color(0x1F000000);
}
