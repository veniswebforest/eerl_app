import 'dart:async';

import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:flutter/foundation.dart';

class LocalQueryController<T> extends ChangeNotifier {
  LocalQueryController(
    this._loader, {
    BootstrapSyncService? bootstrapSyncService,
  }) : _bootstrapSyncService =
           bootstrapSyncService ?? BootstrapSyncService.instance {
    _bootstrapRevision = _bootstrapSyncService.revision;
    _bootstrapSyncService.addListener(_reloadAfterBootstrap);
  }

  final Future<T> Function() _loader;
  final BootstrapSyncService _bootstrapSyncService;
  T? _data;
  Object? _error;
  bool _isLoading = false;
  bool _reloadRequested = false;
  bool _disposed = false;
  late int _bootstrapRevision;

  T? get data => _data;
  Object? get error => _error;
  bool get isLoading => _isLoading;
  bool get hasData => _data != null;

  Future<void> load() async {
    if (_isLoading) {
      // A Bootstrap commit may land while the initial query is still running.
      // Queue one more read so that the stale result cannot win the race.
      _reloadRequested = true;
      return;
    }

    do {
      _reloadRequested = false;
      _isLoading = true;
      _error = null;
      _notify();
      try {
        _data = await _loader();
      } catch (error) {
        _error = error;
      } finally {
        _isLoading = false;
        _notify();
      }
    } while (_reloadRequested && !_disposed);
  }

  void _reloadAfterBootstrap() {
    final revision = _bootstrapSyncService.revision;
    if (_disposed || revision == _bootstrapRevision) return;
    _bootstrapRevision = revision;
    unawaited(load());
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _bootstrapSyncService.removeListener(_reloadAfterBootstrap);
    super.dispose();
  }
}
