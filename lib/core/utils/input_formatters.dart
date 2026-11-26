import 'package:flutter/services.dart';

/// Keyboard presets shared by every form in the app.
///
/// Field limits follow "Validation rules (28 Oct 2026)" in
/// `docs/project-context/overall-requirements.md`.
abstract final class AppKeyboards {
  /// Rupee amounts, weights and other decimal values.
  static const decimal = TextInputType.numberWithOptions(decimal: true);

  /// Whole counts (bales, pieces) and other digit-only values.
  static const number = TextInputType.number;

  /// Indian mobile numbers.
  static const phone = TextInputType.phone;

  /// Remarks, notes and descriptions.
  static const multiline = TextInputType.multiline;
}

/// Shared field limits taken from the server's request schemas.
abstract final class AppInputLimits {
  /// Indian mobile number, without `+91`.
  static const mobileDigits = 10;

  /// Login code length.
  static const otpDigits = 6;

  /// Rupee amounts: at most 2 decimal places.
  static const moneyDecimals = 2;

  /// Quantities and weights: at most 3 decimal places.
  static const quantityDecimals = 3;

  /// Largest collection or transfer quantity (999,999.999).
  static const maxQuantity = 999999.999;

  /// Largest expense, cash request, transfer fee or estimated expense.
  static const maxWalletAmount = 9999999.0;

  /// Largest item rate (99,999,999.99).
  static const maxRate = 99999999.99;

  /// Largest bale count.
  static const maxBaleCount = 9999;

  /// Common text lengths.
  static const personName = 255;
  static const idNumber = 100;
  static const shortText = 255;
  static const longText = 1000;
  static const veryLongText = 2000;
  static const vehicleDriverName = 100;
}

/// Accepts only digits and an optional single decimal point with at most
/// [decimalPlaces] digits after it.
class DecimalTextInputFormatter extends TextInputFormatter {
  const DecimalTextInputFormatter({required this.decimalPlaces, this.maxValue})
    : assert(decimalPlaces >= 0);

  final int decimalPlaces;

  /// When set, edits that would exceed this value are rejected.
  final double? maxValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final pattern = decimalPlaces == 0
        ? RegExp(r'^\d*$')
        : RegExp('^\\d*\\.?\\d{0,$decimalPlaces}\$');
    if (!pattern.hasMatch(text)) return oldValue;
    final max = maxValue;
    if (max != null && text != '.') {
      final parsed = double.tryParse(text);
      if (parsed != null && parsed > max) return oldValue;
    }
    return newValue;
  }
}

/// Turns letters into capitals while typing, keeping the caret in place.
class UpperCaseTextInputFormatter extends TextInputFormatter {
  const UpperCaseTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

/// Ready-made formatter lists so screens do not repeat them.
abstract final class AppInputFormatters {
  /// 10-digit Indian mobile number.
  static final List<TextInputFormatter> mobile = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(AppInputLimits.mobileDigits),
  ];

  /// Rupees: digits with up to 2 decimals.
  static List<TextInputFormatter> money({double? maxValue}) => [
    DecimalTextInputFormatter(
      decimalPlaces: AppInputLimits.moneyDecimals,
      maxValue: maxValue,
    ),
  ];

  /// Weights / quantities: digits with up to 3 decimals.
  static List<TextInputFormatter> quantity({
    double maxValue = AppInputLimits.maxQuantity,
  }) => [
    DecimalTextInputFormatter(
      decimalPlaces: AppInputLimits.quantityDecimals,
      maxValue: maxValue,
    ),
  ];

  /// Whole numbers only, optionally limited to [maxLength] digits.
  static List<TextInputFormatter> digits({int? maxLength}) => [
    FilteringTextInputFormatter.digitsOnly,
    if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
  ];
}
