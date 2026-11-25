import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _iconRoot = 'assets/icons/supervisor/drawer';
const _imageRoot = 'assets/images/supervisor/drawer';
const _assetPackage = 'pickup_supervisor';

/// Static Pickup Supervisor drawer matching Figma node 7028:2245.
class PickupSupervisorHomeDrawer extends StatelessWidget {
  const PickupSupervisorHomeDrawer({super.key, this.onItemSelected});

  final ValueChanged<String>? onItemSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final items = <_DrawerItemData>[
      _DrawerItemData(
        keyName: 'unassigned-sources',
        label: l10n.supervisorDrawerUnassignedSources,
        icon: '$_iconRoot/unassigned_sources.svg',
      ),
      _DrawerItemData(
        keyName: 'routes',
        label: l10n.supervisorDrawerRoutes,
        icon: '$_iconRoot/routes.svg',
      ),
      _DrawerItemData(
        keyName: 'drivers-labour',
        label: l10n.supervisorDrawerDriversLabour,
        icon: '$_iconRoot/drivers_labour.svg',
      ),
      _DrawerItemData(
        keyName: 'issues',
        label: l10n.supervisorDrawerIssues,
        icon: '$_iconRoot/issues.svg',
      ),
      _DrawerItemData(
        keyName: 'cash-payments',
        label: l10n.supervisorDrawerCashPayments,
        icon: '$_iconRoot/cash_payments.svg',
      ),
      _DrawerItemData(
        keyName: 'extra-pickup',
        label: l10n.supervisorDrawerExtraPickupRequests,
        icon: '$_iconRoot/extra_pickup.svg',
      ),
      _DrawerItemData(
        keyName: 'sync-status',
        label: l10n.supervisorDrawerSyncStatus,
        icon: '$_iconRoot/sync_status.svg',
      ),
      _DrawerItemData(
        keyName: 'notifications',
        label: l10n.supervisorDrawerNotifications,
        icon: '$_iconRoot/notifications.svg',
      ),
      _DrawerItemData(
        keyName: 'help-support',
        label: l10n.supervisorDrawerHelpSupport,
        icon: '$_iconRoot/help_support.svg',
      ),
      _DrawerItemData(
        keyName: 'logout',
        label: l10n.supervisorDrawerLogout,
        icon: '$_iconRoot/logout.svg',
        isDestructive: true,
      ),
    ];

    return Drawer(
      key: const Key('supervisor-home-drawer'),
      width: 310,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      backgroundColor: DriverColors.neutral50,
      child: Column(
        children: [
          _DrawerProfileHeader(l10n: l10n),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _DrawerNavigationItem(
                        item: items[index],
                        onTap: () {
                          Navigator.pop(context);
                          onItemSelected?.call(items[index].keyName);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: DriverColors.cool200, width: 2),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Text(
                      l10n.supervisorDrawerPoweredBy,
                      style: DriverTextStyles.semibold14.copyWith(
                        color: DriverColors.neutral300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerProfileHeader extends StatelessWidget {
  const _DrawerProfileHeader({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 134,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            '$_iconRoot/header_background.svg',
            package: _assetPackage,
            fit: BoxFit.fill,
          ),
          Positioned(
            left: 24,
            top: 62,
            right: 24,
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    '$_imageRoot/kiran_shah.png',
                    package: _assetPackage,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.supervisorDrawerUserName,
                        key: const Key('supervisor-drawer-user-name'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DriverTextStyles.semibold18.copyWith(
                          color: DriverColors.neutral50,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.supervisorDrawerRole,
                        key: const Key('supervisor-drawer-user-role'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DriverTextStyles.semibold12.copyWith(
                          color: DriverColors.primary400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerNavigationItem extends StatelessWidget {
  const _DrawerNavigationItem({required this.item, required this.onTap});

  final _DrawerItemData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = item.isDestructive
        ? DriverColors.red600
        : DriverColors.neutral600;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('supervisor-drawer-${item.keyName}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              SvgPicture.asset(
                item.icon,
                package: _assetPackage,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: foreground,
                  ),
                ),
              ),
              RotatedBox(
                quarterTurns: 3,
                child: SvgPicture.asset(
                  item.isDestructive
                      ? '$_iconRoot/logout_chevron.svg'
                      : '$_iconRoot/chevron_right.svg',
                  package: _assetPackage,
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItemData {
  const _DrawerItemData({
    required this.keyName,
    required this.label,
    required this.icon,
    this.isDestructive = false,
  });

  final String keyName;
  final String label;
  final String icon;
  final bool isDestructive;
}
