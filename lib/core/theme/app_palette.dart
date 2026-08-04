import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Dynamic theme palette mapping mode-independent shade names to values,
/// along with semantic layout tokens for backwards compatibility.
class AppPalette {
  // ── Semantic Tokens ───────────────────────────────────────────────
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color tertiary;
  final Color onTertiary;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceContainer;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color border;
  final Color divider;
  final Color success;
  final Color successLight;
  final Color error;
  final Color warning;
  final Color warningLight;
  final Color info;
  final Color infoLight;
  final Color shadow;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color disabled;

  // ── Raw Shade Properties ──────────────────────────────────────────
  final Color backgroundColor;

  final Color primary950;
  final Color primary900;
  final Color primary800;
  final Color primary700;
  final Color primary600;
  final Color primary500;
  final Color primary400;
  final Color primary300;
  final Color primary200;
  final Color primary100;
  final Color primary50;

  final Color secondary950;
  final Color secondary900;
  final Color secondary800;
  final Color secondary700;
  final Color secondary600;
  final Color secondary500;
  final Color secondary400;
  final Color secondary300;
  final Color secondary200;
  final Color secondary100;
  final Color secondary50;

  final Color cool950;
  final Color cool900;
  final Color cool800;
  final Color cool700;
  final Color cool600;
  final Color cool500;
  final Color cool400;
  final Color cool300;
  final Color cool200;
  final Color cool100;
  final Color cool50;

  final Color neutral950;
  final Color neutral900;
  final Color neutral800;
  final Color neutral700;
  final Color neutral600;
  final Color neutral500;
  final Color neutral400;
  final Color neutral300;
  final Color neutral200;
  final Color neutral100;
  final Color neutral50;

  final Color red600;
  final Color red500;
  final Color red400;
  final Color red300;
  final Color red200;
  final Color red100;

  final Color yellow600;
  final Color yellow400;
  final Color yellow300;
  final Color yellow200;
  final Color yellow100;
  final Color yellow50;

  final Color green700;
  final Color green600;
  final Color green500;
  final Color green400;
  final Color green300;
  final Color green200;
  final Color green100;

  final Color orchid;
  final Color orchidLight;
  final Color purple;
  final Color purpleLight;
  final Color orange;
  final Color orangeLight;

  const AppPalette({
    // Semantic
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.tertiary,
    required this.onTertiary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.border,
    required this.divider,
    required this.success,
    required this.successLight,
    required this.error,
    required this.warning,
    required this.warningLight,
    required this.info,
    required this.infoLight,
    required this.shadow,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.disabled,
    // Shades
    required this.backgroundColor,
    required this.primary950,
    required this.primary900,
    required this.primary800,
    required this.primary700,
    required this.primary600,
    required this.primary500,
    required this.primary400,
    required this.primary300,
    required this.primary200,
    required this.primary100,
    required this.primary50,
    required this.secondary950,
    required this.secondary900,
    required this.secondary800,
    required this.secondary700,
    required this.secondary600,
    required this.secondary500,
    required this.secondary400,
    required this.secondary300,
    required this.secondary200,
    required this.secondary100,
    required this.secondary50,
    required this.cool950,
    required this.cool900,
    required this.cool800,
    required this.cool700,
    required this.cool600,
    required this.cool500,
    required this.cool400,
    required this.cool300,
    required this.cool200,
    required this.cool100,
    required this.cool50,
    required this.neutral950,
    required this.neutral900,
    required this.neutral800,
    required this.neutral700,
    required this.neutral600,
    required this.neutral500,
    required this.neutral400,
    required this.neutral300,
    required this.neutral200,
    required this.neutral100,
    required this.neutral50,
    required this.red600,
    required this.red500,
    required this.red400,
    required this.red300,
    required this.red200,
    required this.red100,
    required this.yellow600,
    required this.yellow400,
    required this.yellow300,
    required this.yellow200,
    required this.yellow100,
    required this.yellow50,
    required this.green700,
    required this.green600,
    required this.green500,
    required this.green400,
    required this.green300,
    required this.green200,
    required this.green100,
    required this.orchid,
    required this.orchidLight,
    required this.purple,
    required this.purpleLight,
    required this.orange,
    required this.orangeLight,
  });

