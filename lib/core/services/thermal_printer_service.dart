import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/network/network_print_result.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:image/image.dart' as img;
import 'package:multicast_dns/multicast_dns.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThermalPrinterTransport { bluetooth, wifi, usb }

class ThermalPrinterPreferences {
  ThermalPrinterPreferences._();

  static const _transportKey = 'thermal_printer_transport';
  static const _labelKey = 'thermal_printer_label';

  static Future<void> remember(
    ThermalPrinterTransport transport,
    String label,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_transportKey, transport.name);
    await preferences.setString(_labelKey, label);
  }

  static Future<({ThermalPrinterTransport transport, String label})?>
  get lastPrinter async {
    final preferences = await SharedPreferences.getInstance();
    final transportName = preferences.getString(_transportKey);
    final label = preferences.getString(_labelKey)?.trim();
    if (transportName == null || label == null || label.isEmpty) return null;
    for (final transport in ThermalPrinterTransport.values) {
      if (transport.name == transportName) {
        return (transport: transport, label: label);
      }
    }
    return null;
  }
}

class ThermalPrinterBytes {
  ThermalPrinterBytes._();

  static const printWidthPixels = 384;

  static Future<Uint8List?> fromPng(Uint8List pngBytes) async {
    final decoded = img.decodeImage(pngBytes);
    if (decoded == null) return null;
    final receipt = img.copyResize(decoded, width: printWidthPixels);
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    return Uint8List.fromList([
      ...generator.reset(),
      ...generator.imageRaster(receipt, align: PosAlign.center),
      ...generator.feed(3),
    ]);
  }
}

/// Bluetooth and USB discovery/printing backed entirely by
/// flutter_thermal_printer. The plugin owns all native communication.
class ThermalPrinterService {
  ThermalPrinterService._();

  static final instance = ThermalPrinterService._();
  final FlutterThermalPrinter _plugin = FlutterThermalPrinter.instance;

  Future<bool> ensureBluetoothEnabled() async {
    if (await _plugin.isBleTurnedOn()) return true;
    await _plugin.turnOnBluetooth();
    for (var attempt = 0; attempt < 12; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (await _plugin.isBleTurnedOn()) return true;
    }
    return false;
  }

  Future<List<Printer>> scanPrinters(ConnectionType type) async {
    var latest = <Printer>[];
    final subscription = _plugin.devicesStream.listen((devices) {
      latest = devices
          .where((printer) => printer.connectionType == type)
          .toList(growable: false);
    });
    try {
      await _plugin.getPrinters(
        refreshDuration: const Duration(seconds: 1),
        connectionTypes: [type],
        androidUsesFineLocation: false,
      );
      await Future<void>.delayed(const Duration(seconds: 4));
      return latest;
    } on Object {
      return const [];
    } finally {
      await _plugin.stopScan();
      await subscription.cancel();
    }
  }

  Future<bool> printPng(Printer printer, Uint8List pngBytes) async {
    final bytes = await ThermalPrinterBytes.fromPng(pngBytes);
    if (bytes == null) return false;
    try {
      final connectedPrinter = printer.connectionType == ConnectionType.BLE
          ? await _connectBlePrinter(printer)
          : await _plugin.connect(printer)
          ? printer
          : null;
      if (connectedPrinter == null) return false;
      await _plugin.printData(connectedPrinter, bytes, longData: true);
      final transport = connectedPrinter.connectionType == ConnectionType.USB
          ? ThermalPrinterTransport.usb
          : ThermalPrinterTransport.bluetooth;
      await ThermalPrinterPreferences.remember(
        transport,
        connectedPrinter.name?.trim().isNotEmpty == true
            ? connectedPrinter.name!.trim()
            : connectedPrinter.address ?? transport.name,
      );
      return true;
    } on Object catch (error) {
      AppLogger.diagnostic('THERMAL_PRINTER_PRINT', error.toString());
      return false;
    }
  }

