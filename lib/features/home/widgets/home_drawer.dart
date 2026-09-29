import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:eerl_app/features/dashboard/provider/dashboard_navigation_provider.dart';
import 'package:eerl_app/features/profile/widgets/logout_confirmation_dialog.dart';
import 'package:eerl_app/features/verification/model/verification_entry.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'home_assets.dart';

const _iconPath = 'assets/icons/home';
const _supervisorDrawerIconPath = 'assets/icons/home/supervisor/drawer';

enum HomeDrawerRole { collectionAgent, supervisor }

/// Role-aware navigation drawer based on Figma nodes 5114:3146 and 5114:3594.
class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  bool _tasksExpanded = false;
  bool _supervisorVerificationExpanded = false;
  bool _supervisorTasksExpanded = false;

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<DashboardNavigationProvider>();
    final role = navigation.activeRole == DashboardUserRole.supervisor
        ? HomeDrawerRole.supervisor
        : HomeDrawerRole.collectionAgent;
    final roleTitle = role == HomeDrawerRole.supervisor
        ? context.l10n.roleCollectionSupervisor
        : context.l10n.drawerUserRole;

    return Drawer(
      width: 310,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _ProfileHeader(roleTitle: roleTitle, role: role),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (role == HomeDrawerRole.supervisor)
                            ..._buildSupervisorItems(context)
                          else ...[
                            _DrawerItem(
                              key: const Key('drawer-collection'),
                              label: context.l10n.drawerCollection,
                              icon: '$_iconPath/drawer_collection.svg',
                              onTap: () {
                                _close(context);
                                navigation.selectPage('collections');
                              },
                            ),
                            _DrawerItem(
                              key: const Key('drawer-transfer-requests'),
                              label: context.l10n.transferRequests,
                              icon: '$_iconPath/drawer_transfer_requests.svg',
                              onTap: () {
                                _close(context);
                                context.push(AppRoutes.transferRequests);
                              },
                            ),
                            _DrawerItem(
                              key: const Key('drawer-receipts'),
                              label: context.l10n.drawerReceipts,
                              icon: '$_iconPath/drawer_receipts.svg',
                              onTap: () {
                                _close(context);
                                navigation.selectPage('records');
                              },
                            ),
                            _DrawerItem(
                              label: context.l10n.walletLogExpense,
                              icon: '$_iconPath/drawer_wallet.svg',
                              onTap: () {
                                _close(context);
                                context.push(AppRoutes.wallet);
                              },
                            ),
                            _DrawerItem(
                              key: const Key('drawer-configure-material'),
                              label: context.l10n.drawerConfigureMaterials,
                              icon: '$_iconPath/drawer_material_list.svg',
                              onTap: () {
                                _close(context);
                                context.push(AppRoutes.configureMaterials);
                              },
                            ),
                            _DrawerItem(
                              key: const Key('drawer-ragpicker-directory'),
                              label: context.l10n.drawerRagpickerDirectory,
                              icon: 'assets/icons/profile/role.svg',
                              onTap: () {
                                _close(context);
                                context.push(AppRoutes.ragpickerDirectory);
                              },
                            ),
                            _DrawerExpandableItem(
                              icon: '$_iconPath/pending_task.svg',

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
                                  style: AppTextStyles.semiboldH9_14.copyWith(
                                    color: AppColors.neutral950,
                                  ),
                                  onTap: () {
                                    _close(context);
                                    context.push(AppRoutes.tasks);
                                  },
                                ),
                                _DrawerChildItem(
                                  key: const Key('drawer-requests'),
                                  label: context.l10n.drawerRequests,
                                  style: AppTextStyles.semiboldH9_14.copyWith(
                                    color: AppColors.neutral950,
                                  ),
                                  onTap: () {
                                    _close(context);
                                    context.push(AppRoutes.requests);
                                  },
                                ),
                              ],
                            ),
                            _DrawerItem(
                              key: const Key('drawer-sync-status'),
                              label: context.l10n.drawerSyncStatus,
                              icon: '$_iconPath/drawer_sync_status.svg',
                              onTap: () {
                                _close(context);
                                navigation.selectPage('profile');
                              },
                            ),
                            _DrawerItem(
                              key: const Key('drawer-notifications'),
                              label: context.l10n.notifications,
                              icon: '$_iconPath/drawer_notifications.svg',
                              onTap: () {
                                _close(context);
                                context.push(AppRoutes.notifications);
                              },
                            ),
                            _DrawerItem(
                              key: const Key('drawer-help-support'),
                              label: context.l10n.drawerHelpSupport,
                              icon: '$_iconPath/drawer_help_support.svg',
                              onTap: () {
                                _close(context);
                                context.push(AppRoutes.helpSupport);
                              },
                            ),
                            _DrawerItem(
                              key: const Key('drawer-logout'),
                              label: context.l10n.drawerLogout,
                              icon: '$_iconPath/drawer_logout.svg',
                              textColor: const Color(0xFFE22424),
                              onTap: () {
                                _close(context);
                                _showLogoutDialog(context);
                              },
                            ),
                          ],
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

  List<Widget> _buildSupervisorItems(BuildContext context) {
    final items = <Widget>[
      _DrawerItem(
        key: const Key('drawer-supervisor-stock'),
        label: context.l10n.drawerSupervisorStock,
        icon: '$_supervisorDrawerIconPath/stock.svg',
        onTap: () {
          _close(context);
          context.read<DashboardNavigationProvider>().selectPage(
            'supervisor-stock',
          );
        },
      ),
      _SupervisorExpandableItem(
        key: const Key('drawer-supervisor-verification'),
        label: context.l10n.drawerSupervisorVerification,
        collapsedIcon: '$_supervisorDrawerIconPath/verification.svg',
        expandedIcon: '$_supervisorDrawerIconPath/verification_active.svg',
        expanded: _supervisorVerificationExpanded,
        childGap: 4,
        onTap: () => setState(
          () => _supervisorVerificationExpanded =
              !_supervisorVerificationExpanded,
        ),
        children: [
          _SupervisorChildItem(
            key: const Key('drawer-supervisor-pending-verification'),
            label: context.l10n.transferTimelinePendingVerification,
            onTap: () {
              _close(context);
              context.read<DashboardNavigationProvider>().showVerification(
                VerificationListStatus.pending,
              );
            },
          ),
          _SupervisorChildItem(
            key: const Key('drawer-supervisor-verified-entries'),
            label: context.l10n.verifiedEntries,
            onTap: () {
              _close(context);
              context.read<DashboardNavigationProvider>().showVerification(
                VerificationListStatus.processed,
              );
            },
          ),
        ],
      ),
      _SupervisorExpandableItem(
        key: const Key('drawer-supervisor-tasks-requests'),
        label: context.l10n.drawerTasksRequests,
        collapsedIcon: '$_supervisorDrawerIconPath/tasks_requests.svg',
        expandedIcon: '$_supervisorDrawerIconPath/tasks_requests_active.svg',
        expanded: _supervisorTasksExpanded,
        onTap: () => setState(
          () => _supervisorTasksExpanded = !_supervisorTasksExpanded,
        ),
        children: [
          _SupervisorChildItem(
            key: const Key('drawer-supervisor-tasks'),
            label: context.l10n.drawerTasks,
            onTap: () {
              _close(context);
              context.push(AppRoutes.supervisorTasks);
            },
          ),
          _SupervisorChildItem(
            key: const Key('drawer-supervisor-requests'),
            label: context.l10n.drawerRequests,
            onTap: () {
              _close(context);
              context.push(AppRoutes.supervisorRequests);
            },
          ),
        ],
      ),
      _DrawerItem(
        key: const Key('drawer-supervisor-expense'),
        label: context.l10n.drawerSupervisorExpense,
        icon: '$_supervisorDrawerIconPath/expense.svg',
        showBadge: true,
        onTap: () {
          _close(context);
          context.push(AppRoutes.supervisorExpense);
        },
      ),
      _DrawerItem(
        key: const Key('drawer-supervisor-mrf-person-list'),
        label: context.l10n.drawerSupervisorMrfPersonList,
        icon: '$_supervisorDrawerIconPath/mrf_person.svg',
        onTap: () {
          _close(context);
          context.push(AppRoutes.supervisorMrfPeople);
        },
      ),
      _DrawerItem(
        key: const Key('drawer-supervisor-d2d-vehicle-list'),
        label: context.l10n.drawerSupervisorD2dVehicleList,
        icon: '$_supervisorDrawerIconPath/d2d_vehicle.svg',
        onTap: () {
          _close(context);
        },
      ),
      _DrawerItem(
        key: const Key('drawer-supervisor-ragpicker-directory'),
        label: context.l10n.drawerRagpickerDirectory,
        icon: '$_supervisorDrawerIconPath/ragpicker.svg',
        onTap: () {
          _close(context);
          context.push(AppRoutes.ragpickerDirectory);
        },
      ),
      _DrawerItem(
        key: const Key('drawer-supervisor-agent-status'),
        label: context.l10n.drawerSupervisorAgentStatus,
        icon: '$_supervisorDrawerIconPath/agent_status.svg',
        onTap: () {
          _close(context);
        },
      ),
      _DrawerItem(
        key: const Key('drawer-sync-status'),
        label: context.l10n.drawerSyncStatus,
        icon: '$_supervisorDrawerIconPath/sync_status.svg',
        onTap: () {
          _close(context);
          context.read<DashboardNavigationProvider>().selectPage('profile');
        },
      ),
      _DrawerItem(
        key: const Key('drawer-notifications'),
        label: context.l10n.notifications,
        icon: '$_supervisorDrawerIconPath/notifications.svg',
        onTap: () {
          _close(context);
          context.push(AppRoutes.notifications);
        },
      ),
      _DrawerItem(
        key: const Key('drawer-help-support'),
        label: context.l10n.drawerHelpSupport,
        icon: '$_supervisorDrawerIconPath/help_support.svg',
        onTap: () {
          _close(context);
          context.push(AppRoutes.helpSupport);
        },
      ),
      _DrawerItem(
        key: const Key('drawer-logout'),
        label: context.l10n.drawerLogout,
        icon: '$_supervisorDrawerIconPath/logout.svg',
        chevronColor: const Color(0xFFE22424),
        textColor: const Color(0xFFE22424),
        onTap: () {
          _close(context);
          _showLogoutDialog(context);
        },
      ),
    ];

    return [
      for (var index = 0; index < items.length; index++) ...[
        items[index],
        if (index != items.length - 1) const SizedBox(height: 12),
      ],
    ];
  }

  void _showLogoutDialog(BuildContext context) => showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.56),
    builder: (_) => const LogoutConfirmationDialog(),
  );
}

