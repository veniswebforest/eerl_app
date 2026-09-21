import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/collection/model/collection_entry_state.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
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
    this.onDraftContinue,
  });
  final RecordsViewFlag initialView;
  final ValueChanged<CollectionDetailStatus>? onRecordTap;
  final ValueChanged<CollectionDraftModel>? onDraftContinue;
  @override
  State<RecordsTabScreen> createState() => _RecordsTabScreenState();
}

class _RecordsTabScreenState extends State<RecordsTabScreen> {
  late RecordsViewFlag _view = widget.initialView;
  int _draftCount = 3;
  _RecordsTypeFilter _typeFilter = _RecordsTypeFilter.all;
  _RecordsDateFilter _dateFilter = _RecordsDateFilter.today;
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
              padding: const EdgeInsets.fromLTRB(
                20,
                AppScreenHeaderMetrics.topInset,
                20,
                112,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppScreenHeader(
                        title: context.l10n.recordsCollectionsTitle,
                        subtitle: context.l10n.recordsCollectionsSubtitle,
                        actions: [
                          IconButton(
                            key: const Key('records-date-filter'),
                            onPressed: _showDateFilter,
                            icon: SvgPicture.asset(
                              RecordsAssets.filter,
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SearchField(hint: context.l10n.recordsSearchHint),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      _RecordsTypeChips(
                        selected: _typeFilter,
                        onSelected: (value) =>
                            setState(() => _typeFilter = value),
                      ),
                      const SizedBox(height: 24),
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
        context.l10n.recordsAllCollections,
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
    final visibleGroups = groups
        .map(
          (group) => (
            group.$1,
            group.$2.where((item) => _matchesType(item.name)).toList(),
          ),
        )
        .where((group) => group.$2.isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in visibleGroups) ...[
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
        type: CollectionType.d2d,
        resumeStep: CollectionEntryStep.photos,
        selectedItems: const <int>{0, 1, 2, 3, 4},
      ),
      CollectionDraftModel(
        name: 'MRF Station',
        date: context.l10n.recordsOctober22Time,
        weight: '240.20 KG',
        itemCount: '....',
        type: CollectionType.mrfStation,
        resumeStep: CollectionEntryStep.items,
      ),
      CollectionDraftModel(
        name: 'MRF Station',
        date: context.l10n.recordsOctober21Time,
        weight: '....',
        itemCount: '....',
        type: CollectionType.mrfStation,
        resumeStep: CollectionEntryStep.items,
      ),
    ].where((draft) => _matchesType(draft.name)).take(_draftCount).toList();
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
              onContinue: () => widget.onDraftContinue?.call(item),
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

  bool _matchesType(String name) => switch (_typeFilter) {
    _RecordsTypeFilter.all => true,
    _RecordsTypeFilter.d2d => name == 'D2D',
    _RecordsTypeFilter.mrf => name == 'MRF Station',
    _RecordsTypeFilter.ramp => name == 'Ramp',
  };

  void _discardDraft() => setState(() {
    _draftCount--;
    _view = _draftCount <= 0
        ? RecordsViewFlag.emptyDrafts
        : RecordsViewFlag.afterDiscard;
  });

  Future<void> _showDateFilter() async {
    final selected = await showModalBottomSheet<_RecordsDateFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (context) => _RecordsDateFilterSheet(selected: _dateFilter),
    );
    if (selected != null && mounted) {
      setState(() => _dateFilter = selected);
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint});
  final String hint;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 55,
    child: TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(15.5),
          child: SvgPicture.asset(
            RecordsAssets.search,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.cool600,
              BlendMode.srcIn,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        filled: true,
        fillColor: AppColors.neutral50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cool400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cool400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary500),
        ),
      ),
    ),
  );
}

enum _RecordsTypeFilter { all, d2d, mrf, ramp }

enum _RecordsDateFilter { today, yesterday, lastSevenDays }

class _RecordsTypeChips extends StatelessWidget {
  const _RecordsTypeChips({required this.selected, required this.onSelected});

  final _RecordsTypeFilter selected;
  final ValueChanged<_RecordsTypeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final labels = <_RecordsTypeFilter, String>{
      _RecordsTypeFilter.all: context.l10n.recordsAll,
      _RecordsTypeFilter.d2d: context.l10n.d2d,
      _RecordsTypeFilter.mrf: context.l10n.collectionMrfShort,
      _RecordsTypeFilter.ramp: context.l10n.ramp,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _RecordsTypeFilter.values
            .map(
              (value) => Padding(
                padding: EdgeInsets.only(
                  right: value == _RecordsTypeFilter.values.last ? 0 : 8,
                ),
                child: InkWell(
                  key: Key('records-filter-${value.name}'),
                  onTap: () => onSelected(value),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected == value
                          ? AppColors.primary500
                          : AppColors.cool200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: labels[value]!,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: selected == value
                              ? Colors.white
                              : AppColors.neutral700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _RecordsDateFilterSheet extends StatelessWidget {
  const _RecordsDateFilterSheet({required this.selected});

  final _RecordsDateFilter selected;

  @override
  Widget build(BuildContext context) {
    final labels = <_RecordsDateFilter, String>{
      _RecordsDateFilter.today: context.l10n.recordsFilterToday,
      _RecordsDateFilter.yesterday: context.l10n.recordsFilterYesterday,
      _RecordsDateFilter.lastSevenDays: context.l10n.recordsFilterLastSevenDays,
    };
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: const BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.recordsFilterByDate,
                    style: AppTextStyles.semiboldH6_20.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('records-filter-close'),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  icon: const Icon(Icons.close, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final value in _RecordsDateFilter.values)
              InkWell(
                key: Key('records-date-${value.name}'),
                onTap: () => Navigator.pop(context, value),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: value == selected
                        ? AppColors.primary50
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      _RecordsRadio(selected: value == selected),
                      const SizedBox(width: 12),
                      Text(labels[value]!, style: AppTextStyles.regularB7_14),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecordsRadio extends StatelessWidget {
  const _RecordsRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      border: Border.all(color: AppColors.neutral400),
    ),
    child: selected
        ? const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary500,
            ),
          )
        : null,
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
