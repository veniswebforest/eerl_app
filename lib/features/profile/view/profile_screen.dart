import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import '../widgets/profile_action_card.dart';
import '../widgets/profile_assets.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/sync_data_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onNotificationTap});

  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeProvider = context.watch<LocaleProvider>();

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
                onNotificationTap:
                    onNotificationTap ??
                    () => _showLanguagePicker(context, localeProvider),
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
                              value: l10n.profileFacilityValue,
                            ),
                            ProfileInfoItem(
                              icon: ProfileAssets.mobile,
                              label: l10n.profileMobileNumber,
                              value: l10n.profileMobileValue,
                            ),
                            ProfileInfoItem(
                              icon: ProfileAssets.role,
                              label: l10n.profileRole,
                              value: l10n.drawerUserRole,
                            ),
                            ProfileInfoItem(
                              icon: ProfileAssets.sessionExpiry,
                              label: l10n.profileSessionExpires,
                              value: l10n.profileSessionExpiryValue,
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
                          onTap: () => showDialog<void>(
                            context: context,
                            barrierColor: Colors.black.withValues(alpha: 0.56),
                            builder: (_) => const SyncDataDialog(),
                          ),
                        ),
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

  void _showLanguagePicker(BuildContext context, LocaleProvider provider) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.selectLanguage, style: AppTextStyles.semiboldH6_20),
              const SizedBox(height: 12),
              _LanguageOption(
                label: l10n.english,
                selected:
                    provider.locale == null ||
                    provider.locale?.languageCode == 'en',
                onTap: () =>
                    _selectLocale(sheetContext, provider, const Locale('en')),
              ),
              _LanguageOption(
                label: l10n.gujarati,
                selected: provider.locale?.languageCode == 'gu',
                onTap: () =>
                    _selectLocale(sheetContext, provider, const Locale('gu')),
              ),
              _LanguageOption(
                label: l10n.hindi,
                selected: provider.locale?.languageCode == 'hi',
                onTap: () =>
                    _selectLocale(sheetContext, provider, const Locale('hi')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectLocale(
    BuildContext sheetContext,
    LocaleProvider provider,
    Locale locale,
  ) {
    provider.setLocale(locale);
    Navigator.pop(sheetContext);
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onNotificationTap});

  final VoidCallback onNotificationTap;

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
                  InkWell(
                    key: const Key('profile-notification-button'),
                    onTap: onNotificationTap,
                    borderRadius: BorderRadius.circular(24),
                    child: SvgPicture.asset(
                      ProfileAssets.notification,
                      width: 45,
                      height: 45,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              Container(
                height: 220,
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
                        ClipOval(
                          child: Image.asset(
                            ProfileAssets.portrait,
                            width: 112,
                            height: 112,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.drawerUserName,
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
                            context.l10n.drawerUserRole,
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

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label, style: AppTextStyles.mediumSH7_16),
    trailing: selected
        ? const Icon(Icons.check_circle, color: AppColors.primary500)
        : null,
    onTap: onTap,
  );
}
