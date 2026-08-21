import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'home_assets.dart';

const _iconPath = 'assets/icons/home';

/// Navigation drawer implemented from Figma node 2004:1841.
class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key, this.onWalletTap});

  final VoidCallback? onWalletTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 310,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const _ProfileHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _DrawerItem(
                            label: context.l10n.drawerCollection,
                            icon: '$_iconPath/drawer_collection.svg',
                            onTap: () => _close(context),
                          ),
                          _DrawerItem(
                            label: context.l10n.transferRequests,
                            icon: '$_iconPath/drawer_transfer_requests.svg',
                            onTap: () => _close(context),
                          ),
                          _DrawerItem(
                            label: context.l10n.drawerReceipts,
                            icon: '$_iconPath/drawer_receipts.svg',
                            onTap: () => _close(context),
                          ),
                          _DrawerItem(
                            label: context.l10n.walletLogExpense,
                            icon: '$_iconPath/drawer_wallet.svg',
                            onTap: () {
                              _close(context);
                              onWalletTap?.call();
                            },
                          ),
                          _DrawerItem(
                            label: context.l10n.drawerConfigureMaterials,
                            icon: '$_iconPath/drawer_material_list.svg',
                            onTap: () => _close(context),
                          ),
                          _DrawerItem(
                            label: context.l10n.drawerSyncStatus,
                            icon: '$_iconPath/drawer_sync_status.svg',
                            onTap: () => _close(context),
                          ),
                          _DrawerItem(
                            label: context.l10n.notifications,
                            icon: '$_iconPath/drawer_notifications.svg',
                            onTap: () => _close(context),
                          ),
                          _DrawerItem(
                            label: context.l10n.drawerHelpSupport,
                            icon: '$_iconPath/drawer_help_support.svg',
                            onTap: () => _close(context),
                          ),
                          _DrawerItem(
                            label: context.l10n.drawerLogout,
                            icon: '$_iconPath/drawer_logout.svg',
                            textColor: const Color(0xFFE22424),
                            onTap: () => context.go(AppRoutes.login),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const _PoweredBy(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _close(BuildContext context) => Navigator.of(context).pop();
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 134,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            '$_iconPath/drawer_header_background.svg',
            fit: BoxFit.fill,
          ),
          Positioned(
            left: 24,
            top: 62,
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/home_drawer_rahul_patel.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.drawerUserName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 22 / 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.drawerUserRole,
                      style: TextStyle(
                        color: Color(0xFF5FC974),
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.textColor = const Color(0xFF5D5D5D),
  });

  final String label;
  final String icon;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(width: 24, height: 24, child: SvgPicture.asset(icon)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  height: 20 / 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                HomeAssets.drawerChevronRight,
                colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoweredBy extends StatelessWidget {
  const _PoweredBy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 2, thickness: 2, color: Color(0xFFE6EBEE)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            context.l10n.drawerPoweredBy,
            style: const TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 14,
              height: 18 / 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
