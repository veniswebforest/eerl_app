import 'dart:async';
import 'dart:io';

import 'package:eerl_app/core/services/thermal_printer_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wi-Fi thermal printer validation', () {
    test('accepts local IP addresses and host names', () {
      expect(WifiThermalPrinterService.isValidHost('192.168.1.100'), isTrue);
      expect(
        WifiThermalPrinterService.isValidHost('receipt-printer.local'),
        isTrue,
      );
    });

    test('rejects blank or spaced addresses', () {
      expect(WifiThermalPrinterService.isValidHost(''), isFalse);
      expect(WifiThermalPrinterService.isValidHost('192.168.1. 100'), isFalse);
    });

    test('only accepts TCP ports in range', () {
      expect(WifiThermalPrinterService.isValidPort(9100), isTrue);
      expect(WifiThermalPrinterService.isValidPort(0), isFalse);
      expect(WifiThermalPrinterService.isValidPort(65536), isFalse);
      expect(WifiThermalPrinterService.isValidPort(null), isFalse);
    });
  });

  group('Wi-Fi printer advertised name', () {
    test('extracts the DNS-SD service instance name', () {
      expect(
        WifiThermalPrinterService.mdnsDisplayName(
          r'EPSON\032TM-m30III._pdl-datastream._tcp.local',
          '_pdl-datastream._tcp.local',
        ),
        'EPSON TM-m30III',
      );
    });

    test('rejects a domain from another service type', () {
      expect(
        WifiThermalPrinterService.mdnsDisplayName(
          'Office Printer._ipp._tcp.local',
          '_pdl-datastream._tcp.local',
        ),
        isNull,
      );
    });
  });

  test(
    'sends a complete raster job over the network printer connection',
    () async {
      SharedPreferences.setMockInitialValues({});
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final received = <int>[];
      final receivedAllBytes = Completer<void>();
      final serverSubscription = server.listen((socket) {
        socket.listen(received.addAll, onDone: receivedAllBytes.complete);
      });
      addTearDown(() async {
        await serverSubscription.cancel();
        await server.close();
      });

      final printJob = List<int>.generate(6000, (index) => index % 256);
      final printed = await WifiThermalPrinterService.instance.printBytes(
        WifiThermalPrinter(host: '127.0.0.1', port: server.port),
        printJob,
      );

      expect(printed, isTrue);
      await receivedAllBytes.future.timeout(const Duration(seconds: 2));
      expect(received, isNotEmpty);
      expect(received, printJob);
    },
  );
}
