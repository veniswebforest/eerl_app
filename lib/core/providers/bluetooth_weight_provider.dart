import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:eerl_app/core/bluetooth/bluetooth_scale_service.dart';

class BluetoothWeightProvider extends ChangeNotifier {
  BluetoothWeightProvider({BluetoothScaleService? service})
    : _service = service ?? BluetoothScaleService() {
    _service.addListener(_forwardState);
  }

  static final BluetoothWeightProvider instance = BluetoothWeightProvider();

  final BluetoothScaleService _service;
  int? _targetItem;
  int _measurementRevision = 0;
  double? _lastForwardedWeight;

  BluetoothScaleStatus get status => _service.status;
  List<BluetoothScaleDevice> get devices => _service.devices;
  BluetoothScaleDevice? get connectedDevice {
    final connected = _service.connectedDevice;
    if (connected == null) return null;
    for (final device in devices) {
      if (device.device.address == connected.address) return device;
    }
    return null;
  }

  double? get weightKg => _service.weightKg;
  String? get errorMessage => _service.errorMessage;
  String? get lastRawFrame => _service.lastRawFrame;
  int? get targetItem => _targetItem;
  int get measurementRevision => _measurementRevision;
  bool get isScanning => _service.isScanning;
  bool get isConnected => _service.isConnected;

  void selectTarget(int? item) {
    if (_targetItem == item) return;
    _targetItem = item;
    notifyListeners();
  }

  Future<void> startScan() => _service.startScan();
  Future<void> stopScan() => _service.stopScan();
  Future<void> connect(BluetoothScaleDevice device) => _service.connect(device);
  Future<void> disconnect() => _service.disconnect();
  Future<void> reconnect() => _service.reconnect();
  Future<void> openSettings() => _service.openSettings();

  void _forwardState() {
    final weight = _service.weightKg;
    if (weight != null && weight != _lastForwardedWeight) {
      _lastForwardedWeight = weight;
      _measurementRevision++;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _service.removeListener(_forwardState);
    unawaited(_service.close());
    super.dispose();
  }
}