  static const AppPalette light = AppPalette(
    // Semantic
    primary: AppColors.primary500,
    onPrimary: AppColors.neutral50,
    secondary: AppColors.primary50,
    onSecondary: AppColors.primary900,
    tertiary: AppColors.primary700,
    onTertiary: AppColors.neutral50,
    background: AppColors.backgroundColor,
    surface: AppColors.neutral50,
    surfaceVariant: AppColors.neutral100,
    surfaceContainer: AppColors.neutral50,
    textPrimary: AppColors.neutral900,
    textSecondary: AppColors.neutral600,
    textDisabled: AppColors.neutral300,
    border: AppColors.neutral200,
    divider: AppColors.neutral100,
    success: AppColors.green500,
    successLight: AppColors.green100,
    error: AppColors.red500,
    warning: AppColors.yellow400,
    warningLight: AppColors.yellow50,
    info: AppColors.secondary500,
    infoLight: AppColors.secondary100,
    shadow: Color(0x0F000000),
    shimmerBase: AppColors.neutral200,
    shimmerHighlight: AppColors.neutral100,
    disabled: AppColors.neutral300,
    // Shades
    backgroundColor: AppColors.backgroundColor,
    primary950: AppColors.primary950,
    primary900: AppColors.primary900,
    primary800: AppColors.primary800,
    primary700: AppColors.primary700,
    primary600: AppColors.primary600,
    primary500: AppColors.primary500,
    primary400: AppColors.primary400,
    primary300: AppColors.primary300,
    primary200: AppColors.primary200,
    primary100: AppColors.primary100,
    primary50: AppColors.primary50,
    secondary950: AppColors.secondary950,
    secondary900: AppColors.secondary900,
    secondary800: AppColors.secondary800,
    secondary700: AppColors.secondary700,
    secondary600: AppColors.secondary600,
    secondary500: AppColors.secondary500,
    secondary400: AppColors.secondary400,
    secondary300: AppColors.secondary300,
    secondary200: AppColors.secondary200,
    secondary100: AppColors.secondary100,
    secondary50: AppColors.secondary50,
    cool950: AppColors.cool950,
    cool900: AppColors.cool900,
    cool800: AppColors.cool800,
    cool700: AppColors.cool700,
    cool600: AppColors.cool600,
    cool500: AppColors.cool500,
    cool400: AppColors.cool400,
    cool300: AppColors.cool300,
    cool200: AppColors.cool200,
    cool100: AppColors.cool100,
    cool50: AppColors.cool50,
    neutral950: AppColors.neutral950,
    neutral900: AppColors.neutral900,
    neutral800: AppColors.neutral800,
    neutral700: AppColors.neutral700,
    neutral600: AppColors.neutral600,
    neutral500: AppColors.neutral500,
    neutral400: AppColors.neutral400,
    neutral300: AppColors.neutral300,
    neutral200: AppColors.neutral200,
    neutral100: AppColors.neutral100,
    neutral50: AppColors.neutral50,
    red600: AppColors.red600,
    red500: AppColors.red500,
    red400: AppColors.red400,
    red300: AppColors.red300,
    red200: AppColors.red200,
    red100: AppColors.red100,
    yellow600: AppColors.yellow600,
    yellow400: AppColors.yellow400,
    yellow300: AppColors.yellow300,
    yellow200: AppColors.yellow200,
    yellow100: AppColors.yellow100,
    yellow50: AppColors.yellow50,
    green700: AppColors.green700,
    green600: AppColors.green600,
    green500: AppColors.green500,
    green400: AppColors.green400,
    green300: AppColors.green300,
    green200: AppColors.green200,
    green100: AppColors.green100,
    orchid: AppColors.orchid,
    orchidLight: AppColors.orchidLight,
    purple: AppColors.purple,
    purpleLight: AppColors.purpleLight,
    orange: AppColors.orange,
    orangeLight: AppColors.orangeLight,
  );

