import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'home_assets.dart';

/// Dropdown card showing the currently selected EERL zone.
class ZoneSelector extends StatefulWidget {
  const ZoneSelector({super.key, this.onExpandedChanged});

  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<ZoneSelector> createState() => _ZoneSelectorState();
}

class _ZoneSelectorState extends State<ZoneSelector> {
  bool _isExpanded = false;
  int _selectedIndex = 0;

  void _toggleDropdown() {
    final nextValue = !_isExpanded;
    setState(() => _isExpanded = nextValue);
    widget.onExpandedChanged?.call(nextValue);
  }

  @override
  Widget build(BuildContext context) {
    final zones = [
      context.l10n.homeSuratEastZone,
      context.l10n.homeSuratNorthZone,
      context.l10n.homeSuratSouthZone,
    ];

    return Column(
      children: [
        InkWell(
          key: const Key('home-zone-selector'),
          onTap: _toggleDropdown,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary500),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(HomeAssets.zone),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedIndex == 0 && !_isExpanded
                        ? context.l10n.zoneName
                        : zones[_selectedIndex],
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semiboldH9_14.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? .5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: SvgPicture.asset(
                    HomeAssets.chevronDown,
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[const SizedBox(height: 4), _buildOptions(zones)],
      ],
    );
  }

  Widget _buildOptions(List<String> zones) => Container(
    key: const Key('home-zone-options'),
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.cool400),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        zones.length,
        (index) => InkWell(
          key: ValueKey('home-zone-option-$index'),
          onTap: () {
            setState(() {
              _selectedIndex = index;
              _isExpanded = false;
            });
            widget.onExpandedChanged?.call(false);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: index == _selectedIndex
                          ? AppColors.primary500
                          : AppColors.neutral400,
                    ),
                  ),
                  child: index == _selectedIndex
                      ? const DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.primary500,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    zones[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regularB7_14.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
