import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'home_assets.dart';

/// Bottom navigation bar for the home shell.
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary900,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutral950.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavItem(
                    iconAsset: HomeAssets.navHome,
                    label: context.l10n.home,
                    isActive: true,
                  ),
                  NavItem(
                    iconAsset: HomeAssets.navCollections,
                    label: context.l10n.reports,
                    isActive: false,
                  ),
                  NavItem(
                    iconAsset: HomeAssets.navWallet,
                    label: context.l10n.collections,
                    isActive: false,
                  ),
                  NavItem(
                    iconAsset: HomeAssets.navProfile,
                    label: context.l10n.profile,
                    isActive: false,
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

/// Single nav tab item used inside [HomeBottomNav].
class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.isActive,
  });

  final String iconAsset;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 10 : 12,
          vertical: 8,
        ),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primary700,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(iconAsset, width: 28, height: 28),
            if (isActive) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTextStyles.semiboldH10_12.copyWith(
                  color: AppColors.primary400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