  /// Android can report GATT_CONNECTION_TIMEOUT (147) even though a BLE
  /// advertisement was discovered. Close the failed GATT client, wait for the
  /// peripheral to advertise again, and retry once with a fresh scan result.
  Future<Printer?> _connectBlePrinter(Printer selectedPrinter) async {
    var printer = selectedPrinter;
    for (var attempt = 1; attempt <= 2; attempt++) {
      AppLogger.diagnostic(
        'THERMAL_PRINTER_BLE',
        'Connecting attempt=$attempt name=${printer.name} '
            'address=${printer.address} services=${printer.services.join(',')}',
      );
      final connected =
          printer.isConnected == true ||
          await _plugin.connect(
            printer,
            connectionStabilizationDelay: const Duration(seconds: 10),
          );
      if (connected) return printer;

      AppLogger.diagnostic(
        'THERMAL_PRINTER_BLE',
        'Connection failed attempt=$attempt address=${printer.address}',
      );
      if (attempt == 2) break;

      // flutter_thermal_printer catches the native GATT exception and returns
      // false. Explicit disconnect ensures Android does not reuse that failed
      // client on the retry.
      await _plugin.disconnect(printer);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      final rescanned = await scanPrinters(ConnectionType.BLE);
      final address = selectedPrinter.address?.toLowerCase();
      for (final candidate in rescanned) {
        if (candidate.address?.toLowerCase() == address) {
          printer = candidate;
          break;
        }
      }
    }
    return null;
  }
}

class WifiThermalPrinter {
  const WifiThermalPrinter({required this.host, this.port = 9100, this.name});

  final String host;
  final int port;
  final String? name;

  String get label {
    final configuredName = name?.trim();
    return configuredName == null || configuredName.isEmpty
        ? host
        : configuredName;
  }
}

/// Finds raw ESC/POS printers on the current local network. Version 2.3.0 of
/// flutter_thermal_printer does not discover Android network printers, so
/// discovery stays in Dart while connection and printing use its network API.
class WifiThermalPrinterService {
  WifiThermalPrinterService._();

  static final instance = WifiThermalPrinterService._();

  static bool isValidHost(String value) {
    final host = value.trim();
    if (host.isEmpty || host.contains(RegExp(r'\s'))) return false;
    final address = InternetAddress.tryParse(host);
    if (address != null) return true;
    return RegExp(
      r'^(?=.{1,253}$)([a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)*[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$',
    ).hasMatch(host);
  }

  static bool isValidPort(int? port) =>
      port != null && port >= 1 && port <= 65535;

  Future<List<WifiThermalPrinter>> discoverPrinters() async {
    final localAddress = await _localIpv4Address();
    if (localAddress == null) return const [];
    final parts = localAddress.split('.');
    if (parts.length != 4) return const [];
    final prefix = parts.take(3).join('.');
    final mdnsNamesFuture = _discoverMdnsNames();
    final printers = await _scanRawPrinters(
      localAddress: localAddress,
      prefix: prefix,
    );
    final mdnsNames = await mdnsNamesFuture;

    return Future.wait(
      printers.map((printer) async {
        final advertisedName = mdnsNames[printer.host];
        final name = advertisedName ?? await _reverseHostName(printer.host);
        return WifiThermalPrinter(
          host: printer.host,
          port: printer.port,
          name: name ?? _fallbackPrinterName(printer.host),
        );
      }),
    );
  }

  Future<List<WifiThermalPrinter>> _scanRawPrinters({
    required String localAddress,
    required String prefix,
  }) async {
    final printers = <WifiThermalPrinter>[];

    for (var start = 1; start <= 254; start += 32) {
      final end = (start + 31).clamp(1, 254);
      final batch = <Future<WifiThermalPrinter?>>[];
      for (var suffix = start; suffix <= end; suffix++) {
        final host = '$prefix.$suffix';
        if (host == localAddress) continue;
        batch.add(_probe(host));
      }
      final results = await Future.wait(batch);
      printers.addAll(results.whereType<WifiThermalPrinter>());
    }
    return printers;
  }

  Future<Map<String, String>> _discoverMdnsNames() async {
    const serviceTypes = <String>[
      '_pdl-datastream._tcp.local',
      '_printer._tcp.local',
      '_ipp._tcp.local',
      '_ipps._tcp.local',
    ];
    final client = MDnsClient();
    final names = <String, String>{};
    var started = false;
    try {
      await client.start();
      started = true;
      await Future.wait(
        serviceTypes.map(
          (serviceType) => _collectMdnsNames(
            client: client,
            serviceType: serviceType,
            names: names,
          ),
        ),
      );
    } on Object {
      // Subnet discovery remains available when multicast is blocked.
    } finally {
      if (started) client.stop();
    }
    return names;
  }