  static final AppPalette dark = AppPalette(
    // Semantic
    primary: AppColors.primary400,
    onPrimary: AppColors.primary950,
    secondary: AppColors.primary900,
    onSecondary: AppColors.primary200,
    tertiary: AppColors.primary300,
    onTertiary: AppColors.primary950,
    background: AppColors.backgroundColorDark,
    surface: AppColors.neutral900,
    surfaceVariant: AppColors.neutral800,
    surfaceContainer: AppColors.neutral800,
    textPrimary: AppColors.neutral200,
    textSecondary: AppColors.neutral400,
    textDisabled: AppColors.neutral600,
    border: AppColors.neutral700,
    divider: AppColors.neutral800,
    success: AppColors.green400,
    successLight: AppColors.green700,
    error: AppColors.red400,
    warning: AppColors.yellow400,
    warningLight: AppColors.yellow50,
    info: AppColors.secondary400,
    infoLight: AppColors.secondary900,
    shadow: const Color(0x40000000),
    shimmerBase: AppColors.neutral800,
    shimmerHighlight: AppColors.neutral700,
    disabled: AppColors.neutral600,
    // Shades
    backgroundColor: AppColors.backgroundColorDark,
    primary950: AppColors.primary100,
    primary900: AppColors.primary200,
    primary800: AppColors.primary300,
    primary700: AppColors.primary400,
    primary600: AppColors.primary500,
    primary500: AppColors.primary400,
    primary400: AppColors.primary300,
    primary300: AppColors.primary200,
    primary200: AppColors.primary900,
    primary100: AppColors.primary950,
    primary50: AppColors.primary950,
    secondary950: AppColors.secondary100,
    secondary900: AppColors.secondary200,
    secondary800: AppColors.secondary300,
    secondary700: AppColors.secondary400,
    secondary600: AppColors.secondary500,
    secondary500: AppColors.secondary400,
    secondary400: AppColors.secondary300,
    secondary300: AppColors.secondary200,
    secondary200: AppColors.secondary900,
    secondary100: AppColors.secondary950,
    secondary50: AppColors.secondary950,
    cool950: AppColors.cool100,
    cool900: AppColors.cool200,
    cool800: AppColors.cool300,
    cool700: AppColors.cool400,
    cool600: AppColors.cool500,
    cool500: AppColors.cool400,
    cool400: AppColors.cool300,
    cool300: AppColors.cool200,
    cool200: AppColors.cool900,
    cool100: AppColors.cool950,
    cool50: AppColors.cool950,
    neutral950: AppColors.neutral100,
    neutral900: AppColors.neutral200,
    neutral800: AppColors.neutral300,
    neutral700: AppColors.neutral400,
    neutral600: AppColors.neutral500,
    neutral500: AppColors.neutral400,
    neutral400: AppColors.neutral300,
    neutral300: AppColors.neutral200,
    neutral200: AppColors.neutral900,
    neutral100: AppColors.neutral950,
    neutral50: AppColors.neutral950,
    red600: AppColors.red600,
    red500: AppColors.red500,
    red400: AppColors.red400,
    red300: AppColors.red300,
    red200: AppColors.red200,
    red100: AppColors.red100,
    yellow600: AppColors.yellow600,
    yellow400: AppColors.yellow400,
    yellow300: AppColors.yellow300,
    yellow200: AppColors.yellow200,
    yellow100: AppColors.yellow100,
    yellow50: AppColors.yellow50,
    green700: AppColors.green700,
    green600: AppColors.green600,
    green500: AppColors.green500,
    green400: AppColors.green400,
    green300: AppColors.green300,
    green200: AppColors.green200,
    green100: AppColors.green100,
    orchid: AppColors.orchid,
    orchidLight: AppColors.orchidLight,
    purple: AppColors.purple,
    purpleLight: AppColors.purpleLight,
    orange: AppColors.orange,
    orangeLight: AppColors.orangeLight,
  );
}
