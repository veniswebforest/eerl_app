import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Bottom navigation bar for the home shell.
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              NavItem(icon: Icons.home_filled, label: 'Home', isActive: true),
              NavItem(icon: Icons.bar_chart_rounded, label: 'Reports', isActive: false),
              NavItem(icon: Icons.inventory_2_outlined, label: 'Collections', isActive: false),
              NavItem(icon: Icons.person_outline, label: 'Profile', isActive: false),
            ],
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
    required this.icon,
    required this.label,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active pill highlight
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: isActive
                ? BoxDecoration(
                    color: AppColors.primary100,
                    borderRadius: BorderRadius.circular(20),
                  )
                : null,
            child: Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.primary500 : const Color(0xFFB9C5CC),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.primary500 : const Color(0xFFB9C5CC),
            ),
          ),
        ],
      ),
    );
  }
}
