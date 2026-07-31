import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Convenience extensions on [BuildContext] for quick access to
/// theme, color scheme, text theme, localization, and brightness checks.
extension ContextExtensions on BuildContext {
  // ── Theme ──────────────────────────────────────────────────────────

  /// Current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Whether the current theme is dark.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ── Localization ───────────────────────────────────────────────────

  /// Shorthand for [AppLocalizations.of(context)].
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  // ── Media Query ────────────────────────────────────────────────────

  /// Screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Bottom padding (e.g. safe area).
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;
}
