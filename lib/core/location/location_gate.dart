import 'dart:async';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/location/device_location_service.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Checks permission and the GPS switch; [request] may show the OS prompt.
typedef LocationAccessCheck =
    Future<HomeLocationState> Function({bool request});

/// Keeps the whole app behind a full-screen page until location permission
/// is granted and the phone's location (GPS) is on, so every collection can
/// carry latitude/longitude.
///
/// * App open: asks for permission once (the OS prompt).
/// * Back from Settings (resume) and whenever GPS is switched on/off: checks
///   again and removes or shows the page by itself.
/// * The button does what is missing: ask again, open location settings, or
///   open app settings when the permission was denied for good.
class LocationGate extends StatefulWidget {
  const LocationGate({
    super.key,
    required this.child,
    this.checkAccess,
    this.serviceChanges,
    this.openLocationSettings,
    this.openAppSettings,
    this.onReady,
  });

  final Widget child;

  // Injectable for tests; default to [DeviceLocationService].
  final LocationAccessCheck? checkAccess;
  final Stream<bool>? serviceChanges;
  final Future<bool> Function()? openLocationSettings;
  final Future<bool> Function()? openAppSettings;

  /// Called each time access becomes ready (refreshes the cached fix).
  final VoidCallback? onReady;

  @override
  State<LocationGate> createState() => _LocationGateState();
}

class _LocationGateState extends State<LocationGate>
    with WidgetsBindingObserver {
  final _service = DeviceLocationService.instance;

  /// Null until the first check finishes (the app shows as usual meanwhile).
  HomeLocationState? _state;
  StreamSubscription<bool>? _serviceSub;
  var _checking = false;

  LocationAccessCheck get _check => widget.checkAccess ?? _service.checkAccess;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _serviceSub = (widget.serviceChanges ?? _safeServiceStream()).listen(
      (_) => _run(),
    );
    _run(request: true);
  }

  Stream<bool> _safeServiceStream() {
    try {
      return _service.serviceEnabledChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from Settings or the permission prompt.
    if (state == AppLifecycleState.resumed) _run();
  }

  Future<void> _run({bool request = false}) async {
    if (_checking) return;
    _checking = true;
    final result = await _check(request: request);
    _checking = false;
    if (!mounted) return;
    final becameReady =
        result == HomeLocationState.ready && _state != HomeLocationState.ready;
    setState(() => _state = result);
    if (becameReady) {
      (widget.onReady ?? () => unawaited(_service.warmUpFix()))();
    }
  }

  Future<void> _fix() async {
    switch (_state) {
      case HomeLocationState.permissionDenied:
        await _run(request: true);
      case HomeLocationState.serviceDisabled:
        await (widget.openLocationSettings ?? _service.openLocationSettings)();
      case HomeLocationState.permissionDeniedForever:
        await (widget.openAppSettings ?? _service.openAppSettings)();
      case HomeLocationState.ready || HomeLocationState.unavailable || null:
        await _run(request: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceSub?.cancel();
    super.dispose();
  }

  bool get _blocked =>
      _state == HomeLocationState.permissionDenied ||
      _state == HomeLocationState.permissionDeniedForever ||
      _state == HomeLocationState.serviceDisabled;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      if (_blocked)
        Positioned.fill(
          child: _LocationRequiredPage(state: _state!, onFix: _fix),
        ),
    ],
  );
}

/// Full-screen "location needed" page drawn over the app.
class _LocationRequiredPage extends StatelessWidget {
  const _LocationRequiredPage({required this.state, required this.onFix});

  final HomeLocationState state;
  final Future<void> Function() onFix;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (title, message, button) = switch (state) {
      HomeLocationState.serviceDisabled => (
        l10n.locationServiceTitle,
        l10n.locationGateServiceMessage,
        l10n.locationGateTurnOn,
      ),
      HomeLocationState.permissionDeniedForever => (
        l10n.locationPermissionTitle,
        l10n.locationGateSettingsMessage,
        l10n.locationOpenSettings,
      ),
      _ => (
        l10n.locationPermissionTitle,
        l10n.locationGatePermissionMessage,
        l10n.locationGateAllow,
      ),
    };
    return Material(
      key: const Key('location-gate'),
      color: AppColors.backgroundColor,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: AppColors.primary50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      state == HomeLocationState.serviceDisabled
                          ? Icons.location_off_outlined
                          : Icons.my_location,
                      size: 44,
                      color: AppColors.primary500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.boldH6_20.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.mediumSH8_14.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      key: const Key('location-gate-action'),
                      onPressed: onFix,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: AppTextStyles.boldH7_16,
                      ),
                      child: Text(button),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
