import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_ble/universal_ble.dart';

import 'package:eerl_app/core/logging/app_logger.dart';

enum BluetoothScaleStatus {
  idle,
  permissionDenied,
  adapterOff,
  scanning,
  connecting,
  connected,
  reconnecting,
  disconnected,
  unsupported,
  error,
}

class BluetoothScaleDevice {
  const BluetoothScaleDevice({
    required this.device,
    required this.name,
    required this.id,
    required this.rssi,
  });

  final BleDevice device;
  final String name;
  final String id;
  final int rssi;
}

/// Owns every BLE subscription used by the weighing-scale flow.
///
/// Only the Bluetooth SIG Weight Scale service/measurement UUID pair is
/// interpreted here. Custom characteristics are deliberately reported (with
/// their UUIDs) instead of guessing a proprietary payload format.
class BluetoothScaleService extends ChangeNotifier {
  BluetoothScaleService();

  static const Duration scanTimeout = Duration(seconds: 12);
  static const String weightScaleServiceUuid = '181d';
  static const String weightMeasurementCharacteristicUuid = '2a9d';

  final Map<String, BluetoothScaleDevice> _devices = {};
  StreamSubscription<BleDevice>? _scanSubscription;
  StreamSubscription<BleConnectionChange>? _connectionSubscription;
  StreamSubscription<Uint8List>? _measurementSubscription;
  Timer? _scanTimer;
  Timer? _reconnectTimer;

  BluetoothScaleStatus _status = BluetoothScaleStatus.idle;
  AvailabilityState _adapterState = AvailabilityState.unknown;
  BleDevice? _connectedDevice;
  BleCharacteristic? _measurementCharacteristic;
  double? _weightKg;
  String? _errorMessage;
  List<String> _discoveredGatt = const [];
  bool _intentionalDisconnect = false;
  bool _initialized = false;
  int _reconnectAttempts = 0;

  BluetoothScaleStatus get status => _status;
  AvailabilityState get adapterState => _adapterState;
  List<BluetoothScaleDevice> get devices =>
      _devices.values.toList()..sort((a, b) => b.rssi.compareTo(a.rssi));
  BleDevice? get connectedDevice => _connectedDevice;
  double? get weightKg => _weightKg;
  String? get errorMessage => _errorMessage;
  List<String> get discoveredGatt => _discoveredGatt;
  bool get isScanning => _status == BluetoothScaleStatus.scanning;
  bool get isConnected => _status == BluetoothScaleStatus.connected;

  Future<void> initialize() async {
    if (_initialized) return;
    UniversalBle.queueType = QueueType.perDevice;
    UniversalBle.onAvailabilityChange = _onAvailabilityChanged;
    _scanSubscription = UniversalBle.scanStream.listen(
      _onScanResult,
      onError: (Object error) => _setError('BLE scan failed: $error'),
    );
    try {
      _onAvailabilityChanged(
        await UniversalBle.getBluetoothAvailabilityState(),
      );
      _initialized = true;
    } catch (error) {
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      UniversalBle.onAvailabilityChange = null;
      _setError(
        'Bluetooth service is not loaded in this app process. Fully stop and '
        'reinstall/restart the app after the Universal BLE plugin change.',
      );
      AppLogger.diagnostic('BLE_PLUGIN_UNAVAILABLE', error.toString());
    }
  }

  void _onAvailabilityChanged(AvailabilityState state) {
    _adapterState = state;
    if (state != AvailabilityState.poweredOn) {
      _weightKg = null;
      if (state == AvailabilityState.unauthorized) {
        _status = BluetoothScaleStatus.permissionDenied;
        _errorMessage = 'Bluetooth permission is required to find the scale.';
      } else if (state == AvailabilityState.poweredOff) {
        _status = BluetoothScaleStatus.adapterOff;
        _errorMessage = 'Turn on Bluetooth to find a weighing scale.';
      } else if (state == AvailabilityState.unsupported) {
        _status = BluetoothScaleStatus.error;
        _errorMessage = 'Bluetooth Low Energy is not supported on this device.';
      }
    } else if (_status == BluetoothScaleStatus.adapterOff ||
        _status == BluetoothScaleStatus.permissionDenied) {
      _status = BluetoothScaleStatus.idle;
      _errorMessage = null;
    }
    notifyListeners();
  }

