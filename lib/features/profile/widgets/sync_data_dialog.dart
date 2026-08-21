import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

import '../model/sync_data_status.dart';
import 'profile_assets.dart';

class SyncDataDialog extends StatefulWidget {
  const SyncDataDialog({
    super.key,
    this.initialStatus = SyncDataStatus.pending,
  });

  final SyncDataStatus initialStatus;

  @override
  State<SyncDataDialog> createState() => _SyncDataDialogState();
}

class _SyncDataDialogState extends State<SyncDataDialog> {
  late SyncDataStatus _status = widget.initialStatus;

  @override
  Widget build(BuildContext context) {
    final isPending = _status == SyncDataStatus.pending;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: AppColors.neutral50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 335),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    ProfileAssets.syncCloud,
                    width: 79,
                    height: 53,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isPending
                        ? context.l10n.syncOfflineDataTitle
                        : context.l10n.syncAlreadySyncedTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.boldH6_20.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isPending)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.cool400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.yellow50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SvgPicture.asset(
                                  ProfileAssets.syncPendingCollection,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  context.l10n.syncPendingCollections,
                                  style: AppTextStyles.semiboldH8_16.copyWith(
                                    color: AppColors.neutral950,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _SyncButton(
                            label: context.l10n.syncNow,
                            icon: ProfileAssets.syncRefresh,
                            onTap: () =>
                                setState(() => _status = SyncDataStatus.synced),
                          ),
                        ],
                      ),
                    )
                  else
                    _SyncButton(
                      label: context.l10n.syncBack,
                      onTap: () => Navigator.pop(context),
                    ),
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                child: InkWell(
                  key: const Key('sync-dialog-close'),
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: SvgPicture.asset(
                      ProfileAssets.syncClose,
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncButton extends StatelessWidget {
  const _SyncButton({required this.label, required this.onTap, this.icon});
  final String label;
  final VoidCallback onTap;
  final String? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      key: ValueKey(icon == null ? 'sync-back-button' : 'sync-now-button'),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary500,
        foregroundColor: AppColors.neutral50,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.boldH7_16),
          if (icon != null) ...[
            const SizedBox(width: 8),
            SvgPicture.asset(icon!, width: 20, height: 20),
          ],
        ],
      ),
    ),
  );
}
