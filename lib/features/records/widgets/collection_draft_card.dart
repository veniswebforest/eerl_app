import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/collection_record_model.dart';
import 'records_assets.dart';

class CollectionDraftCard extends StatelessWidget {
  const CollectionDraftCard({
    super.key,
    required this.item,
    required this.pendingLabel,
    required this.discardLabel,
    required this.continueLabel,
    required this.onDiscard,
  });
  final CollectionDraftModel item;
  final String pendingLabel;
  final String discardLabel;
  final String continueLabel;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pendingLabel,
                  style: AppTextStyles.mediumSH8_14.copyWith(
                    color: AppColors.yellow600,
                  ),
                ),
              ),
              Text(
                item.date,
                style: AppTextStyles.mediumSH9_12.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cool100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.mediumSH7_16.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 10),
                _DraftInfo(icon: RecordsAssets.weight, text: item.weight),
                const SizedBox(height: 8),
                _DraftInfo(icon: RecordsAssets.items, text: item.itemCount),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Button(
                  label: discardLabel,
                  color: AppColors.red500,
                  onTap: onDiscard,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Button(
                  label: continueLabel,
                  color: AppColors.primary500,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DraftInfo extends StatelessWidget {
  const _DraftInfo({required this.icon, required this.text});
  final String icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 28,
        height: 28,
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: AppColors.neutral50,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(icon),
      ),
      const SizedBox(width: 8),
      Text(
        text,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral600),
      ),
    ],
  );
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: AppTextStyles.semiboldH8_16),
    ),
  );
}
