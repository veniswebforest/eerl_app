import 'package:eerl_app/core/utils/input_formatters.dart';
import 'package:eerl_app/core/utils/input_validators.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('InputValidators.text', () {
    test('required empty and whitespace-only are rejected', () {
      expect(
        InputValidators.text('', l10n, isRequired: true),
        l10n.validationRequired,
      );
      expect(
        InputValidators.text('   ', l10n, isRequired: true),
        l10n.validationRequired,
      );
    });

    test('optional empty passes but is checked once filled', () {
      expect(InputValidators.text('', l10n, maxLength: 5), isNull);
      expect(InputValidators.text(null, l10n, minLength: 3), isNull);
      expect(
        InputValidators.text('ab', l10n, minLength: 3),
        l10n.validationMinLength(3),
      );
    });

    test('lengths are counted after trimming', () {
      expect(InputValidators.text('  ab  ', l10n, minLength: 3), isNotNull);
      expect(InputValidators.text('  abc  ', l10n, minLength: 3), isNull);
      expect(
        InputValidators.text('abcdef', l10n, maxLength: 5),
        l10n.validationMaxLength(5),
      );
    });
  });

  group('InputValidators.mobile', () {
    test('accepts 10 digits starting 6-9, with or without +91', () {
      expect(InputValidators.mobile('9876543210', l10n), isNull);
      expect(InputValidators.mobile('+91 98765 43210', l10n), isNull);
      expect(InputValidators.isValidMobile('6000000000'), isTrue);
    });

    test('rejects short, wrong prefix and alphabetic numbers', () {
      expect(InputValidators.mobile('98765', l10n), l10n.invalidMobileNumber);
      expect(
        InputValidators.mobile('5876543210', l10n),
        l10n.invalidMobileNumber,
      );
      expect(
        InputValidators.mobile('98765abcde', l10n),
        l10n.invalidMobileNumber,
      );
    });

    test('required vs optional empty', () {
      expect(InputValidators.mobile('', l10n), l10n.validationRequired);
      expect(InputValidators.mobile(' ', l10n, isRequired: false), isNull);
    });
  });

  group('InputValidators numbers', () {
    test('money: >0, max 2 decimals, max value', () {
      expect(InputValidators.money('10.50', l10n), isNull);
      expect(InputValidators.money('0', l10n), l10n.validationGreaterThanZero);
      expect(
        InputValidators.money('10.555', l10n),
        l10n.validationMaxDecimals(2),
      );
      expect(
        InputValidators.money('10000000', l10n),
        l10n.validationMaxValue('9,999,999'),
      );
      expect(InputValidators.money('abc', l10n), l10n.validationInvalidNumber);
      expect(InputValidators.money('', l10n), l10n.validationRequired);
      expect(InputValidators.money('', l10n, isRequired: false), isNull);
      expect(InputValidators.money('0', l10n, allowZero: true), isNull);
    });

    test('quantity: 3 decimals and 999,999.999 cap', () {
      expect(InputValidators.quantity('12.345', l10n), isNull);
      expect(
        InputValidators.quantity('12.3456', l10n),
        l10n.validationMaxDecimals(3),
      );
      expect(
        InputValidators.quantity('1000000', l10n),
        l10n.validationMaxValue('999,999.999'),
      );
    });

    test('whole numbers reject decimals and letters', () {
      expect(InputValidators.wholeNumber('12', l10n), isNull);
      expect(
        InputValidators.wholeNumber('1.5', l10n),
        l10n.validationWholeNumber,
      );
      expect(
        InputValidators.wholeNumber('a1', l10n),
        l10n.validationWholeNumber,
      );
      expect(
        InputValidators.wholeNumber('10000', l10n, max: 9999),
        l10n.validationMaxValue('9999'),
      );
    });
  });

  group('DecimalTextInputFormatter', () {
    TextEditingValue apply(
      TextInputFormatter formatter,
      String oldText,
      String newText,
    ) => formatter.formatEditUpdate(
      TextEditingValue(text: oldText),
      TextEditingValue(text: newText),
    );

    test('limits decimal places', () {
      const money = DecimalTextInputFormatter(decimalPlaces: 2);
      expect(apply(money, '12.3', '12.34').text, '12.34');
      expect(apply(money, '12.34', '12.345').text, '12.34');
      expect(apply(money, '', '.').text, '.');
    });

    test('rejects letters, second dot and values over the max', () {
      const quantity = DecimalTextInputFormatter(
        decimalPlaces: 3,
        maxValue: AppInputLimits.maxQuantity,
      );
      expect(apply(quantity, '12', '12a').text, '12');
      expect(apply(quantity, '1.2', '1.2.').text, '1.2');
      expect(apply(quantity, '999999', '9999999').text, '999999');
    });

    test('zero decimal places allows digits only', () {
      const whole = DecimalTextInputFormatter(decimalPlaces: 0);
      expect(apply(whole, '1', '1.').text, '1');
      expect(apply(whole, '1', '12').text, '12');
    });
  });

  group('vehicle numbers', () {
    test('D2D plate follows the PUT /vehicles pattern', () {
      expect(InputValidators.vehiclePlate('GJ-05-BX-1234', l10n), isNull);
      expect(InputValidators.vehiclePlate('gj 5 b 1234', l10n), isNull);
      expect(
        InputValidators.vehiclePlate('GJ-05-1234', l10n),
        l10n.validationVehiclePlate,
      );
      expect(InputValidators.vehiclePlate('  ', l10n), l10n.validationRequired);
      expect(InputValidators.vehiclePlate('', l10n, isRequired: false), isNull);
    });

    test('transfer truck number is 4–20 characters after trimming', () {
      expect(InputValidators.transferVehicleNumber('GJ05', l10n), isNull);
      expect(
        InputValidators.transferVehicleNumber(' GJ0 ', l10n),
        l10n.validationVehicleNumberLength,
      );
      expect(
        InputValidators.transferVehicleNumber('A' * 21, l10n),
        l10n.validationVehicleNumberLength,
      );
      expect(
        InputValidators.transferVehicleNumber('', l10n),
        l10n.validationRequired,
      );
    });

    test('lowercase becomes capitals while typing', () {
      const formatter = UpperCaseTextInputFormatter();
      expect(
        formatter
            .formatEditUpdate(
              TextEditingValue.empty,
              const TextEditingValue(text: 'gj-05 xy'),
            )
            .text,
        'GJ-05 XY',
      );
    });
  });
}
