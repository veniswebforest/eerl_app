import 'package:flutter/services.dart';

class DuplicateVehicleRegistrationException implements Exception {
  const DuplicateVehicleRegistrationException(this.plateNumber);

  final String plateNumber;
}

abstract final class VehicleRegistrationNumber {
  static final RegExp _validCompact = RegExp(
    r'^[A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{4}$',
  );

  static String? normalize(String value) {
    final compact = _compact(value);
    if (!_validCompact.hasMatch(compact)) return null;
    return _formatCompact(compact);
  }

  static bool isValid(String value) => normalize(value) != null;

  static String formatPartial(String value) {
    final source = _compact(value);
    final accepted = StringBuffer();
    for (final codeUnit in source.codeUnits) {
      if (accepted.length >= 10) break;
      final character = String.fromCharCode(codeUnit);
      final expectsLetter =
          accepted.length < 2 || (accepted.length >= 4 && accepted.length < 6);
      final valid = expectsLetter
          ? RegExp(r'[A-Z]').hasMatch(character)
          : RegExp(r'[0-9]').hasMatch(character);
      if (valid) accepted.write(character);
    }
    return _formatCompact(accepted.toString());
  }

  static String _compact(String value) =>
      value.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  static String _formatCompact(String value) {
    final groups = <String>[];
    for (final range in const [(0, 2), (2, 4), (4, 6), (6, 10)]) {
      if (value.length <= range.$1) break;
      groups.add(value.substring(range.$1, value.length.clamp(0, range.$2)));
    }
    return groups.join('-');
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
