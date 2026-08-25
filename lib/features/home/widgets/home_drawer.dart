import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'home_assets.dart';

const _iconPath = 'assets/icons/home';

/// Navigation drawer implemented from Figma node 2004:1841.
class HomeDrawer extends StatefulWidget {
  const HomeDrawer({
    super.key,
    this.onWalletTap,
    this.onHelpSupportTap,
    this.onConfigureMaterialTap,
    this.onTasksTap,
    this.onRequestsTap,
  });

  final VoidCallback? onWalletTap;
  final VoidCallback? onHelpSupportTap;
  final VoidCallback? onConfigureMaterialTap;
  final VoidCallback? onTasksTap;
  final VoidCallback? onRequestsTap;

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  bool _tasksExpanded = false;

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
                              widget.onWalletTap?.call();
                            },
                          ),
                          _DrawerItem(
                            key: const Key('drawer-configure-material'),
                            label: context.l10n.drawerConfigureMaterials,
                            icon: '$_iconPath/drawer_material_list.svg',
                            onTap: () {
                              _close(context);
                              widget.onConfigureMaterialTap?.call();
                            },
                          ),
                          _DrawerExpandableItem(
                            key: const Key('drawer-tasks-requests'),
                            label: context.l10n.drawerTasksRequests,
                            expanded: _tasksExpanded,
                            onTap: () => setState(
                              () => _tasksExpanded = !_tasksExpanded,
                            ),
                            children: [
                              _DrawerChildItem(
                                key: const Key('drawer-tasks'),
                                label: context.l10n.drawerTasks,
                                onTap: () {
                                  _close(context);
                                  widget.onTasksTap?.call();
                                },
                              ),
                              _DrawerChildItem(
                                key: const Key('drawer-requests'),
                                label: context.l10n.drawerRequests,
                                onTap: () {
                                  _close(context);
                                  widget.onRequestsTap?.call();
                                },
                              ),
                            ],
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
                            key: const Key('drawer-help-support'),
                            label: context.l10n.drawerHelpSupport,
                            icon: '$_iconPath/drawer_help_support.svg',
                            onTap: () {
                              _close(context);
                              widget.onHelpSupportTap?.call();
                            },
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

class _DrawerExpandableItem extends StatelessWidget {
  const _DrawerExpandableItem({
    super.key,
    required this.label,
    required this.expanded,
    required this.onTap,
    required this.children,
  });

  final String label;
  final bool expanded;
  final VoidCallback onTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final color = expanded ? AppColors.primary500 : AppColors.neutral600;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: expanded ? AppColors.primary200 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      Icons.pending_actions_outlined,
                      size: 24,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semiboldH8_16.copyWith(color: color),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? .25 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: SvgPicture.asset(
                      HomeAssets.drawerChevronRight,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.topCenter,
            child: expanded
                ? Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(8),
                      ),
                    ),
                    child: Column(children: children),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _DrawerChildItem extends StatelessWidget {
  const _DrawerChildItem({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.mediumSH8_14.copyWith(
                color: AppColors.neutral900,
              ),
            ),
          ),
          SvgPicture.asset(
            HomeAssets.drawerChevronRight,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.neutral900,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    ),
  );
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
    super.key,
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
