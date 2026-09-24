import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/role_switcher/widgets/role_switcher_assets.dart';

class RoleSwitchCard extends StatelessWidget {
  const RoleSwitchCard({
    super.key,
    required this.onSwitchRoleTap,
    this.roleTitle = 'Collection Agent',
    this.zoneName = 'EERL - Surat South Zone',
    this.roleIcon = RoleSwitcherAssets.agent,
  });

  final VoidCallback? onSwitchRoleTap;
  final String roleTitle;
  final String zoneName;
  final String roleIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 202,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary200,
            AppColors.primary50,
            AppColors.primary50,
            AppColors.primary50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.roleSwitchTitle,
                  style: AppTextStyles.semiboldH7_18.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.roleSwitchSubtitle,
                  style: AppTextStyles.mediumSH8_14.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 150,
                  height: 44,
                  child: FilledButton(
                    key: const Key('home-switch-role-button'),
                    onPressed: onSwitchRoleTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.l10n.roleSwitchAction,
                      style: AppTextStyles.boldH7_16.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 36,
            child: Image.asset(
              RoleSwitcherAssets.illustration,
              width: 143,
              height: 104,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 62,
            child: ColoredBox(
              color: AppColors.primary100,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RoleDetailRow(icon: roleIcon, label: roleTitle),
                    const SizedBox(height: 6),
                    _RoleDetailRow(
                      icon: RoleSwitcherAssets.location,
                      label: zoneName,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleDetailRow extends StatelessWidget {
  const _RoleDetailRow({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            AppColors.primary500,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: AppColors.neutral950,
            ),
          ),
        ),
      ],
    );
  }
}
