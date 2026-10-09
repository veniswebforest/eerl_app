import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:geolocator/geolocator.dart';

enum HomeLocationState {
  ready,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

class DeviceCoordinates {
  const DeviceCoordinates({
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
  });

  final double latitude;
  final double longitude;
  final DateTime capturedAt;

  Map<String, Object?> toJson() => {
    'lat': latitude,
    'lng': longitude,
    'capturedAt': capturedAt.toUtc().toIso8601String(),
  };

  static DeviceCoordinates? fromJson(Object? value) {
    if (value is! Map) return null;
    final latitude = value['lat'];
    final longitude = value['lng'];
    final capturedAt = DateTime.tryParse(value['capturedAt']?.toString() ?? '');
    if (latitude is! num || longitude is! num || capturedAt == null) {
      return null;
    }
    return DeviceCoordinates(
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      capturedAt: capturedAt,
    );
  }
}

/// Owns foreground location permission and a SQLite-backed last-known fix.
/// GPS itself does not require an internet connection, so a fresh fix can be
/// captured while offline. If a fix temporarily fails, the last saved fix is
/// available for an offline collection.
class DeviceLocationService {
  DeviceLocationService({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  static final DeviceLocationService instance = DeviceLocationService();
  static const _cacheKey = 'device_location_last_fix';
  static const _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    timeLimit: Duration(seconds: 8),
  );

  final AppDatabase _database;

  Future<HomeLocationState> requestOnHomeOpen() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        _log('Permission permanently denied');
        return HomeLocationState.permissionDeniedForever;
      }
      if (permission == LocationPermission.denied) {
        _log('Permission denied');
        return HomeLocationState.permissionDenied;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        _log('Device location service is disabled');
        return HomeLocationState.serviceDisabled;
      }
      final coordinates =
          await _captureAndCache() ?? await _lastKnownAndCache();
      return coordinates == null
          ? HomeLocationState.unavailable
          : HomeLocationState.ready;
    } catch (error) {
      _log('Home location check failed: $error');
      return HomeLocationState.unavailable;
    }
  }

  /// Returns a fresh fix when permission and GPS are available, falling back
  /// to the platform or SQLite cached fix. Collection submission passes
  /// [requestPermission] so the API is never queued before location access has
  /// been attempted from the submission flow itself.
  Future<DeviceCoordinates?> bestAvailableCoordinates({
    bool requestPermission = false,
  }) async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      if (await Geolocator.isLocationServiceEnabled()) {
        final fresh = await _captureAndCache() ?? await _lastKnownAndCache();
        if (fresh != null) return fresh;
      }
      return readCachedCoordinates();
    } catch (error) {
      _log('Fresh fix unavailable; using SQLite cache: $error');
      return readCachedCoordinates();
    }
  }

  Future<DeviceCoordinates?> readCachedCoordinates() async {
    final raw = await _database.getSyncMeta(_cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return DeviceCoordinates.fromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<DeviceCoordinates?> _captureAndCache() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _settings,
      );
      return _cachePosition(position);
    } catch (error) {
      _log('Could not capture current position: $error');
      return null;
    }
  }

  Future<DeviceCoordinates?> _lastKnownAndCache() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;
      _log('Using platform last-known position');
      return _cachePosition(position);
    } catch (error) {
      _log('Last-known position unavailable: $error');
      return null;
    }
  }

  Future<DeviceCoordinates> _cachePosition(Position position) async {
    final coordinates = DeviceCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
      capturedAt: position.timestamp,
    );
    await _database.setSyncMeta(_cacheKey, jsonEncode(coordinates.toJson()));
    _log('Fix cached lat=${coordinates.latitude} lng=${coordinates.longitude}');
    return coordinates;
  }

  static void _log(String message) {
    AppLogger.diagnostic('LOCATION', message);
  }
}
