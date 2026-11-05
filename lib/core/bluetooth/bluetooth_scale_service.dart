import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_classic_bluetooth/flutter_classic_bluetooth.dart';

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

  final BtcDevice device;
  final String name;
  final String id;
  final int? rssi;

  bool get isPaired => device.bondState == BtcBondState.bonded;
}

/// Owns every Bluetooth Classic/RFCOMM subscription used by the scale flow.
///
/// The scale is an HC-05-style Serial Port Profile device. Incoming RFCOMM
/// bytes are framed on CR/LF where possible. Until the manufacturer's exact
/// open-protocol document is available, only an unambiguous numeric weight is
/// accepted; every raw frame is logged so the real protocol can be tightened
/// after device testing.
class BluetoothScaleService extends ChangeNotifier {
  BluetoothScaleService({FlutterClassicBluetooth? bluetooth})
    : _bluetooth = bluetooth ?? FlutterClassicBluetooth();

  static const Duration scanTimeout = Duration(seconds: 12);
  static const Duration connectionTimeout = Duration(seconds: 15);

  final FlutterClassicBluetooth _bluetooth;
  final Map<String, BluetoothScaleDevice> _devices = {};

  StreamSubscription<BtcAdapterState>? _adapterSubscription;
  StreamSubscription<BtcDevice>? _discoverySubscription;
  StreamSubscription<bool>? _discoveryStateSubscription;
  StreamSubscription<Uint8List>? _inputSubscription;
  StreamSubscription<BtcConnectionState>? _connectionStateSubscription;
  Timer? _scanTimer;
  Timer? _reconnectTimer;
  Timer? _unterminatedFrameTimer;

  BluetoothScaleStatus _status = BluetoothScaleStatus.idle;
  BtcAdapterState _adapterState = BtcAdapterState.unknown;
  BtcDevice? _connectedDevice;
  BtcConnection? _connection;
  double? _weightKg;
  String? _errorMessage;
  String? _lastRawFrame;
  String _receiveBuffer = '';
  bool _intentionalDisconnect = false;
  bool _initialized = false;
  int _reconnectAttempts = 0;

  BluetoothScaleStatus get status => _status;
  BtcAdapterState get adapterState => _adapterState;
  List<BluetoothScaleDevice> get devices {
    final result = _devices.values.toList();
    result.sort((a, b) {
      if (a.isPaired != b.isPaired) return a.isPaired ? -1 : 1;
      return (b.rssi ?? -1000).compareTo(a.rssi ?? -1000);
    });
    return result;
  }