  Future<void> _collectMdnsNames({
    required MDnsClient client,
    required String serviceType,
    required Map<String, String> names,
  }) async {
    await for (final ptr in client.lookup<PtrResourceRecord>(
      ResourceRecordQuery.serverPointer(serviceType),
      timeout: const Duration(seconds: 2),
    )) {
      final displayName = mdnsDisplayName(ptr.domainName, serviceType);
      if (displayName == null) continue;
      await for (final srv in client.lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName),
        timeout: const Duration(seconds: 1),
      )) {
        await for (final address in client.lookup<IPAddressResourceRecord>(
          ResourceRecordQuery.addressIPv4(srv.target),
          timeout: const Duration(seconds: 1),
        )) {
          names[address.address.address] = displayName;
        }
      }
    }
  }

  static String? mdnsDisplayName(String domainName, String serviceType) {
    final marker = '.$serviceType';
    final markerIndex = domainName.toLowerCase().indexOf(marker.toLowerCase());
    if (markerIndex <= 0) return null;
    final name = domainName
        .substring(0, markerIndex)
        .replaceAll(r'\032', ' ')
        .replaceAll(r'\046', '&')
        .replaceAll(r'\.', '.')
        .trim();
    return name.isEmpty ? null : name;
  }

  Future<String?> _reverseHostName(String host) async {
    try {
      final reverse = await InternetAddress(
        host,
      ).reverse().timeout(const Duration(milliseconds: 700));
      final resolved = reverse.host
          .replaceFirst(RegExp(r'\.local\.?$', caseSensitive: false), '')
          .trim();
      if (resolved.isEmpty || resolved == host) return null;
      return resolved;
    } on Object {
      return null;
    }
  }

  String _fallbackPrinterName(String host) {
    final suffix = host.split('.').last;
    return 'Wi-Fi Printer $suffix';
  }

  Future<String?> _localIpv4Address() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (address.isLoopback || address.type != InternetAddressType.IPv4) {
            continue;
          }
          final value = address.address;
          if (value.startsWith('10.') ||
              value.startsWith('192.168.') ||
              RegExp(r'^172\.(1[6-9]|2\d|3[01])\.').hasMatch(value)) {
            return value;
          }
        }
      }
    } on Object {
      return null;
    }
    return null;
  }

  Future<WifiThermalPrinter?> _probe(String host) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        host,
        9100,
        timeout: const Duration(milliseconds: 350),
      );
      return WifiThermalPrinter(host: host);
    } on Object {
      return null;
    } finally {
      socket?.destroy();
    }
  }

  Future<bool> printPng(WifiThermalPrinter printer, Uint8List pngBytes) async {
    final bytes = await ThermalPrinterBytes.fromPng(pngBytes);
    if (bytes == null) return false;
    return printBytes(printer, bytes);
  }

  Future<bool> printBytes(WifiThermalPrinter printer, List<int> bytes) async {
    final networkPrinter = FlutterThermalPrinterNetwork(
      printer.host,
      port: printer.port,
    );
    try {
      final connectResult = await networkPrinter
          .connect(timeout: const Duration(seconds: 6))
          .timeout(const Duration(seconds: 8));
      if (connectResult != NetworkPrintResult.success) return false;

      // Long raster commands can overflow the small receive buffer used by
      // inexpensive ESC/POS printers. Keep one plugin-managed connection open
      // and pace the byte stream in printer-friendly chunks.
      const chunkSize = 2048;
      for (var offset = 0; offset < bytes.length; offset += chunkSize) {
        final end = (offset + chunkSize).clamp(0, bytes.length);
        final chunk = bytes.sublist(offset, end);
        final printResult = await networkPrinter
            .printTicket(chunk, isDisconnect: false)
            .timeout(const Duration(seconds: 6));
        if (printResult != NetworkPrintResult.success) return false;
        await Future<void>.delayed(const Duration(milliseconds: 12));
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await ThermalPrinterPreferences.remember(
        ThermalPrinterTransport.wifi,
        printer.label,
      );
      return true;
    } on Object {
      return false;
    } finally {
      await networkPrinter.disconnect().timeout(
        const Duration(seconds: 3),
        onTimeout: () => NetworkPrintResult.success,
      );
    }
  }
}
