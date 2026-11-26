import 'package:flutter/services.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// What a text field holds: decides its keyboard, capitalisation and
/// input filter, so every form of the module types the same way.
enum ModuleInputKind {
  /// Free text on one line (route name, reference).
  text,

  /// A person's name: words capitalised.
  name,

  /// Indian mobile number: 10 digits.
  phone,

  /// Whole numbers (capacity in kg, counts).
  integer,

  /// Decimal numbers, up to [ModuleInputRules.decimals] places (weights).
  decimal,

  /// Rupees in whole numbers, commas allowed ("1,250").
  rupees,

  /// Aadhaar (12 digits) or Voter ID (letters and digits).
  idNumber,

  /// Vehicle registration ("GJ-05-EE-1002"): capitals.
  vehicle,

  /// Notes, remarks, reasons: several lines.
  multiline,

  /// Search boxes: the keyboard shows Search.
  search,
}

/// Keyboard, capitalisation and formatters for each [ModuleInputKind].
abstract final class ModuleInputRules {
  static TextInputType keyboard(ModuleInputKind kind) => switch (kind) {
    ModuleInputKind.text || ModuleInputKind.search => TextInputType.text,
    ModuleInputKind.name => TextInputType.name,
    ModuleInputKind.phone => TextInputType.phone,
    ModuleInputKind.integer || ModuleInputKind.rupees => TextInputType.number,
    ModuleInputKind.decimal => const TextInputType.numberWithOptions(
      decimal: true,
    ),
    ModuleInputKind.idNumber ||
    ModuleInputKind.vehicle => TextInputType.visiblePassword,
    ModuleInputKind.multiline => TextInputType.multiline,
  };

  static TextCapitalization capitalization(ModuleInputKind kind) =>
      switch (kind) {
        ModuleInputKind.name => TextCapitalization.words,
        ModuleInputKind.vehicle ||
        ModuleInputKind.idNumber => TextCapitalization.characters,
        ModuleInputKind.multiline ||
        ModuleInputKind.text => TextCapitalization.sentences,
        _ => TextCapitalization.none,
      };

  /// Input filters; [decimals] applies to [ModuleInputKind.decimal].
  static List<TextInputFormatter> formatters(
    ModuleInputKind kind, {
    int decimals = 3,
  }) => switch (kind) {
    ModuleInputKind.phone => [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
      LengthLimitingTextInputFormatter(11),
    ],
    ModuleInputKind.integer => [FilteringTextInputFormatter.digitsOnly],
    ModuleInputKind.rupees => [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
      LengthLimitingTextInputFormatter(10),
    ],
    ModuleInputKind.decimal => [ModuleDecimalFormatter(decimals)],
    ModuleInputKind.idNumber => [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z ]')),
      LengthLimitingTextInputFormatter(14),
      const _UpperCaseFormatter(),
    ],
    ModuleInputKind.vehicle => [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z -]')),
      LengthLimitingTextInputFormatter(13),
      const _UpperCaseFormatter(),
    ],
    _ => const [],
  };
}

/// Digits with at most one dot and [decimals] digits after it.
class ModuleDecimalFormatter extends TextInputFormatter {
  const ModuleDecimalFormatter(this.decimals);

  final int decimals;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Drop letters and other characters first (pasted "40a" → "40").
    final cleaned = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (!RegExp('^\\d*\\.?\\d{0,$decimals}\$').hasMatch(cleaned)) {
      return oldValue;
    }
    if (cleaned == newValue.text) return newValue;
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  const _UpperCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

/// Shared validators. Each returns an error message, or null when valid.
/// Values are trimmed first, so spaces alone count as empty; an optional
/// field that is empty is always valid.
abstract final class ModuleValidators {
  static String _t(String? v) => (v ?? '').trim();

  static String? required(DriverLocalizations l10n, String? value) =>
      _t(value).isEmpty ? l10n.vlRequired : null;

  /// Full name: required, at least 2 characters.
  static String? fullName(DriverLocalizations l10n, String? value) {
    final v = _t(value);
    if (v.isEmpty) return l10n.addRouteFullNameRequired;
    if (v.length < 2) return l10n.addRouteFullNameMinLength;
    return null;
  }

  /// 10-digit Indian mobile starting with 6–9 (spaces ignored).
  static String? phone(
    DriverLocalizations l10n,
    String? value, {
    bool required = false,
  }) {
    final v = _t(value).replaceAll(' ', '');
    if (v.isEmpty) return required ? l10n.addRouteMobileRequired : null;
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) return l10n.addRouteMobileInvalid;
    return null;
  }

  /// Rupees ("1,250"): more than 0 and, if given, at most [max].
  static String? rupees(
    DriverLocalizations l10n,
    String? value, {
    bool required = false,
    int? max,
    String Function(int)? format,
  }) {
    final v = _t(value).replaceAll(',', '');
    if (v.isEmpty) return required ? l10n.vlRequired : null;
    final n = int.tryParse(v);
    if (n == null) return l10n.vlNumbersOnly;
    if (n <= 0) return l10n.vlAmountPositive;
    if (max != null && n > max) {
      return l10n.vlMaxAmount(format?.call(max) ?? '$max');
    }
    return null;
  }

  /// A decimal more than 0 with at most [decimals] places.
  static String? positiveDecimal(
    DriverLocalizations l10n,
    String? value, {
    bool required = false,
    int decimals = 3,
    String? positiveMessage,
  }) {
    final v = _t(value);
    if (v.isEmpty) return required ? l10n.vlRequired : null;
    final n = double.tryParse(v);
    if (n == null) return l10n.vlNumbersOnly;
    final places = v.contains('.') ? v.split('.').last.length : 0;
    if (places > decimals) return l10n.vlMaxDecimals(decimals);
    if (n <= 0) return positiveMessage ?? l10n.vlWeightPositive;
    return null;
  }

  /// A whole number more than 0 (capacity).
  static String? positiveInteger(
    DriverLocalizations l10n,
    String? value, {
    bool required = false,
    String? positiveMessage,
  }) {
    final v = _t(value);
    if (v.isEmpty) return required ? l10n.vlRequired : null;
    final n = int.tryParse(v);
    if (n == null) return l10n.vlNumbersOnly;
    if (n <= 0) return positiveMessage ?? l10n.vlAmountPositive;
    return null;
  }

  /// Aadhaar (12 digits, spaces allowed) or Voter ID (3 letters, 7 digits).
  static String? idNumber(DriverLocalizations l10n, String? value) {
    final v = _t(value).replaceAll(' ', '').toUpperCase();
    if (v.isEmpty) return null;
    final aadhaar = RegExp(r'^\d{12}$').hasMatch(v);
    final voter = RegExp(r'^[A-Z]{3}\d{7}$').hasMatch(v);
    return aadhaar || voter ? null : l10n.vlIdNumber;
  }

  /// Vehicle registration, e.g. GJ-05-EE-1002 or GJ05EE1002.
  static String? vehicleNumber(
    DriverLocalizations l10n,
    String? value, {
    bool required = false,
  }) {
    final v = _t(value).toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    if (v.isEmpty) return required ? l10n.vlRequired : null;
    final ok = RegExp(r'^[A-Z]{2}\d{1,2}[A-Z]{0,3}\d{4}$').hasMatch(v);
    return ok ? null : l10n.vlVehicleNumber;
  }
}
