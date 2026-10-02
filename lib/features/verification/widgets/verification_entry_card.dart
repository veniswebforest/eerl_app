import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../../home/widgets/home_styles.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';

class VerificationEntryCard extends StatelessWidget {
  const VerificationEntryCard({super.key, required this.entry, this.onTap});

  final CollectionModel entry;
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
                    '${entry.agentName} • ${entry.channel}',
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
                        '${entry.totalQty.toStringAsFixed(2)} kg • ₹${(entry.totalAmount ?? 0).toStringAsFixed(2)}',
                        style: AppTextStyles.boldH8_14.copyWith(
                          color: AppColors.green600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${entry.slipNumber ?? entry.id} • ${_time(entry.collectedAt)}',
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.centerName ?? entry.centerId,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _VerificationStatusChip(status: entry.status),
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

  String _time(String? value) {
    final parsed = DateTime.tryParse(value ?? '')?.toLocal();
    return parsed == null ? '' : DateFormat('dd MMM, hh:mm a').format(parsed);
  }
}

class _VerificationStatusChip extends StatelessWidget {
  const _VerificationStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final (asset, label, foreground, background) = switch (normalized) {
      'VERIFIED' || 'APPROVED' => (
        'assets/icons/wallet/status_verified.svg',
        context.l10n.verificationVerified,
        AppColors.primary500,
        AppColors.primary50,
      ),
      'REJECTED' => (
        'assets/icons/wallet/status_flagged.svg',
        context.l10n.verificationRejected,
        AppColors.red600,
        AppColors.red50,
      ),
      _ => (
        'assets/icons/records/status_pending.svg',
        context.l10n.verificationPendingApproval,
        AppColors.yellow600,
        AppColors.yellow50,
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
