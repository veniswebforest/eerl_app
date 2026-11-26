import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/core/forms/module_input_rules.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations_en.dart';

void main() {
  final l10n = DriverLocalizationsEn();

  TextEditingValue apply(List<TextInputFormatter> fs, String text) {
    var v = const TextEditingValue();
    for (final f in fs) {
      v = f.formatEditUpdate(v, TextEditingValue(text: text));
      text = v.text;
    }
    return v;
  }

  test('keyboards match the field kind', () {
    expect(
      ModuleInputRules.keyboard(ModuleInputKind.phone),
      TextInputType.phone,
    );
    expect(
      ModuleInputRules.keyboard(ModuleInputKind.decimal),
      const TextInputType.numberWithOptions(decimal: true),
    );
    expect(
      ModuleInputRules.keyboard(ModuleInputKind.multiline),
      TextInputType.multiline,
    );
    expect(ModuleInputRules.keyboard(ModuleInputKind.name), TextInputType.name);
    expect(
      ModuleInputRules.capitalization(ModuleInputKind.vehicle),
      TextCapitalization.characters,
    );
  });

  test('formatters drop letters and limit decimals', () {
    expect(
      apply(ModuleInputRules.formatters(ModuleInputKind.integer), '30a0').text,
      '300',
    );
    expect(
      apply(ModuleInputRules.formatters(ModuleInputKind.decimal), '12.5x').text,
      '12.5',
    );
    const f = ModuleDecimalFormatter(2);
    final kept = f.formatEditUpdate(
      const TextEditingValue(text: '1.25'),
      const TextEditingValue(text: '1.256'),
    );
    expect(kept.text, '1.25');
    expect(
      apply(ModuleInputRules.formatters(ModuleInputKind.vehicle), 'gj05').text,
      'GJ05',
    );
  });

  test('required treats spaces as empty', () {
    expect(ModuleValidators.required(l10n, '   '), l10n.vlRequired);
    expect(ModuleValidators.required(l10n, 'ok'), isNull);
    expect(ModuleValidators.fullName(l10n, ' '), l10n.addRouteFullNameRequired);
    expect(
      ModuleValidators.fullName(l10n, 'A'),
      l10n.addRouteFullNameMinLength,
    );
  });

  test('phone: optional when empty, 10 digits from 6–9 when typed', () {
    expect(ModuleValidators.phone(l10n, ''), isNull);
    expect(
      ModuleValidators.phone(l10n, '', required: true),
      l10n.addRouteMobileRequired,
    );
    expect(ModuleValidators.phone(l10n, '98250 12458'), isNull);
    expect(ModuleValidators.phone(l10n, '12345'), l10n.addRouteMobileInvalid);
    expect(
      ModuleValidators.phone(l10n, '5825012458'),
      l10n.addRouteMobileInvalid,
    );
  });

  test('amounts and weights must be more than 0', () {
    expect(ModuleValidators.rupees(l10n, '0'), l10n.vlAmountPositive);
    expect(ModuleValidators.rupees(l10n, '1,250'), isNull);
    expect(
      ModuleValidators.rupees(l10n, '2000', max: 1250),
      l10n.vlMaxAmount('1250'),
    );
    expect(ModuleValidators.positiveDecimal(l10n, ''), isNull);
    expect(ModuleValidators.positiveDecimal(l10n, '0'), l10n.vlWeightPositive);
    expect(
      ModuleValidators.positiveDecimal(l10n, '1.2345'),
      l10n.vlMaxDecimals(3),
    );
    expect(ModuleValidators.positiveInteger(l10n, '3000'), isNull);
  });

  test('ID and vehicle numbers', () {
    expect(ModuleValidators.idNumber(l10n, ''), isNull);
    expect(ModuleValidators.idNumber(l10n, '8478 8456 6324'), isNull);
    expect(ModuleValidators.idNumber(l10n, 'abc1234567'), isNull);
    expect(ModuleValidators.idNumber(l10n, '123'), l10n.vlIdNumber);
    expect(ModuleValidators.vehicleNumber(l10n, 'GJ-05-EE-1002'), isNull);
    expect(ModuleValidators.vehicleNumber(l10n, 'hello'), l10n.vlVehicleNumber);
    expect(
      ModuleValidators.vehicleNumber(l10n, '', required: true),
      l10n.vlRequired,
    );
  });
}