  Future<bool> requestPermissions() async {
    try {
      await UniversalBle.requestPermissions(withAndroidFineLocation: false);
      return true;
    } catch (error) {
      _status = BluetoothScaleStatus.permissionDenied;
      _errorMessage =
          'Bluetooth permission is required to find the weighing scale. '
          'Enable it in app settings if it was permanently denied.';
      AppLogger.diagnostic('BLE_SCALE_PERMISSION', error.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> startScan() async {
    await initialize();
    if (!_initialized) return;
    if (!await requestPermissions()) return;
    final state = await UniversalBle.getBluetoothAvailabilityState();
    if (state != AvailabilityState.poweredOn) {
      _onAvailabilityChanged(state);
      return;
    }
    if (_status == BluetoothScaleStatus.scanning) {
      await stopScan();
    }
    _devices.clear();
    _errorMessage = null;
    _status = BluetoothScaleStatus.scanning;
    notifyListeners();
    try {
      // Do not filter by UUID: proprietary scales may advertise no service
      // UUID at all. Their GATT UUIDs are inspected after connection.
      await UniversalBle.startScan(
        scanFilter: ScanFilter(connectableOnly: true),
        platformConfig: PlatformConfig(
          android: AndroidOptions(
            requestLocationPermission: false,
            scanMode: AndroidScanMode.lowLatency,
          ),
        ),
        // Some devices advertise their name only in a later packet. Keep
        // duplicates enabled until a named result has been stored.
        skipDuplicates: false,
      );
      unawaited(_loadSystemDevices());
      _scanTimer?.cancel();
      _scanTimer = Timer(scanTimeout, () => unawaited(stopScan()));
    } catch (error) {
      _setError('Unable to scan for BLE devices: $error');
    }
  }

  Future<void> stopScan() async {
    _scanTimer?.cancel();
    _scanTimer = null;
    if (_status != BluetoothScaleStatus.scanning) return;
    try {
      await UniversalBle.stopScan();
    } catch (error) {
      AppLogger.diagnostic('BLE_SCALE_STOP_SCAN', error.toString());
    }
    if (_status == BluetoothScaleStatus.scanning) {
      _status = BluetoothScaleStatus.idle;
      notifyListeners();
    }
  }

  void _onScanResult(BleDevice result) {
    if (_storeDevice(result)) notifyListeners();
  }

  Future<void> _loadSystemDevices() async {
    try {
      final systemDevices = await UniversalBle.getSystemDevices(
        withServices: const [],
        timeout: const Duration(seconds: 5),
      );
      var changed = false;
      for (final device in systemDevices) {
        changed = _storeDevice(device) || changed;
      }
      if (changed) notifyListeners();
    } catch (error) {
      // System devices supplement active scan results; scan remains usable
      // when a platform cannot return its already-connected BLE devices.
      AppLogger.diagnostic('BLE_SYSTEM_DEVICES', error.toString());
    }
  }

  bool _storeDevice(BleDevice result) {
    final id = UniversalBle.canonicalDeviceId(result.deviceId);
    if (_devices.containsKey(id)) return false;
    final name = resolveDeviceName(
      advertisedName: result.name ?? '',
      platformName: '',
    );
    // A nameless advertisement cannot be identified reliably in the UI.
    if (name == null) return false;
    _devices[id] = BluetoothScaleDevice(
      device: result,
      name: name,
      id: id,
      rssi: result.rssi ?? 0,
    );
    return true;
  }

  @visibleForTesting
  static String? resolveDeviceName({
    required String advertisedName,
    required String platformName,
  }) {
    final advertised = advertisedName.trim();
    if (advertised.isNotEmpty) return advertised;
    final platform = platformName.trim();
    return platform.isEmpty ? null : platform;
  }

  Future<void> connect(BluetoothScaleDevice scale) async {
    await stopScan();
    await _disconnectCurrent(intentional: true);
    _intentionalDisconnect = false;
    _connectedDevice = scale.device;
    _status = BluetoothScaleStatus.connecting;
    _errorMessage = null;
    _weightKg = null;
    notifyListeners();
    try {
      _listenToConnection(scale.device);
      await scale.device.connect(timeout: const Duration(seconds: 15));
      _reconnectAttempts = 0;
      await _discoverWeightCharacteristic(scale.device);
    } catch (error) {
      _setError('Unable to connect to ${scale.name}: $error');
    }
  }

  void _listenToConnection(BleDevice device) {
    unawaited(_connectionSubscription?.cancel());
    _connectionSubscription = device.connectionChangeStream.listen((change) {
      if (!change.isConnected &&
          _connectedDevice != null &&
          UniversalBle.canonicalDeviceId(_connectedDevice!.deviceId) ==
              UniversalBle.canonicalDeviceId(change.deviceId)) {
        _measurementCharacteristic = null;
        _weightKg = null;
        if (_intentionalDisconnect) {
          _status = BluetoothScaleStatus.disconnected;
        } else {
          if (change.error?.isNotEmpty == true) {
            AppLogger.diagnostic(
              'BLE_SCALE_DISCONNECTED',
              '${change.errorCode}: ${change.error} '
                  '(native=${change.nativeErrorCode})',
            );
          }
          _scheduleReconnect(device);
        }
        notifyListeners();
      }
    });
  }

  Future<void> _discoverWeightCharacteristic(BleDevice device) async {
    final services = await device.discoverServices(
      timeout: const Duration(seconds: 15),
    );
    final diagnostics = <String>[];
    BleCharacteristic? measurement;
    for (final service in services) {
      for (final characteristic in service.characteristics) {
        final properties = characteristic.properties;
        diagnostics.add(
          '${service.uuid}/${characteristic.uuid} '
          '[read=${properties.contains(CharacteristicProperty.read)}, '
          'notify=${properties.contains(CharacteristicProperty.notify)}, '
          'indicate=${properties.contains(CharacteristicProperty.indicate)}]',
        );
        if (BleUuidParser.compareStrings(
              service.uuid,
              weightScaleServiceUuid,
            ) &&
            BleUuidParser.compareStrings(
              characteristic.uuid,
              weightMeasurementCharacteristicUuid,
            )) {
          measurement = characteristic;
        }
      }
    }
    _discoveredGatt = List.unmodifiable(diagnostics);
    if (measurement == null) {
      _status = BluetoothScaleStatus.unsupported;
      _errorMessage =
          'Connected, but the standard Weight Measurement characteristic '
          '(0x2A9D) was not found. This may be a custom BLE protocol or a '
          'Bluetooth Classic SPP scale; its manufacturer UUID and payload '
          'format are required.';
      AppLogger.diagnostic('BLE_SCALE_GATT', diagnostics.join(', '));
      notifyListeners();
      return;
    }

    _measurementCharacteristic = measurement;
    await _measurementSubscription?.cancel();
    _measurementSubscription = measurement.onValueReceived.listen(
      _onMeasurement,
      onError: (Object error) => _setError('Weight stream failed: $error'),
    );
    final properties = measurement.properties;
    if (properties.contains(CharacteristicProperty.notify)) {
      await measurement.notifications.subscribe(
        timeout: const Duration(seconds: 10),
      );
    } else if (properties.contains(CharacteristicProperty.indicate)) {
      await measurement.indications.subscribe(
        timeout: const Duration(seconds: 10),
      );
    }
    if (properties.contains(CharacteristicProperty.read)) {
      _onMeasurement(
        await measurement.read(timeout: const Duration(seconds: 10)),
      );
    }
    _status = BluetoothScaleStatus.connected;
    _errorMessage = null;
    notifyListeners();
  }

  void _onMeasurement(Uint8List bytes) {
    if (bytes.isEmpty) return;
    try {
      final parsed = parseStandardWeightMeasurement(bytes);
      if (parsed <= 0 || !parsed.isFinite) return;
      _weightKg = parsed;
      _status = BluetoothScaleStatus.connected;
      _errorMessage = null;
      notifyListeners();
    } on FormatException catch (error) {
      _setError(error.message);
    }
  }

  @visibleForTesting
  static double parseStandardWeightMeasurement(List<int> bytes) {
    if (bytes.length < 3) {
      throw const FormatException('Invalid 0x2A9D weight payload.');
    }
    final data = Uint8List.fromList(bytes);
    final flags = data[0];
    final rawWeight = ByteData.sublistView(data).getUint16(1, Endian.little);
    final imperial = (flags & 0x01) != 0;
    if (imperial) {
      final pounds = rawWeight * 0.01;
      return pounds * 0.45359237;
    }
    return rawWeight * 0.005;
  }

  void _scheduleReconnect(BleDevice device) {
    _reconnectTimer?.cancel();
    if (_reconnectAttempts >= 3 ||
        _adapterState != AvailabilityState.poweredOn) {
      _status = BluetoothScaleStatus.disconnected;
      _errorMessage =
          'Weighing scale disconnected. Tap reconnect to try again.';
      return;
    }
    _reconnectAttempts++;
    _status = BluetoothScaleStatus.reconnecting;
    _reconnectTimer = Timer(
      Duration(seconds: _reconnectAttempts * 2),
      () async {
        if (_intentionalDisconnect ||
            _connectedDevice == null ||
            UniversalBle.canonicalDeviceId(_connectedDevice!.deviceId) !=
                UniversalBle.canonicalDeviceId(device.deviceId)) {
          return;
        }
        try {
          await device.connect(timeout: const Duration(seconds: 15));
          await _discoverWeightCharacteristic(device);
        } catch (error) {
          AppLogger.diagnostic('BLE_SCALE_RECONNECT', error.toString());
          _scheduleReconnect(device);
          notifyListeners();
        }
      },
    );
  }

  Future<void> reconnect() async {
    final device = _connectedDevice;
    if (device == null) {
      await startScan();
      return;
    }
    final id = UniversalBle.canonicalDeviceId(device.deviceId);
    final known =
        _devices[id] ??
        BluetoothScaleDevice(
          device: device,
          name:
              resolveDeviceName(
                advertisedName: device.name ?? '',
                platformName: '',
              ) ??
              'Weighing scale',
          id: id,
          rssi: device.rssi ?? 0,
        );
    await connect(known);
  }

  Future<void> disconnect() => _disconnectCurrent(intentional: true);

  Future<void> _disconnectCurrent({required bool intentional}) async {
    _intentionalDisconnect = intentional;
    _reconnectTimer?.cancel();
    await _measurementSubscription?.cancel();
    _measurementSubscription = null;
    final characteristic = _measurementCharacteristic;
    if (characteristic?.isSubscribed == true) {
      try {
        await characteristic!.unsubscribe(timeout: const Duration(seconds: 5));
      } catch (_) {
        // The device may already be gone; subscriptions are still released.
      }
    }
    _measurementCharacteristic = null;
    final device = _connectedDevice;
    if (device != null) {
      try {
        await device.disconnect(timeout: const Duration(seconds: 5));
      } catch (_) {
        // Safe cleanup after a remote disconnect.
      }
    }
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _connectedDevice = null;
    _weightKg = null;
    if (intentional) _status = BluetoothScaleStatus.disconnected;
    notifyListeners();
  }

  void _setError(String message) {
    _status = BluetoothScaleStatus.error;
    _errorMessage = message;
    AppLogger.diagnostic('BLE_SCALE_ERROR', message);
    notifyListeners();
  }

  Future<void> openSettings() => openAppSettings();

  Future<void> close() async {
    await stopScan();
    await _disconnectCurrent(intentional: true);
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    UniversalBle.onAvailabilityChange = null;
    _initialized = false;
    super.dispose();
  }
}
