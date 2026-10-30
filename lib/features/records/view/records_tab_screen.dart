import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_route_data.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/utils/ist_date_time.dart';
import 'package:eerl_app/features/collection/model/collection_entry_state.dart';
import 'package:eerl_app/features/collection/widgets/collection_draft_saved_notification.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/dashboard/provider/dashboard_navigation_provider.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import '../model/records_view_flag.dart';
import '../widgets/collection_draft_card.dart';
import '../widgets/collection_history_card.dart';
import '../widgets/records_assets.dart';
import '../widgets/records_segmented_control.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RecordsTabScreen extends StatefulWidget {
  const RecordsTabScreen({
    super.key,
    this.initialView = RecordsViewFlag.history,
  });
  final RecordsViewFlag initialView;
  @override
  State<RecordsTabScreen> createState() => _RecordsTabScreenState();
}

class _RecordsTabScreenState extends State<RecordsTabScreen> {
  late RecordsViewFlag _view = widget.initialView;
  _RecordsTypeFilter _typeFilter = _RecordsTypeFilter.all;
  _RecordsDateFilter _dateFilter = _RecordsDateFilter.lastSevenDays;
  _RecordsStatusFilter _statusFilter = _RecordsStatusFilter.all;
  String _query = '';
  String? _draftToDiscard;
  late final LocalQueryController<
    ({List<CollectionModel> history, List<CollectionModel> drafts})
  >
  _controller;
  int _bootstrapRevision = -1;
  bool get _showDrafts => _view != RecordsViewFlag.history;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(() async {
      final values = await Future.wait([
        EerlLocalRepository.instance.getAgentCollections(search: _query),
        EerlLocalRepository.instance.getAgentCollections(
          drafts: true,
          search: _query,
        ),
      ]);
      return (history: values[0], drafts: values[1]);
    })..load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final revision = BootstrapSyncService.instance.revision;
    if (_bootstrapRevision >= 0 && revision != _bootstrapRevision) {
      _controller.load();
    }
    _bootstrapRevision = revision;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: RefreshIndicator(
              key: const Key('collection-records-refresh'),
              onRefresh: _refreshLocalCollections,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                              onPressed: _showFilters,
                              icon: SvgPicture.asset(
                                RecordsAssets.filter,
                                width: 28,
                                height: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _SearchField(
                          hint: context.l10n.recordsSearchHint,
                          onChanged: (value) {
                            _query = value;
                            _controller.load();
                          },
                        ),
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
                        if (!_showDrafts) ...[
                          _RecordsStatusChips(
                            selected: _statusFilter,
                            onSelected: (value) =>
                                setState(() => _statusFilter = value),
                          ),
                          const SizedBox(height: 24),
                        ] else
                          const SizedBox(height: 24),
                        ListenableBuilder(
                          listenable: _controller,
                          builder: (context, _) {
                            if (_controller.isLoading && !_controller.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (_controller.error != null) {
                              return Center(
                                child: TextButton(
                                  onPressed: _controller.load,
                                  child: const Text('Retry'),
                                ),
                              );
                            }
                            return _showDrafts
                                ? _buildDrafts()
                                : _buildHistory();
                          },
                        ),
                      ],
                    ),
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

  Future<void> _refreshLocalCollections() => _controller.load();

  Widget _buildHistory() {
    final items = (_controller.data?.history ?? const <CollectionModel>[])
        .where(
          (item) =>
              _matchesType(item.channel) &&
              _matchesDate(item) &&
              _matchesStatus(item.status),
        )
        .toList(growable: false);
    if (items.isEmpty) {
      return _RecordsEmptyState(
        key: const Key('records-history-empty'),
        message: context.l10n.recordsNoCollectionHistory,
        asset: RecordsAssets.emptyHistory,
        imageKey: const Key('records-history-empty-icon'),
      );
    }
    final grouped = <DateTime, List<CollectionModel>>{};
    for (final item in items) {
      final day = _collectionIstDay(item);
      (grouped[day] ??= <CollectionModel>[]).add(item);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.indexed
          .expand((entry) {
            final group = entry.$2;
            return <Widget>[
              if (entry.$1 > 0) const SizedBox(height: 14),
              Text(
                _dateGroupLabel(group.key),
                style: AppTextStyles.semiboldH7_18.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 12),
              for (final item in group.value) ...[
                CollectionHistoryCard(
                  item: item,
                  statusLabel: _statusLabel(item.status),
                  onTap: () => context.push<void>(
                    AppRoutes.collectionDetail,
                    extra: item.id,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ];
          })
          .toList(growable: false),
    );
  }

  Widget _buildDrafts() {
    final drafts = (_controller.data?.drafts ?? const <CollectionModel>[])
        .where((draft) => _matchesType(draft.channel) && _matchesDate(draft))
        .toList(growable: false);
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
          _RecordsEmptyState(
            key: const Key('records-drafts-empty'),
            message: context.l10n.recordsNoDrafts,
          )
        else
          for (final item in drafts) ...[
            CollectionDraftCard(
              item: item,
              pendingLabel: context.l10n.pendingSubmission,
              discardLabel: context.l10n.recordsDiscard,
              continueLabel: context.l10n.recordsContinue,
              onDiscard: () => setState(() {
                _draftToDiscard = item.id;
                _view = RecordsViewFlag.discardConfirmation;
              }),
              onContinue: () => _continueDraft(item),
            ),
            const SizedBox(height: 14),
          ],
      ],
    );
  }

  String _statusLabel(String status) => switch (status.toUpperCase()) {
    'VERIFIED' || 'APPROVED' => context.l10n.expenseVerified,
    'REJECTED' => context.l10n.collectionRejectedSupervisor,
    _ => context.l10n.expensePendingSupervisor,
  };

  Future<void> _continueDraft(CollectionModel draft) async {
    final result = await context.push<CollectionRouteResult>(
      AppRoutes.addCollection,
      extra: AddCollectionRouteData(
        initialStep: CollectionEntryStep.items,
        initialType: _collectionType(draft.channel),
        collectionId: draft.id,
      ),
    );
    if (!mounted) return;
    await _controller.load();
    if (!mounted) return;
    switch (result) {
      case CollectionRouteResult.draftSaved:
        setState(() => _view = RecordsViewFlag.drafts);
        showCollectionDraftSavedNotification(context);
      case CollectionRouteResult.openCollections:
        context.read<DashboardNavigationProvider>().selectPage('collections');
      case null:
        break;
    }
  }

  bool _matchesType(String name) {
    final upper = name.trim().toUpperCase();
    return switch (_typeFilter) {
      _RecordsTypeFilter.all => true,
      _RecordsTypeFilter.d2d => upper == 'D2D' || upper.contains('D2D'),
      _RecordsTypeFilter.mrf => upper.contains('MRF'),
      _RecordsTypeFilter.ramp => upper == 'RAMP' || upper.contains('RAMP'),
    };
  }

  bool _matchesStatus(String status) {
    final upper = status.trim().toUpperCase();
    return switch (_statusFilter) {
      _RecordsStatusFilter.all => true,
      _RecordsStatusFilter.pending =>
        upper == 'PENDING' || upper == 'SUBMITTED',
      _RecordsStatusFilter.verified =>
        upper == 'VERIFIED' || upper == 'APPROVED',
      _RecordsStatusFilter.rejected => upper == 'REJECTED',
    };
  }

  CollectionType _collectionType(String channel) =>
      channel.toUpperCase() == 'D2D'
      ? CollectionType.d2d
      : channel.toUpperCase() == 'RAMP'
      ? CollectionType.ramp
      : CollectionType.mrfStation;

  bool _matchesDate(CollectionModel item) {
    final rawDate = item.collectedAt ?? item.updatedAt;
    final value = DateTime.tryParse(rawDate);
    if (value == null) return true;
    final istDay = IstDateTime.fromUtc(value.toUtc());
    final istNow = IstDateTime.now();
    final today = DateTime(istNow.year, istNow.month, istNow.day);
    final day = DateTime(istDay.year, istDay.month, istDay.day);
    return switch (_dateFilter) {
      _RecordsDateFilter.today => day == today,
      _RecordsDateFilter.yesterday =>
        day == today.subtract(const Duration(days: 1)),
      _RecordsDateFilter.lastSevenDays =>
        !day.isBefore(today.subtract(const Duration(days: 6))) &&
            !day.isAfter(today),
    };
  }

  DateTime _collectionIstDay(CollectionModel item) {
    final parsed = DateTime.tryParse(item.collectedAt ?? item.updatedAt);
    final value = parsed == null
        ? IstDateTime.now()
        : IstDateTime.fromUtc(parsed.toUtc());
    return DateTime(value.year, value.month, value.day);
  }

  String _dateGroupLabel(DateTime day) {
    final now = IstDateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return context.l10n.recordsTodayCollections;
    if (day == today.subtract(const Duration(days: 1))) {
      return context.l10n.recordsYesterdayCollections;
    }
    return context.l10n.recordsDatedCollections(
      DateFormat('dd MMMM').format(day),
    );
  }

  Future<void> _discardDraft() async {
    final id = _draftToDiscard;
    if (id != null) await EerlLocalRepository.instance.discardDraft(id);
    if (!mounted) return;
    await _controller.load();
    if (!mounted) return;
    setState(() {
      _draftToDiscard = null;
      _view = RecordsViewFlag.afterDiscard;
    });
  }

  Future<void> _showFilters() async {
    final selected = await showModalBottomSheet<_RecordsFilterSelection>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      isScrollControlled: true,
      builder: (context) => _RecordsFilterSheet(
        selectedDate: _dateFilter,
        selectedType: _typeFilter,
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        _dateFilter = selected.date;
        _typeFilter = selected.type;
      });
    }
  }
}

