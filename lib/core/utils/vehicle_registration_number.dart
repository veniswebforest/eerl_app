import 'package:flutter/services.dart';

class DuplicateVehicleRegistrationException implements Exception {
  const DuplicateVehicleRegistrationException(this.plateNumber);

  final String plateNumber;
}

abstract final class VehicleRegistrationNumber {
  /// The plate rule of `PUT /vehicles/{id}` ("Validation rules (28 Oct 2026)"
  /// in `docs/project-context/overall-requirements.md`).
  static final RegExp _docPattern = RegExp(
    r'^[A-Z]{2}[-\s]?[0-9]{1,2}[-\s]?[A-Z]{1,2}[-\s]?[0-9]{4}$',
  );

  /// Longest text the rule allows: `AA-00-AA-0000`.
  static const maxLength = 13;

  /// The plate trimmed and uppercased, as typed, or `null` when it does not
  /// match the rule. The docs store the plate "uppercased, as typed".
  static String? normalize(String value) {
    final upper = value.trim().toUpperCase();
    return _docPattern.hasMatch(upper) ? upper : null;
  }

  static bool isValid(String value) => normalize(value) != null;

  /// Uppercases while typing and keeps only letters, digits, `-` and spaces,
  /// up to [maxLength] characters. The full rule is checked on save.
  static String formatPartial(String value) {
    final filtered = value.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9\-\s]'),
      '',
    );
    return filtered.length > maxLength
        ? filtered.substring(0, maxLength)
        : filtered;
  }
}

class VehicleRegistrationInputFormatter extends TextInputFormatter {
  const VehicleRegistrationInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = VehicleRegistrationNumber.formatPartial(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
