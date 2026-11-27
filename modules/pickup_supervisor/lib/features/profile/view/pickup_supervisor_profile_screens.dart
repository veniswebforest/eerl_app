import 'package:flutter/material.dart';
import 'package:eerl_app/shared/widgets/app_language_selector.dart';
import 'package:eerl_app/shared/widgets/cached_app_image.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/profile/data/supervisor_profile_live_data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _package = 'pickup_supervisor';
const _drawerImages = 'assets/images/supervisor/drawer';
const _profileImages = 'assets/images/supervisor/profile';
const _profileIcons = 'assets/icons/supervisor/profile';
const _helpIcons = 'assets/icons/supervisor/help_support';

/// The Sync data flow of the Pickup Supervisor profile: "Sync offline
/// data", then "Data already synced" once Sync now is tapped. Shared by the
/// profile and the drawer's Sync status. Returns true when synced.
Future<bool> showSupervisorSyncDialog(BuildContext context) async {
  // Live: how many changes wait in the outbox; none means already synced.
  final session = OutboundLiveSession.of(context);
  final unsent = session == null ? null : await session.queries.unsentChanges();
  if (!context.mounted) return false;
  if (unsent != 0) {
    final synced = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .58),
      builder: (_) =>
          DriverLocalizationScope(child: _SyncOfflineDialog(unsent: unsent)),
    );
    if (!context.mounted || synced != true) return false;
    await session?.syncNow();
    if (!context.mounted) return false;
  }
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .58),
    builder: (_) =>
        const DriverLocalizationScope(child: _AlreadySyncedDialog()),
  );
  return true;
}

class PickupSupervisorProfileScreen extends StatefulWidget {
  const PickupSupervisorProfileScreen({super.key, this.onLogout});

  /// Called when the user confirms logout (Yes). The host signs out and
  /// navigates; without it, Yes only closes the dialog.
  final Future<void> Function(BuildContext context)? onLogout;

  @override
  State<PickupSupervisorProfileScreen> createState() =>
      _PickupSupervisorProfileScreenState();
}

