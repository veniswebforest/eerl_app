import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'home_assets.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';

/// Dropdown card showing the currently selected EERL zone.
class ZoneSelector extends StatefulWidget {
  const ZoneSelector({
    super.key,
    this.onExpandedChanged,
    this.onSelected,
    this.initialLabel,
    this.initialSelectedIndex = 0,
    this.options,
    this.selectorKey = const Key('home-zone-selector'),
    this.optionsKey = const Key('home-zone-options'),
    this.optionKeyPrefix = 'home-zone-option',
  });

  final ValueChanged<bool>? onExpandedChanged;
  final ValueChanged<int>? onSelected;
  final String? initialLabel;
  final int initialSelectedIndex;
  final List<String>? options;
  final Key selectorKey;
  final Key optionsKey;
  final String optionKeyPrefix;

  @override
  State<ZoneSelector> createState() => _ZoneSelectorState();
}

class _ZoneSelectorState extends State<ZoneSelector> {
  bool _isExpanded = false;
  late int _selectedIndex;
  bool _hasSelectedOption = false;
  LocalQueryController<({List<CenterModel> centers, String? active})>? _query;

  @override
  void initState() {
    super.initState();
    final lastIndex = (widget.options?.length ?? 3) - 1;
    _selectedIndex = widget.initialSelectedIndex.clamp(0, lastIndex).toInt();
    if (widget.options == null) {
      _query =
          LocalQueryController(() async {
              final centers = await EerlLocalRepository.instance.getCenters();
              final active = await EerlLocalRepository.instance.activeCenterId;
              return (centers: centers, active: active);
            })
            ..addListener(_centersChanged)
            ..load();
    }
  }

  void _centersChanged() {
    final data = _query?.data;
    if (data != null && data.centers.isNotEmpty) {
      final activeIndex = data.centers.indexWhere(
        (center) => center.id == data.active,
      );
      _selectedIndex = activeIndex < 0 ? 0 : activeIndex;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _query?.removeListener(_centersChanged);
    _query?.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    final nextValue = !_isExpanded;
    setState(() => _isExpanded = nextValue);
    widget.onExpandedChanged?.call(nextValue);
  }

  @override
  Widget build(BuildContext context) {
    final centers = _query?.data?.centers ?? const <CenterModel>[];
    final zones =
        widget.options ?? centers.map((center) => center.name).toList();
    final safeZones = zones.isEmpty ? [context.l10n.zoneName] : zones;
    if (_selectedIndex >= safeZones.length) _selectedIndex = 0;

    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          InkWell(
            key: widget.selectorKey,
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
                      !_hasSelectedOption && !_isExpanded
                          ? widget.initialLabel ?? context.l10n.zoneName
                          : safeZones[_selectedIndex],
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
          if (_isExpanded) ...[
            const SizedBox(height: 4),
            _buildOptions(safeZones, centers),
          ],
        ],
      ),
    );
  }

  Widget _buildOptions(List<String> zones, List<CenterModel> centers) =>
      Container(
        key: widget.optionsKey,
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
              key: ValueKey('${widget.optionKeyPrefix}-$index'),
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                  _isExpanded = false;
                  _hasSelectedOption = true;
                });
                widget.onExpandedChanged?.call(false);
                widget.onSelected?.call(index);
                if (widget.options == null && index < centers.length) {
                  EerlLocalRepository.instance.selectCenter(centers[index].id);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
