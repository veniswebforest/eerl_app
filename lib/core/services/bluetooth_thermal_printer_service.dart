import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothThermalPrinter {
  const BluetoothThermalPrinter({required this.name, required this.address});

  final String name;
  final String address;
}

/// Connects to a paired Bluetooth ESC/POS thermal printer and sends a 58 mm
/// raster receipt directly, without opening the operating-system print dialog.
class BluetoothThermalPrinterService {
  BluetoothThermalPrinterService._();

  static final instance = BluetoothThermalPrinterService._();
  static const _savedAddressKey = 'bluetooth_thermal_printer_address';
  static const _savedNameKey = 'bluetooth_thermal_printer_name';
  static const _printWidthPixels = 384;

  Future<bool> requestPermission() =>
      PrintBluetoothThermal.isPermissionBluetoothGranted;

  Future<bool> get isBluetoothEnabled => PrintBluetoothThermal.bluetoothEnabled;

  Future<bool> get isConnected => PrintBluetoothThermal.connectionStatus;

  Future<BluetoothThermalPrinter?> get savedPrinter async {
    final preferences = await SharedPreferences.getInstance();
    final address = preferences.getString(_savedAddressKey)?.trim();
    if (address == null || address.isEmpty) return null;
    return BluetoothThermalPrinter(
      name: preferences.getString(_savedNameKey)?.trim().isNotEmpty == true
          ? preferences.getString(_savedNameKey)!.trim()
          : address,
      address: address,
    );
  }

  Future<List<BluetoothThermalPrinter>> pairedPrinters() async {
    final devices = await PrintBluetoothThermal.pairedBluetooths;
    return devices
        .where((device) => device.macAdress.trim().isNotEmpty)
        .map(
          (device) => BluetoothThermalPrinter(
            name: device.name.trim().isEmpty
                ? device.macAdress.trim()
                : device.name.trim(),
            address: device.macAdress.trim(),
          ),
        )
        .toList(growable: false);
  }

  Future<bool> connect(BluetoothThermalPrinter printer) async {
    if (await isConnected) {
      await PrintBluetoothThermal.disconnect;
    }
    final connected = await PrintBluetoothThermal.connect(
      macPrinterAddress: printer.address,
    );
    if (!connected) return false;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_savedAddressKey, printer.address);
    await preferences.setString(_savedNameKey, printer.name);
    return true;
  }

  Future<bool> reconnectSavedPrinter() async {
    if (await isConnected) return true;
    final printer = await savedPrinter;
    return printer != null && await connect(printer);
  }

  Future<bool> printPng(Uint8List pngBytes) async {
    if (!await isConnected) return false;
    final decoded = img.decodeImage(pngBytes);
    if (decoded == null) return false;
    final receipt = img.copyResize(decoded, width: _printWidthPixels);
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final bytes = <int>[
      ...generator.reset(),
      ...generator.imageRaster(receipt, align: PosAlign.center),
      ...generator.feed(3),
    ];
    return PrintBluetoothThermal.writeBytes(bytes);
  }
}
