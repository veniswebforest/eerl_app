import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/providers/app_lock_provider.dart';
import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import 'package:go_router/go_router.dart';
import '../../home/widgets/home_assets.dart';
import '../widgets/profile_action_card.dart';
import '../widgets/profile_assets.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/assigned_centers_dialog.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/sync_data_dialog.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.isSupervisor = false});

  final bool isSupervisor;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final LocalQueryController<
    ({ProfileModel profile, List<CenterModel> centers, List<MyRoleModel> roles})
  >
  _controller;

  bool get isSupervisor => widget.isSupervisor;

  @override
  void initState() {
    super.initState();
    _controller =
        LocalQueryController(() async {
            final values = await Future.wait([
              EerlLocalRepository.instance.getProfile(),
              EerlLocalRepository.instance.getCenters(),
              EerlLocalRepository.instance.getRoles(),
            ]);
            return (
              profile: values[0] as ProfileModel,
              centers: values[1] as List<CenterModel>,
              roles: values[2] as List<MyRoleModel>,
            );
          })
          ..addListener(_refresh)
          ..load();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeProvider = context.watch<LocaleProvider>();
    final profile = _controller.data?.profile;
    final centers = _controller.data?.centers ?? const <CenterModel>[];
    final roles = _controller.data?.roles ?? const <MyRoleModel>[];
    final role = roles.where(
      (item) =>
          item.roleKey.toUpperCase() == (isSupervisor ? 'SUPERVISOR' : 'AGENT'),
    );
    final roleName = role.isEmpty ? '' : role.first.roleName;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary200,
              AppColors.primary100,
              AppColors.cool50,
              AppColors.cool50,
            ],
            stops: [0, .25, .45, 1],
          ),
        ),

        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(
              top: AppScreenHeaderMetrics.topInset,
              bottom: 112,
            ),
            children: [
              _ProfileHeader(
                localeProvider: localeProvider,
                isSupervisor: isSupervisor,
                profile: profile,
                roleName: roleName,
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(l10n.profileAccountInformation),
                        const SizedBox(height: 12),
                        ProfileInfoCard(
                          items: [
                            ProfileInfoItem(
                              icon: ProfileAssets.facility,
                              label: l10n.profileAssignedFacility,
                              value: isSupervisor
                                  ? centers
                                        .map((center) => center.name)
                                        .join(', ')
                                  : (centers.isEmpty ? '' : centers.first.name),
                              trailingIcon: isSupervisor
                                  ? ProfileAssets.arrowRight
                                  : null,
                              onTap: isSupervisor
                                  ? () => showAssignedCentersDialog(
                                      context,
                                      centers: centers,
                                    )
                                  : null,
                            ),
                            ProfileInfoItem(
                              icon: ProfileAssets.mobile,
                              label: l10n.profileMobileNumber,
                              value: profile?.userPhone ?? '',
                            ),
                            ProfileInfoItem(
                              icon: ProfileAssets.role,
                              label: l10n.profileRole,
                              value: roleName,
                            ),
                            ProfileInfoItem(
                              icon: ProfileAssets.sessionExpiry,
                              label: l10n.profileSessionExpires,
                              value: profile?.sessionExpiresAt ?? '',
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _SectionTitle(l10n.profileActions),
                        const SizedBox(height: 12),
                        ProfileActionCard(
                          key: const Key('profile-sync-data'),
                          icon: ProfileAssets.syncData,
                          arrowIcon: ProfileAssets.arrowRight,
                          title: l10n.profileSyncData,
                          subtitle: l10n.profileSyncSubtitle,
                          onTap: () => showSyncDataDialog(context),
                        ),
                        if (!isSupervisor) ...[
                          const SizedBox(height: 12),
                          const _AppLockToggleCard(),
                        ],
                        const SizedBox(height: 18),
                        _SectionTitle(l10n.profileAccount),
                        const SizedBox(height: 12),
                        ProfileActionCard(
                          key: const Key('profile-logout'),
                          icon: ProfileAssets.logout,
                          arrowIcon: ProfileAssets.logoutArrowRight,
                          title: l10n.drawerLogout,
                          subtitle: l10n.profileLogoutSubtitle,
                          destructive: true,
                          onTap: () => showDialog<void>(
                            context: context,
                            barrierColor: Colors.black.withValues(alpha: 0.56),
                            builder: (_) => const LogoutConfirmationDialog(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ProfileActionCard(
                          key: const Key('profile-delete-account'),
                          icon: ProfileAssets.deleteAccount,
                          arrowIcon: ProfileAssets.logoutArrowRight,
                          title: l10n.profileDeleteAccount,
                          subtitle: l10n.profileDeleteAccountSubtitle,
                          destructive: true,
                          onTap: () {},
                        ),
                      ],
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
  const _ProfileHeader({
    required this.localeProvider,
    required this.isSupervisor,
    required this.profile,
    required this.roleName,
  });

  final LocaleProvider localeProvider;
  final bool isSupervisor;
  final ProfileModel? profile;
  final String roleName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              AppScreenHeader(
                title: context.l10n.profileUserProfile,
                subtitle: context.l10n.profileSubtitle,
                actions: [
                  _ProfileLanguageSelector(provider: localeProvider),
                  InkWell(
                    key: const Key('profile-notification-button'),
                    onTap: () => context.push(AppRoutes.notifications),
                    borderRadius: BorderRadius.circular(24),
                    child: SvgPicture.asset(
                      ProfileAssets.notification,
                      width: 45,
                      height: 45,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 232,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
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
                    const Positioned(
                      right: 18,
                      top: -12,
                      child: _DecorationMark(),
                    ),
                    const Positioned(
                      left: -13,
                      bottom: 20,
                      child: _DecorationMark(),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primary100,
                          backgroundImage:
                              profile?.userPhotoUrl?.isNotEmpty == true
                              ? NetworkImage(profile!.userPhotoUrl!)
                              : null,
                          child: profile?.userPhotoUrl?.isNotEmpty == true
                              ? null
                              : Text(
                                  (profile?.userName?.isNotEmpty == true
                                          ? profile!.userName![0]
                                          : '?')
                                      .toUpperCase(),
                                  style: AppTextStyles.boldH5_24.copyWith(
                                    color: AppColors.primary500,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile?.userName ?? '',
                          style: AppTextStyles.semiboldH6_20.copyWith(
                            color: AppColors.neutral950,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            roleName,
                            style: AppTextStyles.boldH8_14.copyWith(
                              color: AppColors.primary400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileLanguageSelector extends StatelessWidget {
  const _ProfileLanguageSelector({required this.provider});

  final LocaleProvider provider;

  @override
  Widget build(BuildContext context) {
    final selectedCode = provider.locale?.languageCode ?? 'en';
    final shortLabels = {
      'en': context.l10n.profileLanguageEnglishShort,
      'gu': context.l10n.profileLanguageGujaratiShort,
      'hi': context.l10n.profileLanguageHindiShort,
    };
    final menuLabels = shortLabels;

    return InkWell(
      key: const Key('profile-language-selector'),
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showLanguagePopover(
        context,
        selectedCode: selectedCode,
        labels: menuLabels,
      ),
      child: Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cool400),
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              shortLabels[selectedCode]!.substring(0, 2),
              style: AppTextStyles.semiboldH9_14.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(width: 8),
            SvgPicture.asset(HomeAssets.chevronDown, width: 18, height: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _showLanguagePopover(
    BuildContext context, {
    required String selectedCode,
    required Map<String, String> labels,
  }) async {
    await showPopover<void>(
      context: context,
      direction: PopoverDirection.bottom,
      backgroundColor: AppColors.neutral50,
      barrierColor: Colors.transparent,
      radius: 12,
      width: 60,
      height: 110,
      arrowWidth: 0,
      arrowHeight: 0,
      contentDxOffset: 0,
      contentDyOffset: 2,
      shadow: const [
        BoxShadow(
          color: Color(0x24000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
      bodyBuilder: (popoverContext) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cool400),
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 0),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: labels.length,
          separatorBuilder: (_, _) => const Divider(
            height: 0,
            indent: 0,
            endIndent: 0,
            color: AppColors.neutral200,
          ),
          itemBuilder: (_, index) {
            final entry = labels.entries.elementAt(index);
            final selected = entry.key == selectedCode;
            return InkWell(
              key: Key('profile-language-${entry.key}'),
              onTap: () {
                provider.setLocale(Locale(entry.key));
                Navigator.of(popoverContext).pop();
              },
              child: SizedBox(
                height: 35,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      entry.value,
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: selected
                            ? AppColors.primary500
                            : AppColors.neutral950,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
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
              border: Border.all(color: AppColors.primary200),
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
              color: AppColors.primary200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: AppTextStyles.semiboldH9_14.copyWith(color: AppColors.neutral950),
  );
}

class _AppLockToggleCard extends StatelessWidget {
  const _AppLockToggleCard();

  @override
  Widget build(BuildContext context) {
    final appLockProvider = context.watch<AppLockProvider?>();
    final isLocked = appLockProvider?.isLockEnabled ?? false;

    return Material(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: const Color(0x26000000),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 22,
                color: AppColors.primary500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Lock',
                    style: AppTextStyles.semiboldH8_16.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLocked
                        ? 'Device lock enabled on open'
                        : 'Unlock without device lock',
                    style: AppTextStyles.mediumSH8_14.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              key: const Key('profile-app-lock-switch'),
              value: isLocked,
              activeThumbColor: AppColors.primary500,
              activeTrackColor: AppColors.primary500.withValues(alpha: 0.8),
              onChanged: (value) async {
                if (appLockProvider == null) return;
                final success = await appLockProvider.setLockEnabled(value);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                if (!success && value) {
                  final errorMsg =
                      appLockProvider.lastErrorMessage ??
                      'Authentication failed. App lock not enabled.';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMsg),
                      backgroundColor: AppColors.red600,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                } else if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'App lock enabled successfully'
                            : 'App lock disabled',
                      ),
                      backgroundColor: value
                          ? AppColors.primary600
                          : AppColors.neutral700,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