class _SupervisorExpandableItem extends StatelessWidget {
  const _SupervisorExpandableItem({
    super.key,
    required this.label,
    required this.collapsedIcon,
    required this.expandedIcon,
    required this.expanded,
    required this.onTap,
    required this.children,
    this.childGap = 0,
  });

  final String label;
  final String collapsedIcon;
  final String expandedIcon;
  final bool expanded;
  final VoidCallback onTap;
  final List<Widget> children;
  final double childGap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: expanded ? const Color(0xFFF2FBF3) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: expanded ? const Color(0xFFC3EFCB) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      expanded ? expandedIcon : collapsedIcon,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: expanded
                            ? AppColors.neutral950
                            : AppColors.neutral600,
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
                      expanded
                          ? '$_supervisorDrawerIconPath/expanded_chevron.svg'
                          : HomeAssets.drawerChevronRight,
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
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < children.length;
                          index++
                        ) ...[
                          children[index],
                          if (index != children.length - 1 && childGap > 0)
                            SizedBox(height: childGap),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SupervisorChildItem extends StatelessWidget {
  const _SupervisorChildItem({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.neutral950,
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                HomeAssets.drawerChevronRight,
                colorFilter: const ColorFilter.mode(
                  AppColors.neutral950,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerExpandableItem extends StatelessWidget {
  const _DrawerExpandableItem({
    super.key,
    required this.label,
    required this.expanded,

    required this.onTap,
    required this.children,
    required this.icon,
  });

  final String label;
  final bool expanded;
  final String icon;

  final VoidCallback onTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final color = expanded ? AppColors.primary500 : AppColors.neutral600;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),

      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: expanded ? AppColors.primary200 : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      icon,
                      colorFilter: ColorFilter.mode(
                        expanded ? AppColors.primary400 : AppColors.neutral600,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),

                  // pending_task.svg
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semiboldH8_16.copyWith(
                        color: expanded
                            ? AppColors.neutral950
                            : AppColors.neutral600,
                      ),
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
                      color: Colors.white,
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
  const _DrawerChildItem({
    super.key,
    required this.label,
    required this.onTap,
    this.style,
  });

  final String label;
  final VoidCallback onTap;
  final TextStyle? style;

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
              style:
                  style ??
                  AppTextStyles.mediumSH8_14.copyWith(
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
  const _ProfileHeader({this.roleTitle, required this.role});

  final String? roleTitle;
  final HomeDrawerRole role;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 134,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            role == HomeDrawerRole.supervisor
                ? '$_supervisorDrawerIconPath/header_background.svg'
                : '$_iconPath/drawer_header_background.svg',
            fit: BoxFit.fill,
          ),
          Positioned(
            left: 24,
            top: 62,
            child: Row(
              children: [
                if (role == HomeDrawerRole.supervisor)
                  ClipOval(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned(
                            left: -5.78,
                            top: -5.13,
                            width: 59.57,
                            height: 63.20,
                            child: Image.asset(
                              'assets/images/home_drawer_bhavesh_shah.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
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
                      role == HomeDrawerRole.supervisor
                          ? context.l10n.drawerSupervisorUserName
                          : context.l10n.drawerUserName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 22 / 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleTitle ?? context.l10n.drawerUserRole,
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
    this.textColor = AppColors.neutral600,
    this.chevronColor,
    this.showBadge = false,
  });

  final String label;
  final String icon;
  final Color textColor;
  final Color? chevronColor;
  final bool showBadge;
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(width: 24, height: 24, child: SvgPicture.asset(icon)),
                if (showBadge)
                  Positioned(
                    left: 16,
                    top: -12,
                    child: SvgPicture.asset(
                      '$_supervisorDrawerIconPath/expense_badge.svg',
                      width: 10,
                      height: 10,
                    ),
                  ),
              ],
            ),
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
                colorFilter: chevronColor == null
                    ? null
                    : ColorFilter.mode(chevronColor!, BlendMode.srcIn),
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
