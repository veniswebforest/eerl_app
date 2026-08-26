import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'home_assets.dart';

/// Dropdown card showing the currently selected EERL zone.
class ZoneSelector extends StatefulWidget {
  const ZoneSelector({super.key});

  @override
  State<ZoneSelector> createState() => _ZoneSelectorState();
}

class _ZoneSelectorState extends State<ZoneSelector> {
  final LayerLink _layerLink = LayerLink();
  bool _isExpanded = false;
  int _selectedIndex = 0;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isExpanded = false);
  }

  void _toggleDropdown(List<String> zones) {
    if (_isExpanded) {
      _closeDropdown();
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final selectorWidth = renderBox.size.width;
    setState(() => _isExpanded = true);
    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, 6),
            child: SizedBox(
              width: selectorWidth,
              child: Material(
                color: Colors.transparent,
                child: _buildOptions(zones),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final zones = [
      context.l10n.homeSuratEastZone,
      context.l10n.homeSuratNorthZone,
      context.l10n.homeSuratSouthZone,
    ];

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        children: [
          InkWell(
            key: const Key('home-zone-selector'),
            onTap: () => _toggleDropdown(zones),
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
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: SvgPicture.asset(
                      HomeAssets.zone,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedIndex == 0 && !_isExpanded
                          ? context.l10n.zoneName
                          : zones[_selectedIndex],
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
        ],
      ),
    );
  }

  Widget _buildOptions(List<String> zones) => Container(
    key: const Key('home-zone-options'),
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x24000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        zones.length,
        (index) => InkWell(
          key: ValueKey('home-zone-option-$index'),
          onTap: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
            setState(() {
              _selectedIndex = index;
              _isExpanded = false;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: index == _selectedIndex
                          ? AppColors.primary500
                          : AppColors.cool500,
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
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    zones[index],
                    style: AppTextStyles.regularB8_12.copyWith(
                      color: AppColors.neutral800,
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