class _PickupSupervisorProfileScreenState
    extends State<PickupSupervisorProfileScreen> {
  bool _hasPendingSync = true;

  Future<void> _showSync() async {
    final synced = await showSupervisorSyncDialog(context);
    if (mounted && synced) setState(() => _hasPendingSync = false);
  }

  @override
  Widget build(BuildContext context) {
    return OutboundLiveBuilder<SupervisorProfileLive>(
      load: SupervisorProfileLive.load,
      fallback: _page(context, null),
      builder: (context, live, _) => _page(context, live),
    );
  }

  Widget _page(BuildContext context, SupervisorProfileLive? live) {
    final l10n = DriverLocalizations.of(context);
    // Live: the logout warning follows the outbox.
    final pending = live == null ? _hasPendingSync : live.unsent > 0;
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DriverColors.primary200,
            DriverColors.primary100,
            DriverColors.cool50,
            DriverColors.cool50,
          ],
          stops: [0, .25, .45, 1],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHeader(
                onNotifications: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DriverLocalizationScope(
                      child: PickupSupervisorNotificationsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _ProfileHero(l10n: l10n, live: live),
              const SizedBox(height: 28),
              _SectionTitle(l10n.profileAccountInformation),
              const SizedBox(height: 12),
              _InfoCard(l10n: l10n, live: live),
              const SizedBox(height: 24),
              _SectionTitle(l10n.profileActions),
              const SizedBox(height: 12),
              _ActionRow(
                key: const Key('profile-sync-data'),
                iconAsset: '$_profileIcons/sync_data.svg',
                title: l10n.profileSyncData,
                subtitle: l10n.profileSyncDataSubtitle,
                onTap: _showSync,
              ),
              const SizedBox(height: 18),
              _SectionTitle(l10n.profileAccount),
              const SizedBox(height: 12),
              _ActionRow(
                key: const Key('profile-logout'),
                iconAsset: '$_profileIcons/logout.svg',
                arrowAsset: '$_profileIcons/logout_arrow_right.svg',
                title: l10n.profileLogout,
                subtitle: l10n.profileLogoutSubtitle,
                destructive: true,
                onTap: () => showDialog<void>(
                  context: context,
                  barrierColor: Colors.black.withValues(alpha: .58),
                  builder: (_) => DriverLocalizationScope(
                    child: _LogoutDialog(
                      showPendingWarning: pending,
                      onLogout: widget.onLogout == null
                          ? null
                          : () => widget.onLogout!(this.context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onNotifications});

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.profileTitle,
                style: DriverTextStyles.semibold20.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.profileSubtitle,
                style: DriverTextStyles.medium14.copyWith(
                  color: DriverColors.neutral600,
                ),
              ),
            ],
          ),
        ),
        const AppLanguageSelector(),
        const SizedBox(width: 10),
        InkWell(
          key: const Key('profile-notifications'),
          onTap: onNotifications,
          borderRadius: BorderRadius.circular(24),
          child: SvgPicture.asset(
            '$_profileIcons/notification.svg',
            package: _package,
            width: 45,
            height: 45,
          ),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.l10n, this.live});

  final DriverLocalizations l10n;
  final SupervisorProfileLive? live;

  /// The photo, or the first letter of the name, as the main profile does.
  Widget _livePhoto(SupervisorProfileLive live) {
    final initial = Text(
      (live.name.isNotEmpty ? live.name[0] : '?').toUpperCase(),
      style: DriverTextStyles.bold24.copyWith(color: DriverColors.primary500),
    );
    return CircleAvatar(
      radius: 60,
      backgroundColor: DriverColors.primary100,
      child: (live.photoUrl?.isNotEmpty ?? false)
          ? ClipOval(
              child: CachedAppImage(
                source: live.photoUrl,
                width: 120,
                height: 120,
                placeholder: Center(child: initial),
              ),
            )
          : initial,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 232,
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(right: 18, top: -12, child: _DecorationMark()),
          const Positioned(left: -13, bottom: 20, child: _DecorationMark()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (live != null)
                  _livePhoto(live!)
                else
                  ClipOval(
                    child: Image.asset(
                      '$_drawerImages/kiran_shah.png',
                      package: _package,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  live?.name ?? l10n.profileUserName,
                  key: const Key('supervisor-profile-name'),
                  style: DriverTextStyles.semibold20.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: DriverColors.primary100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    live?.roleName ?? l10n.profileRole,
                    style: DriverTextStyles.bold14.copyWith(
                      color: DriverColors.primary400,
                    ),
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

class _DecorationMark extends StatelessWidget {
  const _DecorationMark();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 62,
    height: 72,
    child: Stack(
      children: [
        Positioned(
          left: 5,
          bottom: 4,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: DriverColors.primary200),
            ),
          ),
        ),
        Positioned(
          right: 2,
          top: 0,
          child: Container(
            width: 8,
            height: 38,
            decoration: BoxDecoration(
              color: DriverColors.primary200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: DriverTextStyles.semibold14.copyWith(color: DriverColors.neutral950),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.l10n, this.live});
  final DriverLocalizations l10n;
  final SupervisorProfileLive? live;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            '$_profileIcons/facility.svg',
            l10n.profileMyAreas,
            live?.areas ?? l10n.profileAreasValue,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: DriverColors.cool400),
          const SizedBox(height: 12),
          _InfoRow(
            '$_profileIcons/mobile.svg',
            l10n.profileMobileNumber,
            live?.phone ?? l10n.profileMobileValue,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: DriverColors.cool400),
          const SizedBox(height: 12),
          _InfoRow(
            '$_profileIcons/role.svg',
            l10n.profileRoleLabel,
            live?.roleName ?? l10n.profileRole,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: DriverColors.cool400),
          const SizedBox(height: 12),
          _InfoRow(
            '$_profileIcons/session_expiry.svg',
            l10n.profileSessionExpires,
            live?.sessionExpires ?? l10n.profileSessionValue,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: DriverColors.primary50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(icon, package: _package),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: DriverTextStyles.semibold14.copyWith(
                color: DriverColors.neutral600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DriverTextStyles.medium14.copyWith(
                fontSize: 16,
                color: DriverColors.neutral950,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.arrowAsset = '$_profileIcons/arrow_right.svg',
    this.destructive = false,
  });
  final String iconAsset;
  final String arrowAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Material(
    color: DriverColors.neutral50,
    borderRadius: BorderRadius.circular(12),
    elevation: 2,
    shadowColor: const Color(0x26000000),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: destructive
                    ? DriverColors.red50
                    : DriverColors.primary50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(iconAsset, package: _package),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DriverTextStyles.semibold16.copyWith(
                      color: destructive
                          ? DriverColors.red600
                          : DriverColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DriverTextStyles.medium14.copyWith(
                      color: DriverColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              arrowAsset,
              package: _package,
              width: 24,
              height: 24,
            ),
          ],
        ),
      ),
    ),
  );
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: DriverColors.cool200);
}

class _SyncOfflineDialog extends StatelessWidget {
  const _SyncOfflineDialog({this.unsent});

  /// Changes not sent yet; null shows the design sample.
  final int? unsent;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return _ProfileDialog(
      iconAsset: '$_profileIcons/sync_cloud.svg',
      onClose: () => Navigator.pop(context),
      title: l10n.profileSyncOfflineData,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: DriverColors.cool400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DriverColors.yellow50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(
                    '$_profileIcons/sync_pending_collection.svg',
                    package: _package,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    unsent == null
                        ? l10n.profileChangesNotSent
                        : l10n.liveNotSent(unsent!),
                    style: DriverTextStyles.semibold16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PrimaryButton(
              key: const Key('profile-sync-now'),
              label: l10n.profileSyncNow,
              iconAsset: '$_profileIcons/sync_refresh.svg',
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlreadySyncedDialog extends StatelessWidget {
  const _AlreadySyncedDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return _ProfileDialog(
      iconAsset: '$_profileIcons/sync_cloud.svg',
      onClose: () => Navigator.pop(context),
      title: l10n.profileDataAlreadySynced,
      child: _PrimaryButton(
        label: l10n.profileBack,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog({required this.showPendingWarning, this.onLogout});
  final bool showPendingWarning;
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: DriverColors.neutral50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 335),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                '$_profileIcons/logout_dialog.svg',
                package: _package,
                width: 57.8123,
                height: 55.5,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  l10n.profileLogoutQuestion,
                  textAlign: TextAlign.center,
                  style: DriverTextStyles.bold20.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.profileLogoutMessage,
                textAlign: TextAlign.center,
                style: DriverTextStyles.medium14.copyWith(
                  color: DriverColors.cool950,
                ),
              ),
              if (showPendingWarning) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DriverColors.red50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        '$_profileIcons/logout_warning.svg',
                        package: _package,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.profileSendChangesWarning,
                          style: DriverTextStyles.bold14.copyWith(
                            color: DriverColors.red600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _SecondaryButton(
                      label: l10n.profileNo,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PrimaryButton(
                      key: const Key('profile-logout-yes'),
                      label: l10n.profileYes,
                      color: DriverColors.red500,
                      onPressed: () async {
                        // Close the dialog first, then let the host sign out.
                        final logout = onLogout;
                        Navigator.pop(context);
                        if (logout != null) await logout();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileDialog extends StatelessWidget {
  const _ProfileDialog({
    required this.iconAsset,
    required this.title,
    required this.child,
    this.onClose,
  });
  final String iconAsset;
  final String title;
  final Widget child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
    backgroundColor: DriverColors.neutral50,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 335),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  package: _package,
                  width: 79,
                  height: 53,
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: DriverTextStyles.bold20.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
            if (onClose != null)
              Positioned(
                right: 0,
                top: 0,
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: SvgPicture.asset(
                      '$_profileIcons/sync_close.svg',
                      package: _package,
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class PickupSupervisorNotificationsScreen extends StatelessWidget {
  const PickupSupervisorNotificationsScreen({
    super.key,
    this.showEmpty = false,
  });
  final bool showEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Scaffold(
      backgroundColor: DriverColors.neutral50,
      appBar: showEmpty
          ? null
          : _ProfileAppBar(title: l10n.profileNotifications),
      body: showEmpty
          ? const _EmptyNotifications()
          : const _NotificationsList(),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _SectionTitle(l10n.profileToday),
        const SizedBox(height: 10),
        _NotificationCard(
          items: [
            _NotificationData(
              Icons.cloud_off_outlined,
              DriverColors.neutral600,
              DriverColors.neutral100,
              l10n.profileOfflineMode,
              l10n.profileOfflineModeMessage,
              l10n.profileJustNow,
            ),
            _NotificationData(
              Icons.add_location_alt_outlined,
              DriverColors.secondary500,
              DriverColors.secondary100,
              l10n.profileNewSourceUnassigned,
              l10n.profileNewSourceMessage,
              l10n.profileTenMinutesAgo,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionTitle(l10n.profileEarlier),
        const SizedBox(height: 10),
        _NotificationCard(
          items: [
            _NotificationData(
              Icons.report_problem_outlined,
              DriverColors.primary500,
              DriverColors.primary50,
              l10n.profileDriverEscalation,
              l10n.profileDriverEscalationMessage,
              l10n.profileYesterdayTime,
            ),
            _NotificationData(
              Icons.block_rounded,
              DriverColors.primary500,
              DriverColors.primary50,
              l10n.profilePickupSkipped,
              l10n.profilePickupSkippedMessage,
              l10n.profilePickupSkippedTime,
            ),
          ],
        ),
      ],
    );
  }
}

class _NotificationData {
  const _NotificationData(
    this.icon,
    this.color,
    this.backgroundColor,
    this.title,
    this.message,
    this.time,
  );
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String title;
  final String message;
  final String time;
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.items});
  final List<_NotificationData> items;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: DriverColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _NotificationTile(data: items[i]),
          if (i != items.length - 1) const _CardDivider(),
        ],
      ],
    ),
  );
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.data});
  final _NotificationData data;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: data.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(data.icon, color: data.color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: DriverTextStyles.semibold16.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.message,
                style: DriverTextStyles.regular14.copyWith(
                  color: DriverColors.neutral600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.time,
                style: DriverTextStyles.medium12.copyWith(
                  color: DriverColors.primary500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 184,
              height: 218,
              child: Stack(
                children: [
                  Positioned(
                    left: 4,
                    top: 0,
                    width: 178,
                    height: 217,
                    child: SvgPicture.asset(
                      '$_profileImages/notifications_background.svg',
                      package: _package,
                    ),
                  ),
                  Positioned(
                    left: 31,
                    top: 31,
                    width: 109,
                    height: 180,
                    child: SvgPicture.asset(
                      '$_profileImages/notifications_device.svg',
                      package: _package,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 74,
                    width: 115,
                    height: 101,
                    child: SvgPicture.asset(
                      '$_profileImages/notifications_bell.svg',
                      package: _package,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.profileAllCaughtUp,
              textAlign: TextAlign.center,
              style: DriverTextStyles.bold24.copyWith(
                color: DriverColors.neutral950,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.profileNoNotifications,
              textAlign: TextAlign.center,
              style: DriverTextStyles.medium14.copyWith(
                color: DriverColors.neutral700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PickupSupervisorHelpSupportScreen extends StatefulWidget {
  const PickupSupervisorHelpSupportScreen({super.key});

  @override
  State<PickupSupervisorHelpSupportScreen> createState() =>
      _PickupSupervisorHelpSupportScreenState();
}

class _PickupSupervisorHelpSupportScreenState
    extends State<PickupSupervisorHelpSupportScreen> {
  int _expanded = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final faqs = [
      (l10n.profileFaqDailyTrips, l10n.profileFaqDailyTripsAnswer),
      (l10n.profileFaqSwapDriver, l10n.profileFaqSwapDriverAnswer),
      (l10n.profileFaqUnassigned, l10n.profileFaqUnassignedAnswer),
      (l10n.profileFaqSkipping, l10n.profileFaqSkippingAnswer),
    ];
    return Scaffold(
      backgroundColor: DriverColors.neutral50,
      appBar: _ProfileAppBar(title: l10n.profileHelpSupport),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _SupportCard(
            iconAsset: '$_helpIcons/call.svg',
            externalAsset: '$_helpIcons/external_blue.svg',
            color: DriverColors.secondary500,
            backgroundColor: DriverColors.secondary100,
            title: l10n.profileCallSupport,
            subtitle: l10n.profileCallSupportSubtitle,
          ),
          const SizedBox(height: 12),
          _SupportCard(
            iconAsset: '$_helpIcons/whatsapp.svg',
            externalAsset: '$_helpIcons/external_green.svg',
            color: DriverColors.primary500,
            backgroundColor: DriverColors.primary50,
            title: l10n.profileInstantHelp,
            subtitle: l10n.profileInstantHelpSubtitle,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.profileFaqTitle,
            style: DriverTextStyles.semibold18.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DriverColors.neutral50,
              border: Border.all(color: DriverColors.cool400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (var i = 0; i < faqs.length; i++) ...[
                  InkWell(
                    key: Key('profile-faq-$i'),
                    onTap: () =>
                        setState(() => _expanded = _expanded == i ? -1 : i),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: i == 0 ? 0 : 16,
                        bottom: i == faqs.length - 1 ? 0 : 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  faqs[i].$1,
                                  style: DriverTextStyles.semibold14.copyWith(
                                    color: DriverColors.neutral950,
                                  ),
                                ),
                              ),
                              SvgPicture.asset(
                                _expanded == i
                                    ? '$_helpIcons/remove.svg'
                                    : '$_helpIcons/add.svg',
                                package: _package,
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                          if (_expanded == i) ...[
                            const SizedBox(height: 10),
                            Text(
                              faqs[i].$2,
                              style: DriverTextStyles.medium14.copyWith(
                                color: DriverColors.neutral600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (i != faqs.length - 1)
                    const Divider(height: 1, color: DriverColors.cool400),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.iconAsset,
    required this.externalAsset,
    required this.color,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
  });
  final String iconAsset;
  final String externalAsset;
  final Color color;
  final Color backgroundColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: DriverColors.neutral50,
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset(iconAsset, package: _package),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DriverTextStyles.semibold16.copyWith(
                  color: DriverColors.neutral900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: DriverTextStyles.semibold14.copyWith(
                  color: DriverColors.neutral600,
                ),
              ),
            ],
          ),
        ),
        SvgPicture.asset(
          externalAsset,
          package: _package,
          width: 12,
          height: 12,
        ),
      ],
    ),
  );
}

class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ProfileAppBar({required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: DriverColors.neutral50,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leadingWidth: 68,
    leading: Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Material(
        color: DriverColors.primary500,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              '$_helpIcons/back.svg',
              package: _package,
              width: 20,
              height: 20,
            ),
          ),
        ),
      ),
    ),
    title: Text(
      title,
      style: DriverTextStyles.semibold20.copyWith(
        color: DriverColors.neutral950,
      ),
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconAsset,
    this.color = DriverColors.primary500,
  });
  final String label;
  final VoidCallback onPressed;
  final String? iconAsset;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: DriverColors.neutral50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: iconAsset != null
          ? SvgPicture.asset(
              iconAsset!,
              package: _package,
              width: 24,
              height: 24,
            )
          : const SizedBox.shrink(),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: DriverTextStyles.bold16,
      ),
    ),
  );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: DriverColors.primary700,
        side: const BorderSide(color: DriverColors.primary500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: DriverTextStyles.bold16,
      ),
    ),
  );
}
