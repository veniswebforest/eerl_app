import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../../home/widgets/home_styles.dart';
import '../model/verification_entry.dart';

class VerificationEntryCard extends StatelessWidget {
  const VerificationEntryCard({super.key, required this.entry, this.onTap});

  final VerificationEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.neutral50,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          // border: entry.highlighted
          //     ? Border.all(color: AppColors.primary500)
          //     : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [HomeStyles.cardShadow],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 28),
                  child: Text(
                    '${entry.person} • ${entry.collectionType}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semiboldH8_16.copyWith(
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // color: AppColors.cool100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.weightAndAmount,
                        style: AppTextStyles.boldH8_14.copyWith(
                          color: AppColors.green600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.collectionIdAndTime,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.facility,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _VerificationStatusChip(result: entry.result),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: SvgPicture.asset(
                'assets/icons/wallet/open_details.svg',
                width: 24,
                height: 24,
                // colorFilt
              ),
              //     ? const ColorFilter.mode(
              //         AppColors.primary500,
              //         BlendMode.srcIn,
              //       )
              //     : null,
            ),
          ],
        ),
      ),
    ),
  );
}

class _VerificationStatusChip extends StatelessWidget {
  const _VerificationStatusChip({required this.result});

  final VerificationResult result;

  @override
  Widget build(BuildContext context) {
    final (asset, label, foreground, background) = switch (result) {
      VerificationResult.pending => (
        'assets/icons/records/status_pending.svg',
        context.l10n.verificationPendingApproval,
        AppColors.yellow600,
        AppColors.yellow50,
      ),
      VerificationResult.verified => (
        'assets/icons/wallet/status_verified.svg',
        context.l10n.verificationVerified,
        AppColors.primary500,
        AppColors.primary50,
      ),
      VerificationResult.rejected => (
        'assets/icons/wallet/status_flagged.svg',
        context.l10n.verificationRejected,
        AppColors.red600,
        AppColors.red50,
      ),
    };

    return Container(
      height: 32,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(asset, width: 16, height: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiboldH10_12.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