  BtcDevice? get connectedDevice => _connectedDevice;
  double? get weightKg => _weightKg;
  String? get errorMessage => _errorMessage;
  String? get lastRawFrame => _lastRawFrame;
  bool get isScanning => _status == BluetoothScaleStatus.scanning;
  bool get isConnected =>
      _status == BluetoothScaleStatus.connected &&
      _connection?.isConnected == true;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      if (!await _bluetooth.isSupported()) {
        _status = BluetoothScaleStatus.unsupported;
        _errorMessage = 'Bluetooth Classic is not supported on this device.';
        notifyListeners();
        return;
      }
      _adapterSubscription = _bluetooth.adapterState.listen(
        _onAdapterStateChanged,
        onError: (Object error) =>
            _setError('Bluetooth adapter state failed: $error'),
      );
      _discoverySubscription = _bluetooth.discoveryResults.listen(
        _onDiscoveryResult,
        onError: (Object error) =>
            _setError('Bluetooth device discovery failed: $error'),
      );
      _discoveryStateSubscription = _bluetooth.discoveryState.listen(
        _onDiscoveryStateChanged,
        onError: (Object error) =>
            AppLogger.diagnostic('BT_SCALE_DISCOVERY_STATE', error.toString()),
      );
      _initialized = true;
      _onAdapterStateChanged(
        await _bluetooth.isEnabled() ? BtcAdapterState.on : BtcAdapterState.off,
      );
    } catch (error) {
      _setError(
        'Bluetooth Classic service is not loaded. Fully stop and reinstall '
        'the app after the plugin change. Details: $error',
      );
      AppLogger.diagnostic('BT_CLASSIC_PLUGIN_UNAVAILABLE', error.toString());
    }
  }

  void _onAdapterStateChanged(BtcAdapterState state) {
    _adapterState = state;
    if (state == BtcAdapterState.on) {
      if (_status == BluetoothScaleStatus.adapterOff ||
          _status == BluetoothScaleStatus.permissionDenied) {
        _status = BluetoothScaleStatus.idle;
        _errorMessage = null;
      }
    } else {
      _weightKg = null;
      switch (state) {
        case BtcAdapterState.unauthorized:
          _status = BluetoothScaleStatus.permissionDenied;
          _errorMessage =
              'Nearby devices permission is required to find the scale.';
        case BtcAdapterState.off:
        case BtcAdapterState.turningOff:
          _status = BluetoothScaleStatus.adapterOff;
          _errorMessage = 'Turn on Bluetooth to find the weighing scale.';
        case BtcAdapterState.unsupported:
          _status = BluetoothScaleStatus.unsupported;
          _errorMessage = 'Bluetooth Classic is not supported on this device.';
        case BtcAdapterState.unknown:
        case BtcAdapterState.turningOn:
        case BtcAdapterState.on:
          break;
      }
    }
    notifyListeners();
  }

  Future<bool> requestPermissions() async {
    try {
      final result = await _bluetooth.requestPermissions(
        permissions: const {BtcPermission.scan, BtcPermission.connect},
      );
      if (result == BtcPermissionStatus.granted ||
          result == BtcPermissionStatus.notRequired) {
        return true;
      }
      _status = BluetoothScaleStatus.permissionDenied;
      _errorMessage = result == BtcPermissionStatus.permanentlyDenied
          ? 'Nearby devices permission is permanently denied. Enable it in app settings.'
          : 'Nearby devices permission is required to find the weighing scale.';
      notifyListeners();
      return false;
    } catch (error) {
      _status = BluetoothScaleStatus.permissionDenied;
      _errorMessage = 'Unable to request Bluetooth permission: $error';
      AppLogger.diagnostic('BT_SCALE_PERMISSION', error.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> startScan() async {
    await initialize();
    if (!_initialized || !await requestPermissions()) return;
    if (!await _bluetooth.isEnabled()) {
      _onAdapterStateChanged(BtcAdapterState.off);
      return;
    }
    if (await _bluetooth.isLocationServiceRequired() &&
        !await _bluetooth.isLocationServiceEnabled()) {
      _status = BluetoothScaleStatus.error;
      _errorMessage =
          'Turn on Location to discover Bluetooth devices on this Android version.';
      notifyListeners();
      return;
    }

    await stopScan();
    _devices.clear();
    _errorMessage = null;
    _status = BluetoothScaleStatus.scanning;
    notifyListeners();

    try {
      // A paired scale should be selectable immediately, even when it is not
      // currently discoverable. Live discovery then adds unpaired devices.
      final paired = await _bluetooth.getPairedDevices();
      for (final device in paired) {
        _storeDevice(device);
      }
      notifyListeners();
      await _bluetooth.startDiscovery();
      _scanTimer?.cancel();
      _scanTimer = Timer(scanTimeout, () => unawaited(stopScan()));
    } on BtcPermissionException catch (error) {
      _status = BluetoothScaleStatus.permissionDenied;
      _errorMessage = error.message;
      notifyListeners();
    } on BtcDisabledException {
      _onAdapterStateChanged(BtcAdapterState.off);
    } catch (error) {
      _setError('Unable to scan for Bluetooth Classic devices: $error');
    }
  }

  Future<void> stopScan() async {
    _scanTimer?.cancel();
    _scanTimer = null;
    try {
      if (_initialized && await _bluetooth.isDiscovering()) {
        await _bluetooth.stopDiscovery();
      }
    } catch (error) {
      AppLogger.diagnostic('BT_SCALE_STOP_SCAN', error.toString());
    }
    if (_status == BluetoothScaleStatus.scanning) {
      _status = BluetoothScaleStatus.idle;
      notifyListeners();
    }
  }

  void _onDiscoveryStateChanged(bool discovering) {
    if (!discovering && _status == BluetoothScaleStatus.scanning) {
      _scanTimer?.cancel();
      _scanTimer = null;
      _status = BluetoothScaleStatus.idle;
      notifyListeners();
    }
  }

  void _onDiscoveryResult(BtcDevice result) {
    if (_storeDevice(result)) notifyListeners();
  }

  bool _storeDevice(BtcDevice result) {
    if (result.type == BtcDeviceType.le) return false;
    final id = _canonicalDeviceId(result.address);
    final name = resolveDeviceName(result.alias, result.name);
    if (name == null) return false;
    final previous = _devices[id];
    final merged = previous == null
        ? result
        : previous.device.mergedWith(result);
    _devices[id] = BluetoothScaleDevice(
      device: merged,
      name: resolveDeviceName(merged.alias, merged.name) ?? name,
      id: id,
      rssi: merged.rssi,
    );
    if (previous == null) {
      AppLogger.diagnostic(
        'BT_CLASSIC_DEVICE_FOUND',
        'name=$name address=$id rssi=${result.rssi} '
            'paired=${result.bondState == BtcBondState.bonded} '
            'type=${result.type.name} uuids=${result.uuids.join(',')}',
      );
    }
    return true;
  }

  @visibleForTesting
  static String? resolveDeviceName(String? alias, String? name) {
    final localAlias = alias?.trim() ?? '';
    if (localAlias.isNotEmpty) return localAlias;
    final advertisedName = name?.trim() ?? '';
    return advertisedName.isEmpty ? null : advertisedName;
  }

  Future<void> connect(BluetoothScaleDevice scale) async {
    await stopScan();
    await _disconnectCurrent(intentional: true);
    _intentionalDisconnect = false;
    _connectedDevice = scale.device;
    _status = BluetoothScaleStatus.connecting;
    _errorMessage = null;
    _weightKg = null;
    _receiveBuffer = '';
    notifyListeners();

    try {
      var device = scale.device;
      if (device.bondState != BtcBondState.bonded) {
        final paired = await _bluetooth.bondDevice(device.address);
        if (!paired) {
          throw const BtcConnectionException(
            'Pairing was not completed. Pair the scale and try again.',
            cause: BtcConnectFailure.notPaired,
          );
        }
        device = BtcDevice(
          address: device.address,
          name: device.name,
          alias: device.alias,
          rssi: device.rssi,
          type: device.type,
          bondState: BtcBondState.bonded,
          uuids: device.uuids,
        );
        _connectedDevice = device;
        _storeDevice(device);
      }

      final connection = await _bluetooth.connect(
        address: device.address,
        timeout: connectionTimeout,
      );
      _connection = connection;
      _reconnectAttempts = 0;
      _listenToConnection(connection);
      _status = BluetoothScaleStatus.connected;
      _errorMessage = null;
      AppLogger.diagnostic(
        'BT_SCALE_CONNECTED',
        'name=${scale.name} address=${device.address} uuid=${BtcUuid.spp}',
      );
      notifyListeners();
    } on BtcConnectionException catch (error) {
      _setError('Unable to connect to ${scale.name}: ${error.message}');
    } on BtcTimeoutException catch (error) {
      _setError('Connection to ${scale.name} timed out: ${error.message}');
    } catch (error) {
      _setError('Unable to connect to ${scale.name}: $error');
    }
  }

  void _listenToConnection(BtcConnection connection) {
    unawaited(_inputSubscription?.cancel());
    unawaited(_connectionStateSubscription?.cancel());
    _inputSubscription = connection.input.listen(
      _onSerialBytes,
      onError: (Object error) => _setError('Weight stream failed: $error'),
      onDone: _handleRemoteDisconnect,
    );
    _connectionStateSubscription = connection.stateStream.listen((state) {
      if (state == BtcConnectionState.disconnected) {
        _handleRemoteDisconnect();
      }
    });
  }

  void _onSerialBytes(Uint8List bytes) {
    if (bytes.isEmpty) return;
    final chunk = ascii
        .decode(bytes, allowInvalid: true)
        .replaceAll('\u0000', '');
    AppLogger.diagnostic(
      'BT_SCALE_RX',
      'hex=${bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ')} '
          'text=${jsonEncode(chunk)}',
    );
    _receiveBuffer += chunk;
    if (_receiveBuffer.length > 4096) {
      _receiveBuffer = _receiveBuffer.substring(_receiveBuffer.length - 4096);
    }

    final frames = _receiveBuffer.split(RegExp(r'[\r\n]+'));
    _receiveBuffer = frames.removeLast();
    for (final frame in frames) {
      _processFrame(frame);
    }

    // Some open-protocol indicators stream fixed records without CR/LF.
    // Debounce the current chunk and treat it as one frame without losing the
    // normal delimiter-based path.
    _unterminatedFrameTimer?.cancel();
    if (_receiveBuffer.trim().isNotEmpty) {
      _unterminatedFrameTimer = Timer(const Duration(milliseconds: 180), () {
        final frame = _receiveBuffer;
        _receiveBuffer = '';
        _processFrame(frame);
      });
    }
  }

  void _processFrame(String frame) {
    final clean = frame.trim();
    if (clean.isEmpty) return;
    _lastRawFrame = clean;
    AppLogger.diagnostic('BT_SCALE_FRAME', jsonEncode(clean));
    final parsed = tryParseOpenProtocolWeight(clean);
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      AppLogger.diagnostic(
        'BT_SCALE_UNPARSED_FRAME',
        'No unambiguous weight found in ${jsonEncode(clean)}',
      );
      notifyListeners();
      return;
    }
    _weightKg = parsed;
    _status = BluetoothScaleStatus.connected;
    _errorMessage = null;
    notifyListeners();
  }

  @visibleForTesting
  static double? tryParseOpenProtocolWeight(String frame) {
    final normalized = frame
        .replaceAll('\u0000', '')
        .replaceAll(',', '.')
        .trim();
    if (normalized.isEmpty) return null;

    // Prefer a value explicitly labelled with a supported unit.
    final labelled = RegExp(
      r'([+-]?\s*\d+(?:\.\d+)?)\s*(kg|kgs|kilograms?|g|grams?|lb|lbs|pounds?)\b',
      caseSensitive: false,
    ).allMatches(normalized).toList();
    if (labelled.isNotEmpty) {
      final match = labelled.last;
      final value = double.tryParse(match.group(1)!.replaceAll(' ', ''));
      if (value == null) return null;
      final unit = match.group(2)!.toLowerCase();
      if (unit == 'g' || unit.startsWith('gram')) return value / 1000;
      if (unit == 'lb' || unit == 'lbs' || unit.startsWith('pound')) {
        return value * 0.45359237;
      }
      return value;
    }

    // For an unlabelled serial frame, accept it only when there is exactly
    // one numeric field. This avoids mistaking status codes for a weight.
    final numbers = RegExp(
      r'[+-]?\s*\d+(?:\.\d+)?',
    ).allMatches(normalized).toList();
    if (numbers.length != 1) return null;
    return double.tryParse(numbers.single.group(0)!.replaceAll(' ', ''));
  }

  void _handleRemoteDisconnect() {
    if (_intentionalDisconnect || _connectedDevice == null) return;
    if (_status == BluetoothScaleStatus.reconnecting) return;
    final connection = _connection;
    _connection = null;
    connection?.dispose();
    _weightKg = null;
    _scheduleReconnect();
    notifyListeners();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_reconnectAttempts >= 3 ||
        _adapterState != BtcAdapterState.on ||
        _connectedDevice == null) {
      _status = BluetoothScaleStatus.disconnected;
      _errorMessage =
          'Weighing scale disconnected. Tap reconnect to try again.';
      notifyListeners();
      return;
    }
    _reconnectAttempts++;
    _status = BluetoothScaleStatus.reconnecting;
    _reconnectTimer = Timer(Duration(seconds: _reconnectAttempts * 2), () {
      final device = _connectedDevice;
      if (_intentionalDisconnect || device == null) return;
      final known = _devices[_canonicalDeviceId(device.address)];
      if (known != null) {
        unawaited(connect(known));
      }
    });
  }

  Future<void> reconnect() async {
    final device = _connectedDevice;
    if (device == null) {
      await startScan();
      return;
    }
    final known = _devices[_canonicalDeviceId(device.address)];
    if (known != null) await connect(known);
  }

  Future<void> disconnect() => _disconnectCurrent(intentional: true);

  static String _canonicalDeviceId(String address) => address.toUpperCase();

  Future<void> _disconnectCurrent({required bool intentional}) async {
    _intentionalDisconnect = intentional;
    _reconnectTimer?.cancel();
    _unterminatedFrameTimer?.cancel();
    await _inputSubscription?.cancel();
    await _connectionStateSubscription?.cancel();
    _inputSubscription = null;
    _connectionStateSubscription = null;
    final connection = _connection;
    _connection = null;
    if (connection != null) {
      try {
        await connection.close();
      } catch (_) {
        // The remote device may already be gone.
      }
      connection.dispose();
    }
    _connectedDevice = null;
    _weightKg = null;
    _receiveBuffer = '';
    if (intentional) _status = BluetoothScaleStatus.disconnected;
    notifyListeners();
  }

  void _setError(String message) {
    _status = BluetoothScaleStatus.error;
    _errorMessage = message;
    AppLogger.diagnostic('BT_SCALE_ERROR', message);
    notifyListeners();
  }

  Future<void> openSettings() async {
    await _bluetooth.openAppSettings();
  }

  Future<void> close() async {
    await stopScan();
    await _disconnectCurrent(intentional: true);
    await _adapterSubscription?.cancel();
    await _discoverySubscription?.cancel();
    await _discoveryStateSubscription?.cancel();
    _adapterSubscription = null;
    _discoverySubscription = null;
    _discoveryStateSubscription = null;
    _initialized = false;
    super.dispose();
  }
}
