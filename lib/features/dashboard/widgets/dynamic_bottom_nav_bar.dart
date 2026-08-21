import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/bottom_nav_item_model.dart';

/// Responsive Figma-matched bottom navigation driven entirely by [items].
class DynamicBottomNavBar extends StatelessWidget {
  const DynamicBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final List<BottomNavItemModel> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            height: 70,
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
            child: Row(
              children: List.generate(items.length, (index) {
                return Expanded(
                  child: _NavigationItem(
                    item: items[index],
                    isSelected: index == selectedIndex,
                    onTap: () => onItemSelected(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final BottomNavItemModel item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = isSelected ? item.selectedIcon : item.unselectedIcon;
    final iconColor = isSelected ? AppColors.primary400 : Colors.white;

    return Semantics(
      selected: isSelected,
      button: true,
      label: item.title,
      child: InkWell(
        key: ValueKey('bottom-nav-${item.pageKey}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.semiboldH10_12.copyWith(
                            color: AppColors.primary400,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
