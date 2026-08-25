import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/help_faq_item.dart';
import 'help_support_assets.dart';

class HelpFaqList extends StatelessWidget {
  const HelpFaqList({
    super.key,
    required this.items,
    required this.expandedIndex,
    required this.onItemTap,
  });

  final List<HelpFaqItem> items;
  final int? expandedIndex;
  final ValueChanged<int> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        border: Border.all(color: AppColors.cool400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final expanded = expandedIndex == index;
          final isLast = index == items.length - 1;

          return InkWell(
            key: ValueKey('help-faq-$index'),
            onTap: () => onItemTap(index),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: index == 0 ? 0 : 16,
                bottom: isLast ? 0 : 16,
              ),
              decoration: isLast
                  ? null
                  : const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.cool400),
                      ),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.question,
                          style: AppTextStyles.semiboldH9_14.copyWith(
                            color: AppColors.neutral950,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        expanded
                            ? HelpSupportAssets.remove
                            : HelpSupportAssets.add,
                        width: 24,
                        height: 24,
                      ),
                    ],
                  ),
                  if (expanded) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.answer,
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
