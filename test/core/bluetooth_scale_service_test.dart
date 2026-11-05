import 'package:eerl_app/core/bluetooth/bluetooth_scale_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('open protocol serial weight parser', () {
    test('parses an HC-05 style stable kilogram frame', () {
      expect(
        BluetoothScaleService.tryParseOpenProtocolWeight('ST,GS,+  12.450 kg'),
        12.45,
      );
    });

    test('converts grams to kilograms', () {
      expect(
        BluetoothScaleService.tryParseOpenProtocolWeight('weight=12500 g'),
        12.5,
      );
    });

    test('converts pounds to kilograms', () {
      expect(
        BluetoothScaleService.tryParseOpenProtocolWeight('100.00 lb'),
        closeTo(45.359237, 0.000001),
      );
    });

    test('parses a single unlabelled numeric serial frame', () {
      expect(
        BluetoothScaleService.tryParseOpenProtocolWeight('+00012.450'),
        12.45,
      );
    });

    test('rejects an ambiguous frame with multiple numeric fields', () {
      expect(
        BluetoothScaleService.tryParseOpenProtocolWeight('01,12.450'),
        isNull,
      );
    });

    test('rejects a frame without a numeric weight', () {
      expect(
        BluetoothScaleService.tryParseOpenProtocolWeight('STABLE'),
        isNull,
      );
    });
  });

  test('prefers a locally assigned Classic device alias', () {
    expect(
      BluetoothScaleService.resolveDeviceName('  WEIGH_SCALE:01  ', 'HC-05'),
      'WEIGH_SCALE:01',
    );
  });

  test('falls back to the broadcast Classic device name', () {
    expect(BluetoothScaleService.resolveDeviceName(null, '  HC-05  '), 'HC-05');
  });

  test('filters a Classic result when both names are empty', () {
    expect(BluetoothScaleService.resolveDeviceName(' ', null), isNull);
  });
}
