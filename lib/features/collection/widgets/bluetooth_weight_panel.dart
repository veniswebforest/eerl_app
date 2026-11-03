import 'package:flutter/material.dart';

import 'package:eerl_app/core/bluetooth/bluetooth_scale_service.dart';
import 'package:eerl_app/core/providers/bluetooth_weight_provider.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class BluetoothWeightPanel extends StatelessWidget {
  const BluetoothWeightPanel({super.key, required this.provider});

  final BluetoothWeightProvider provider;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: provider,
    builder: (context, _) {
      final connected = provider.isConnected;
      final unsupported = provider.status == BluetoothScaleStatus.unsupported;
      final colour = connected
          ? AppColors.primary500
          : unsupported || provider.status == BluetoothScaleStatus.error
          ? AppColors.red500
          : AppColors.neutral600;
      return AnimatedContainer(
        key: const Key('bluetooth-weight-panel'),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: connected ? AppColors.primary50 : Colors.white,
          border: Border.all(
            color: connected ? AppColors.primary500 : AppColors.cool400,
            width: connected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: connected
              ? const [
                  BoxShadow(
                    color: Color(0x1A39AE51),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: connected ? AppColors.primary100 : AppColors.cool100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    connected
                        ? Icons.bluetooth_connected_rounded
                        : Icons.bluetooth_rounded,
                    color: colour,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Bluetooth scale',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.semiboldH9_14,
                            ),
                          ),
                          if (provider.weightKg != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${provider.weightKg!.toStringAsFixed(3)} kg',
                              key: const Key('bluetooth-live-weight'),
                              style: AppTextStyles.semiboldH9_14.copyWith(
                                color: AppColors.primary700,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _statusText(provider),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.regularB8_12.copyWith(
                          color: colour,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 34,
                  child: OutlinedButton(
                    key: const Key('bluetooth-scale-connect'),
                    onPressed: () => _showDevices(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: Size.zero,
                      side: BorderSide(
                        color: connected
                            ? AppColors.primary500
                            : AppColors.cool500,
                      ),
                      foregroundColor: connected
                          ? AppColors.primary700
                          : AppColors.neutral700,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(connected ? 'Change' : 'Find scale'),
                  ),
                ),
                if (provider.connectedDevice != null) ...[
                  const SizedBox(width: 2),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      key: const Key('bluetooth-scale-disconnect'),
                      tooltip: 'Disconnect scale',
                      padding: EdgeInsets.zero,
                      onPressed: provider.disconnect,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ],
            ),
            if (provider.errorMessage?.isNotEmpty == true) ...[
              const SizedBox(height: 6),
              Text(
                provider.errorMessage!,
                key: const Key('bluetooth-scale-error'),
                style: AppTextStyles.regularB8_12.copyWith(
                  color: AppColors.red500,
                ),
              ),
            ],
          ],
        ),
      );
    },
  );

  String _statusText(BluetoothWeightProvider provider) =>
      switch (provider.status) {
        BluetoothScaleStatus.idle => 'Not connected',
        BluetoothScaleStatus.permissionDenied => 'Permission required',
        BluetoothScaleStatus.adapterOff => 'Bluetooth is off',
        BluetoothScaleStatus.scanning => 'Scanning nearby BLE devices…',
        BluetoothScaleStatus.connecting => 'Connecting…',
        BluetoothScaleStatus.connected =>
          'Connected to ${provider.connectedDevice?.name ?? 'scale'}',
        BluetoothScaleStatus.reconnecting => 'Reconnecting…',
        BluetoothScaleStatus.disconnected => 'Disconnected',
        BluetoothScaleStatus.unsupported => 'Unsupported scale protocol',
        BluetoothScaleStatus.error => 'Connection error',
      };

  Future<void> _showDevices(BuildContext context) async {
    await provider.startScan();
    if (!context.mounted) return;
    final devicesScrollController = _NonRestoringScrollController();
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        builder: (context) => SafeArea(
          child: AnimatedBuilder(
            animation: provider,
            builder: (context, _) => SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.65,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 12, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Nearby BLE devices',
                            style: AppTextStyles.semiboldH7_18,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  if (provider.isScanning)
                    const LinearProgressIndicator(minHeight: 2),
                  Expanded(
                    child: provider.devices.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                provider.errorMessage ??
                                    (provider.isScanning
                                        ? 'Searching for nearby BLE devices…'
                                        : 'No named BLE devices found. Make sure the scale is on and in pairing mode.'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: devicesScrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.devices.length,
                            separatorBuilder: (_, _) => const Divider(),
                            itemBuilder: (context, index) {
                              final device = provider.devices[index];
                              final connected =
                                  provider.connectedDevice?.id == device.id;
                              return ListTile(
                                key: ValueKey('ble-device-${device.id}'),
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  connected
                                      ? Icons.bluetooth_connected_rounded
                                      : Icons.bluetooth_rounded,
                                  color: connected
                                      ? AppColors.primary500
                                      : AppColors.neutral600,
                                ),
                                title: Text(device.name),
                                subtitle: Text(
                                  '${device.id}\n'
                                  '${device.device.isSystemDevice == true ? 'System device • ' : ''}'
                                  '${connected ? 'Connected' : 'Disconnected'} • ${device.rssi} dBm',
                                ),
                                isThreeLine: true,
                                trailing: TextButton(
                                  onPressed: connected
                                      ? null
                                      : () async {
                                          await provider.connect(device);
                                          if (context.mounted &&
                                              provider.isConnected) {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                  child: Text(
                                    connected ? 'Connected' : 'Connect',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (provider.status ==
                            BluetoothScaleStatus.permissionDenied)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: provider.openSettings,
                              child: const Text('Open app settings'),
                            ),
                          )
                        else
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: provider.isScanning
                                  ? provider.stopScan
                                  : provider.startScan,
                              icon: Icon(
                                provider.isScanning
                                    ? Icons.stop_rounded
                                    : Icons.refresh_rounded,
                              ),
                              label: Text(
                                provider.isScanning
                                    ? 'Stop scan'
                                    : 'Scan again',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } finally {
      devicesScrollController.dispose();
      await provider.stopScan();
    }
  }
}

/// The nearby-device picker is temporary and should not participate in app
/// state restoration. Avoiding restoration writes also prevents Flutter's
/// restoration manager from being flushed while scan updates change the list
/// during an active fling (a framework debug assertion after hot reload).
class _NonRestoringScrollController extends ScrollController {
  _NonRestoringScrollController() : super(keepScrollOffset: false);

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) => _NonRestoringScrollPosition(
    physics: physics,
    context: context,
    oldPosition: oldPosition,
  );
}

class _NonRestoringScrollPosition extends ScrollPositionWithSingleContext {
  _NonRestoringScrollPosition({
    required super.physics,
    required super.context,
    super.oldPosition,
  }) : super(keepScrollOffset: false);

  @override
  void saveOffset() {
    // This ephemeral list intentionally has no restoration state to flush.
  }
}
