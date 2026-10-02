import 'package:flutter/foundation.dart';

class LocalQueryController<T> extends ChangeNotifier {
  LocalQueryController(this._loader);

  final Future<T> Function() _loader;
  T? _data;
  Object? _error;
  bool _isLoading = false;
  bool _disposed = false;

  T? get data => _data;
  Object? get error => _error;
  bool get isLoading => _isLoading;
  bool get hasData => _data != null;

  Future<void> load() async {
    if (_isLoading) return;
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
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
