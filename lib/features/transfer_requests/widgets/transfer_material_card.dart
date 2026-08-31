import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class TransferMaterialCard extends StatelessWidget {
  const TransferMaterialCard({
    super.key,
    required this.name,
    required this.capacity,
    required this.selected,
    required this.onTap,
    this.child,
  });

  final String name;
  final String capacity;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: selected ? AppColors.primary500 : AppColors.cool200,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset(
                    'assets/images/collection_detail/pet_thumbnail.png',
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semiboldH9_14.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                ),
                _SelectionCircle(selected: selected),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cool200,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                capacity,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.neutral900,
                ),
              ),
            ),
            if (selected && child != null) ...[
              const SizedBox(height: 14),
              child!,
            ],
          ],
        ),
      ),
    ),
  );
}

class _SelectionCircle extends StatelessWidget {
  const _SelectionCircle({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: selected ? AppColors.primary500 : AppColors.neutral500,
      ),
    ),
    child: selected
        ? const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary500,
              shape: BoxShape.circle,
            ),
          )
        : null,
  );
}
