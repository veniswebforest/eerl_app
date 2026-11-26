import 'package:eerl_app/core/utils/input_formatters.dart';
import 'package:eerl_app/core/utils/vehicle_registration_number.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';

/// Shared field validators.
///
/// Each returns `null` when the value is acceptable, or a localized message.
/// Lengths are counted after trimming, as the server does ("Validation rules
/// (28 Oct 2026)" in `docs/project-context/overall-requirements.md`).
/// Optional fields pass when empty and are only checked once filled.
abstract final class InputValidators {
  static final RegExp _indianMobile = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _otp = RegExp(r'^\d{6}$');

  /// Whether [value] is empty or whitespace only.
  static bool isBlank(String? value) => value == null || value.trim().isEmpty;

  /// Required check; whitespace-only counts as empty.
  static String? required(String? value, AppLocalizations l10n) =>
      isBlank(value) ? l10n.validationRequired : null;

  /// Free-text rule: required (optional), then trimmed length limits.
  static String? text(
    String? value,
    AppLocalizations l10n, {
    bool isRequired = false,
    int? minLength,
    int? maxLength,
    String? requiredMessage,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return isRequired ? (requiredMessage ?? l10n.validationRequired) : null;
    }
    if (minLength != null && trimmed.length < minLength) {
      return l10n.validationMinLength(minLength);
    }
    if (maxLength != null && trimmed.length > maxLength) {
      return l10n.validationMaxLength(maxLength);
    }
    return null;
  }

  /// Digits of an Indian mobile number, without spaces, dashes or `+91`.
  static String mobileDigits(String? value) {
    var digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    }
    return digits;
  }

  /// Whether [value] is a 10-digit Indian mobile number starting 6–9.
  static bool isValidMobile(String? value) =>
      _indianMobile.hasMatch(mobileDigits(value));

  /// Indian mobile: 10 digits starting 6–9.
  static String? mobile(
    String? value,
    AppLocalizations l10n, {
    bool isRequired = true,
  }) {
    if (isBlank(value)) return isRequired ? l10n.validationRequired : null;
    return isValidMobile(value) ? null : l10n.invalidMobileNumber;
  }

  /// Whether [value] is a 6-digit login code.
  static bool isValidOtp(String? value) => _otp.hasMatch(value?.trim() ?? '');

  /// Decimal number rule (money, weights, quantities).
  ///
  /// [allowZero] false means the value must be greater than 0.
  static String? decimal(
    String? value,
    AppLocalizations l10n, {
    bool isRequired = false,
    required int decimalPlaces,
    double? max,
    bool allowZero = false,
    String? requiredMessage,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return isRequired ? (requiredMessage ?? l10n.validationRequired) : null;
    }
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(trimmed) || trimmed == '.') {
      return l10n.validationInvalidNumber;
    }
    final dot = trimmed.indexOf('.');
    if (dot >= 0 && trimmed.length - dot - 1 > decimalPlaces) {
      return l10n.validationMaxDecimals(decimalPlaces);
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null) return l10n.validationInvalidNumber;
    if (!allowZero && parsed <= 0) return l10n.validationGreaterThanZero;
    if (max != null && parsed > max) {
      return l10n.validationMaxValue(_formatLimit(max, decimalPlaces));
    }
    return null;
  }

  /// Rupee amount: more than 0, at most 2 decimals.
  static String? money(
    String? value,
    AppLocalizations l10n, {
    bool isRequired = true,
    double max = AppInputLimits.maxWalletAmount,
    bool allowZero = false,
  }) => decimal(
    value,
    l10n,
    isRequired: isRequired,
    decimalPlaces: AppInputLimits.moneyDecimals,
    max: max,
    allowZero: allowZero,
  );

  /// Weight / quantity: more than 0, at most 3 decimals.
  static String? quantity(
    String? value,
    AppLocalizations l10n, {
    bool isRequired = true,
    double max = AppInputLimits.maxQuantity,
    bool allowZero = false,
  }) => decimal(
    value,
    l10n,
    isRequired: isRequired,
    decimalPlaces: AppInputLimits.quantityDecimals,
    max: max,
    allowZero: allowZero,
  );

  /// Whole number count: digits only, more than 0 unless [allowZero].
  static String? wholeNumber(
    String? value,
    AppLocalizations l10n, {
    bool isRequired = false,
    int? max,
    bool allowZero = false,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return isRequired ? l10n.validationRequired : null;
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) return l10n.validationWholeNumber;
    final parsed = int.tryParse(trimmed);
    if (parsed == null) return l10n.validationWholeNumber;
    if (!allowZero && parsed <= 0) return l10n.validationGreaterThanZero;
    if (max != null && parsed > max) {
      return l10n.validationMaxValue(max.toString());
    }
    return null;
  }

  /// D2D plate (`PUT`/`PATCH /vehicles` `plateNumber`): the documented
  /// pattern, e.g. `GJ-05-BX-1234`; letters are compared in capitals.
  static String? vehiclePlate(
    String? value,
    AppLocalizations l10n, {
    bool isRequired = true,
  }) {
    if (isBlank(value)) return isRequired ? l10n.validationRequired : null;
    return VehicleRegistrationNumber.isValid(value!)
        ? null
        : l10n.validationVehiclePlate;
  }

  /// Transfer truck number (`POST /transfers/{id}/approve`
  /// `vehicle.vehicleNumber` and `/handover` `vehicleNumber`): text of 4–20
  /// characters after trimming. The docs give no pattern for it.
  static String? transferVehicleNumber(
    String? value,
    AppLocalizations l10n, {
    bool isRequired = true,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return isRequired ? l10n.validationRequired : null;
    if (trimmed.length < 4 || trimmed.length > 20) {
      return l10n.validationVehicleNumberLength;
    }
    return null;
  }

  static String _formatLimit(double value, int decimalPlaces) {
    final fixed = value.toStringAsFixed(decimalPlaces);
    final parts = fixed.split('.');
    final whole = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    final fraction = parts.length > 1
        ? parts[1].replaceAll(RegExp(r'0+$'), '')
        : '';
    return fraction.isEmpty ? whole : '$whole.$fraction';
  }
}