class _RecordsEmptyState extends StatelessWidget {
  const _RecordsEmptyState({
    super.key,
    required this.message,
    this.asset = RecordsAssets.emptyDrafts,
    this.imageKey,
  });

  final String message;
  final String asset;
  final Key? imageKey;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 42),
    child: Center(
      child: Column(
        children: [
          SvgPicture.asset(asset, key: imageKey, width: 213, height: 233),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.semiboldH8_16.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 55,
    child: TextField(
      onChanged: onChanged,
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

enum _RecordsStatusFilter { all, pending, verified, rejected }

typedef _RecordsFilterSelection = ({
  _RecordsDateFilter date,
  _RecordsTypeFilter type,
});

class _RecordsStatusChips extends StatelessWidget {
  const _RecordsStatusChips({required this.selected, required this.onSelected});

  final _RecordsStatusFilter selected;
  final ValueChanged<_RecordsStatusFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final labels = <_RecordsStatusFilter, String>{
      _RecordsStatusFilter.all: context.l10n.recordsAll,
      _RecordsStatusFilter.pending: context.l10n.filterPending,
      _RecordsStatusFilter.verified: context.l10n.expenseVerified,
      _RecordsStatusFilter.rejected: context.l10n.verificationRejected,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _RecordsStatusFilter.values
            .map(
              (value) => Padding(
                padding: EdgeInsets.only(
                  right: value == _RecordsStatusFilter.values.last ? 0 : 8,
                ),
                child: InkWell(
                  key: Key('records-status-${value.name}'),
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

class _RecordsFilterSheet extends StatefulWidget {
  const _RecordsFilterSheet({
    required this.selectedDate,
    required this.selectedType,
  });
  final _RecordsDateFilter selectedDate;
  final _RecordsTypeFilter selectedType;

  @override
  State<_RecordsFilterSheet> createState() => _RecordsFilterSheetState();
}

class _RecordsFilterSheetState extends State<_RecordsFilterSheet> {
  late _RecordsDateFilter _date = widget.selectedDate;
  late _RecordsTypeFilter _type = widget.selectedType;

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
                    context.l10n.recordsFilterTitle,
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
            _FilterSectionTitle(
              iconAsset: RecordsAssets.filterDate,
              label: context.l10n.recordsFilterByDate,
            ),
            const SizedBox(height: 8),
            for (final value in _RecordsDateFilter.values)
              _FilterChoice(
                key: Key('records-date-${value.name}'),
                label: labels[value]!,
                selected: value == _date,
                onTap: () => setState(() => _date = value),
              ),
            const SizedBox(height: 12),
            _FilterSectionTitle(
              iconAsset: RecordsAssets.filterType,
              label: context.l10n.recordsSelectTypes,
            ),
            const SizedBox(height: 8),
            for (final value in _RecordsTypeFilter.values)
              _FilterChoice(
                key: Key('records-type-${value.name}'),
                label: switch (value) {
                  _RecordsTypeFilter.all => context.l10n.recordsAll,
                  _RecordsTypeFilter.d2d => context.l10n.d2d,
                  _RecordsTypeFilter.mrf => context.l10n.collectionMrfShort,
                  _RecordsTypeFilter.ramp => context.l10n.ramp,
                },
                selected: value == _type,
                onTap: () => setState(() => _type = value),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                key: const Key('records-apply-filter'),
                onPressed: () =>
                    Navigator.pop(context, (date: _date, type: _type)),
                child: Text(context.l10n.recordsApplyFilter),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSectionTitle extends StatelessWidget {
  const _FilterSectionTitle({required this.iconAsset, required this.label});
  final String iconAsset;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      SvgPicture.asset(iconAsset, width: 24, height: 24),
      const SizedBox(width: 8),
      Text(label, style: AppTextStyles.mediumSH8_14),
    ],
  );
}

class _FilterChoice extends StatelessWidget {
  const _FilterChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _RecordsRadio(selected: selected),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.regularB7_14),
        ],
      ),
    ),
  );
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
