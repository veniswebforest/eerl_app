import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/collection_detail_status.dart';
import '../model/collection_record_model.dart';
import '../model/records_view_flag.dart';
import '../widgets/collection_draft_card.dart';
import '../widgets/collection_history_card.dart';
import '../widgets/records_assets.dart';
import '../widgets/records_segmented_control.dart';

class RecordsTabScreen extends StatefulWidget {
  const RecordsTabScreen({
    super.key,
    this.initialView = RecordsViewFlag.history,
    this.onRecordTap,
  });
  final RecordsViewFlag initialView;
  final ValueChanged<CollectionDetailStatus>? onRecordTap;
  @override
  State<RecordsTabScreen> createState() => _RecordsTabScreenState();
}

class _RecordsTabScreenState extends State<RecordsTabScreen> {
  late RecordsViewFlag _view = widget.initialView;
  int _draftCount = 3;
  bool get _showDrafts => _view != RecordsViewFlag.history;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.recordsCollectionsTitle,
                        style: AppTextStyles.semiboldH6_20.copyWith(
                          color: AppColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.recordsCollectionsSubtitle,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      RecordsSegmentedControl(
                        isDrafts: _showDrafts,
                        historyLabel: context.l10n.recordsHistory,
                        draftsLabel: context.l10n.recordsDrafts,
                        onChanged: (drafts) => setState(
                          () => _view = drafts
                              ? RecordsViewFlag.drafts
                              : RecordsViewFlag.history,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SearchField(hint: context.l10n.recordsSearchHint),
                      const SizedBox(height: 20),
                      if (_showDrafts) _buildDrafts() else _buildHistory(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_view == RecordsViewFlag.discardConfirmation)
            Positioned.fill(
              child: _DiscardOverlay(
                onCancel: () => setState(() => _view = RecordsViewFlag.drafts),
                onDiscard: _discardDraft,
              ),
            ),
        ],
      ),
    ),
  );

  Widget _buildHistory() {
    final groups = <(String, List<CollectionRecordModel>)>[
      (
        context.l10n.recordsTodayCollections,
        const [
          CollectionRecordModel(
            name: 'D2D',
            receipt: 'RC-000248',
            weight: '245 kg',
            status: CollectionRecordStatus.pending,
          ),
          CollectionRecordModel(
            name: 'MRF Station',
            receipt: 'RC-000247',
            weight: '115 kg',
            status: CollectionRecordStatus.verified,
          ),
          CollectionRecordModel(
            name: 'Ramp',
            receipt: 'RC-000246',
            weight: '320 kg',
            status: CollectionRecordStatus.rejected,
          ),
        ],
      ),
      (
        context.l10n.recordsYesterdayCollections,
        const [
          CollectionRecordModel(
            name: 'Ramp',
            receipt: 'RC-000246',
            weight: '320 kg',
            status: CollectionRecordStatus.verified,
          ),
          CollectionRecordModel(
            name: 'D2D',
            receipt: 'RC-000248',
            weight: '245 kg',
            status: CollectionRecordStatus.verified,
          ),
        ],
      ),
      (
        context.l10n.recordsOctoberCollections,
        const [
          CollectionRecordModel(
            name: 'Ramp',
            receipt: 'RC-000246',
            weight: '320 kg',
            status: CollectionRecordStatus.pending,
          ),
          CollectionRecordModel(
            name: 'D2D',
            receipt: 'RC-000248',
            weight: '245 kg',
            status: CollectionRecordStatus.verified,
          ),
        ],
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          Text(
            group.$1,
            style: AppTextStyles.semiboldH7_18.copyWith(
              color: AppColors.neutral950,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in group.$2) ...[
            CollectionHistoryCard(
              item: item,
              statusLabel: _statusLabel(item.status),
              onTap: () => widget.onRecordTap?.call(_detailStatus(item.status)),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
        ],
      ],
    );
  }

  Widget _buildDrafts() {
    final drafts = <CollectionDraftModel>[
      CollectionDraftModel(
        name: 'D2D',
        date: context.l10n.recordsTodayTime,
        weight: '240.20 KG',
        itemCount: context.l10n.recordsFiveItemsSelected,
      ),
      CollectionDraftModel(
        name: 'MRF Station',
        date: context.l10n.recordsOctober22Time,
        weight: '240.20 KG',
        itemCount: '....',
      ),
      CollectionDraftModel(
        name: 'MRF Station',
        date: context.l10n.recordsOctober21Time,
        weight: '....',
        itemCount: '....',
      ),
    ].take(_draftCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.recordsCollectionDrafts,
          style: AppTextStyles.semiboldH7_18.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 12),
        if (_view == RecordsViewFlag.emptyDrafts || drafts.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 42),
            child: Center(
              child: Column(
                children: [
                  SvgPicture.asset(
                    RecordsAssets.emptyDrafts,
                    width: 213,
                    height: 233,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.recordsNoDrafts,
                    style: AppTextStyles.semiboldH8_16.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (final item in drafts) ...[
            CollectionDraftCard(
              item: item,
              pendingLabel: context.l10n.pendingSubmission,
              discardLabel: context.l10n.recordsDiscard,
              continueLabel: context.l10n.recordsContinue,
              onDiscard: () =>
                  setState(() => _view = RecordsViewFlag.discardConfirmation),
            ),
            const SizedBox(height: 14),
          ],
      ],
    );
  }

  String _statusLabel(CollectionRecordStatus status) => switch (status) {
    CollectionRecordStatus.pending => context.l10n.expensePendingSupervisor,
    CollectionRecordStatus.verified => context.l10n.expenseVerified,
    CollectionRecordStatus.rejected =>
      context.l10n.collectionRejectedSupervisor,
  };

  CollectionDetailStatus _detailStatus(CollectionRecordStatus status) =>
      switch (status) {
        CollectionRecordStatus.pending => CollectionDetailStatus.pending,
        CollectionRecordStatus.verified => CollectionDetailStatus.approved,
        CollectionRecordStatus.rejected => CollectionDetailStatus.rejected,
      };

  void _discardDraft() => setState(() {
    _draftCount--;
    _view = _draftCount <= 0
        ? RecordsViewFlag.emptyDrafts
        : RecordsViewFlag.afterDiscard;
  });
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint});
  final String hint;
  @override
  Widget build(BuildContext context) => Container(
    height: 55,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.cool400),
    ),
    child: Row(
      children: [
        SvgPicture.asset(
          RecordsAssets.search,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            AppColors.cool600,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            hint,
            style: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.neutral500,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DiscardOverlay extends StatelessWidget {
  const _DiscardOverlay({required this.onCancel, required this.onDiscard});
  final VoidCallback onCancel;
  final VoidCallback onDiscard;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black.withValues(alpha: 0.56),
    child: Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        constraints: const BoxConstraints(maxWidth: 335),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.recordsAreYouSure,
              style: AppTextStyles.boldH5_24.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.recordsDiscardConfirmation,
              textAlign: TextAlign.center,
              style: AppTextStyles.regularB7_14.copyWith(
                color: AppColors.neutral500,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: context.l10n.recordsCancel,
                    background: AppColors.cool200,
                    foreground: AppColors.neutral950,
                    onTap: onCancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: context.l10n.recordsDiscard,
                    background: AppColors.red500,
                    foreground: Colors.white,
                    onTap: onDiscard,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: AppTextStyles.semiboldH8_16),
    ),
  );
}
