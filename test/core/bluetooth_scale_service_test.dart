import 'package:eerl_app/core/bluetooth/bluetooth_scale_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses standard metric Weight Measurement payload in kilograms', () {
    // Flags 0x00 = SI units. 20,000 * 0.005 kg = 100 kg.
    expect(
      BluetoothScaleService.parseStandardWeightMeasurement([0x00, 0x20, 0x4e]),
      100,
    );
  });

  test('converts standard imperial Weight Measurement payload to kg', () {
    // Flags 0x01 = imperial. 10,000 * 0.01 lb = 100 lb.
    expect(
      BluetoothScaleService.parseStandardWeightMeasurement([0x01, 0x10, 0x27]),
      closeTo(45.359237, 0.000001),
    );
  });

  test('rejects an incomplete standard Weight Measurement payload', () {
    expect(
      () => BluetoothScaleService.parseStandardWeightMeasurement([0x00, 0x01]),
      throwsFormatException,
    );
  });

  test('uses the advertised BLE device name when available', () {
    expect(
      BluetoothScaleService.resolveDeviceName(
        advertisedName: '  Smart Scale  ',
        platformName: 'Platform Scale',
      ),
      'Smart Scale',
    );
  });

  test('falls back to the phone platform BLE device name', () {
    expect(
      BluetoothScaleService.resolveDeviceName(
        advertisedName: ' ',
        platformName: '  Platform Scale  ',
      ),
      'Platform Scale',
    );
  });

  test('filters a BLE result when both names are empty', () {
    expect(
      BluetoothScaleService.resolveDeviceName(
        advertisedName: ' ',
        platformName: '',
      ),
      isNull,
    );
  });
}
