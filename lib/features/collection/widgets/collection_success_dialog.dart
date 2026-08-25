import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class CollectionSuccessDialog extends StatelessWidget {
  const CollectionSuccessDialog({
    super.key,
    required this.onPreview,
    required this.onAddNew,
  });
  final VoidCallback onPreview;
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/collection_detail/collection_success.png',
            width: 135,
            height: 135,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              text: '${context.l10n.collectionSubmitted} ',
              children: [
                TextSpan(
                  text: context.l10n.collectionSuccessfully,
                  style: const TextStyle(color: AppColors.primary500),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: AppTextStyles.boldH5_24,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.collectionSubmissionId,
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 24),
          _DialogButton(
            label: context.l10n.collectionPreviewSlip,
            filled: true,
            onTap: onPreview,
            icon: 'assets/icons/collection/preview_slip.svg',
          ),
          const SizedBox(height: 12),
          _DialogButton(
            label: context.l10n.collectionAddNew,
            filled: false,
            onTap: onAddNew,
          ),
        ],
      ),
    ),
  );
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.icon,
  });
  final String label;
  final bool filled;
  final VoidCallback onTap;
  final String? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: filled ? AppColors.primary500 : AppColors.neutral50,
        foregroundColor: filled ? AppColors.neutral50 : AppColors.primary500,
        side: const BorderSide(color: AppColors.primary500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SvgPicture.asset(icon!, width: 24, height: 24),
            const SizedBox(width: 8),
          ],
          Text(label, style: AppTextStyles.boldH7_16),
        ],
      ),
    ),
  );
}
