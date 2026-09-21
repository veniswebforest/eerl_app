import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class D2dWasteItemsStep extends StatelessWidget {
  const D2dWasteItemsStep({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.isOpen,
    required this.showPlasticItems,
    required this.onSelectorTap,
    required this.onCategoryChanged,
    required this.onItemChanged,
    required this.onDone,
  });

  final List<String> items;
  final Set<int> selectedItems;
  final bool isOpen;
  final bool showPlasticItems;
  final VoidCallback onSelectorTap;
  final ValueChanged<bool> onCategoryChanged;
  final ValueChanged<int> onItemChanged;
  final VoidCallback onDone;

  static const _rowColors = <Color>[
    Color(0xFFAFB4F1),
    Color(0xFFFFF8D2),
    Color(0xFF96FFF4),
    Color(0xFFFF9FA1),
    Color(0xFFB5FFDF),
    Color(0xFFF9C7FE),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.collectionSelectWasteItemsTitle,
          style: AppTextStyles.semiboldH7_18,
        ),
        const SizedBox(height: 6),
        Text(
          l10n.collectionSelectWasteItemsSubtitle,
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 24),
        Text.rich(
          TextSpan(
            text: l10n.collectionAddItemLabel,
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.red600),
              ),
            ],
          ),
          style: AppTextStyles.mediumSH8_14,
        ),
        const SizedBox(height: 8),
        InkWell(
          key: const Key('d2d-waste-selector'),
          onTap: onSelectorTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cool400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedItems.isEmpty
                        ? l10n.collectionSelectWasteItem
                        : l10n.collectionItemsSelected(selectedItems.length),
                    style: AppTextStyles.regularB7_14,
                  ),
                ),
                AnimatedRotation(
                  turns: isOpen ? .5 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: SvgPicture.asset(
                    'assets/icons/home/chevron_down.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isOpen) ...[
          const SizedBox(height: 4),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cool400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _CategoryTab(
                        text: l10n.collectionPlasticCount,
                        active: showPlasticItems,
                        onTap: () => onCategoryChanged(true),
                      ),
                    ),
                    Expanded(
                      child: _CategoryTab(
                        text: l10n.collectionNonPlasticCount,
                        active: !showPlasticItems,
                        onTap: () => onCategoryChanged(false),
                      ),
                    ),
                  ],
                ),
                ...List.generate(
                  items.length,
                  (index) => InkWell(
                    key: Key('d2d-waste-item-$index'),
                    onTap: () => onItemChanged(index),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 38),
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, _rowColors[index]],
                        ),
                      ),
                      child: Row(
                        children: [
                          _SelectionCheck(
                            selected: selectedItems.contains(index),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              items[index],
                              style: AppTextStyles.regularB7_14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: AppColors.cool50,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.collectionItemsSelected(selectedItems.length),
                          style: AppTextStyles.semiboldH9_14,
                        ),
                      ),
                      OutlinedButton(
                        key: const Key('d2d-waste-done'),
                        onPressed: selectedItems.isEmpty ? null : onDone,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(l10n.recordsContinue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.text,
    required this.active,
    required this.onTap,
  });

  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 44,
      alignment: Alignment.center,
      color: active ? AppColors.primary500 : AppColors.cool50,
      child: Text(
        text,
        style: AppTextStyles.boldH8_14.copyWith(
          color: active ? Colors.white : AppColors.neutral900,
        ),
      ),
    ),
  );
}

class _SelectionCheck extends StatelessWidget {
  const _SelectionCheck({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: selected ? AppColors.primary500 : Colors.white,
      border: Border.all(
        color: selected ? AppColors.primary500 : AppColors.neutral400,
      ),
      borderRadius: BorderRadius.circular(4),
    ),
    child: selected
        ? const Icon(Icons.check, color: Colors.white, size: 16)
        : null,
  );
}
