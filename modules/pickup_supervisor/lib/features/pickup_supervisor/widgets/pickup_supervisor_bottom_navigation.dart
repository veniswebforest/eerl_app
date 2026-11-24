import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/model/pickup_supervisor_bottom_nav_item.dart';

const _assetPackage = 'pickup_supervisor';

class PickupSupervisorBottomNavigation extends StatelessWidget {
  const PickupSupervisorBottomNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final List<PickupSupervisorBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 335),
          child: Container(
            key: const Key('supervisor-bottom-navigation'),
            height: 70,
            decoration: BoxDecoration(
              color: DriverColors.navigation,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final selected = index == selectedIndex;
                return Expanded(
                  child: Semantics(
                    selected: selected,
                    button: true,
                    label: item.title,
                    child: InkWell(
                      key: Key('supervisor-nav-${item.pageKey}'),
                      onTap: () => onItemSelected(index),
                      borderRadius: BorderRadius.circular(28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            selected ? item.selectedIcon : item.unselectedIcon,
                            package: _assetPackage,
                            width: 28,
                            height: 28,
                            colorFilter: ColorFilter.mode(
                              selected ? DriverColors.primary400 : Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(height: 6),
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DriverTextStyles.semibold14.copyWith(
                                color: DriverColors.primary400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
