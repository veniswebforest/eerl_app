import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import '../model/verification_entry.dart';
import '../widgets/verification_entry_card.dart';
import '../widgets/verification_filter_chips.dart';
import '../widgets/verification_segmented_control.dart';

class SupervisorVerificationScreen extends StatefulWidget {
  const SupervisorVerificationScreen({
    super.key,
    this.initialStatus = VerificationListStatus.pending,
  });
  final VerificationListStatus initialStatus;
  @override
  State<SupervisorVerificationScreen> createState() =>
      _SupervisorVerificationScreenState();
}

class _SupervisorVerificationScreenState
    extends State<SupervisorVerificationScreen> {
  late VerificationListStatus _status = widget.initialStatus;
  int _selectedFilter = 0;
  _VerificationDateFilter _dateFilter = _VerificationDateFilter.today;
  String _query = '';
  late final LocalQueryController<List<CollectionModel>> _controller;
  int _bootstrapRevision = -1;

  String? get _channel => switch (_selectedFilter) {
    1 => 'D2D',
    2 => 'MRF',
    3 => 'RAMP',
    _ => null,
  };

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(
      () => EerlLocalRepository.instance.getVerificationCollections(
        pending: _status == VerificationListStatus.pending,
        channel: _channel,
        search: _query,
      ),
    )..load();
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
  void didUpdateWidget(covariant SupervisorVerificationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatus != widget.initialStatus) {
      _status = widget.initialStatus;
      _selectedFilter = 0;
      _controller.load();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    key: ValueKey('verification-status-${_status.name}'),
    color: AppColors.backgroundColor,
    child: SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final entries = (_controller.data ?? const <CollectionModel>[])
                  .where(_matchesDate)
                  .toList(growable: false);
              return RefreshIndicator(
                key: const Key('verification-pull-to-refresh'),
                color: AppColors.primary500,
                onRefresh: _controller.load,
                child: CustomScrollView(
                  key: const PageStorageKey('supervisor-verification-scroll'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _VerificationHeader(
                              title: context.l10n.verificationCollectionHistory,
                              subtitle: context.l10n.verificationSubtitle,
                              onFilter: _showDateFilter,
                            ),
                            const SizedBox(height: 20),
                            _VerificationSearchField(
                              hint: context.l10n.verificationSearchHint,
                              onChanged: (value) {
                                _query = value;
                                _controller.load();
                              },
                            ),
                            const SizedBox(height: 16),
                            VerificationSegmentedControl(
                              value: _status,
                              pendingLabel: context.l10n.verificationPending,
                              processedLabel:
                                  context.l10n.verificationProcessed,
                              onChanged: (value) {
                                setState(() {
                                  _status = value;
                                  _selectedFilter = 0;
                                });
                                _controller.load();
                              },
                            ),
                            const SizedBox(height: 12),
                            VerificationFilterChips(
                              labels: [
                                context.l10n.verificationFilterAll,
                                context.l10n.verificationFilterD2d,
                                context.l10n.verificationFilterMrf,
                                context.l10n.verificationFilterRamp,
                              ],
                              selectedIndex: _selectedFilter,
                              onSelected: (index) {
                                setState(() => _selectedFilter = index);
                                _controller.load();
                              },
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
                    if (_controller.isLoading && !_controller.hasData)
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_controller.error != null)
                      SliverFillRemaining(
                        child: Center(
                          child: TextButton(
                            onPressed: _controller.load,
                            child: const Text('Retry'),
                          ),
                        ),
                      )
                    else if (entries.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            context.l10n.verificationEmpty,
                            style: AppTextStyles.mediumSH8_14.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
                        sliver: SliverList.separated(
                          itemCount: entries.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              VerificationEntryCard(
                                key: ValueKey(entries[index].id),
                                entry: entries[index],
                                onTap: () async {
                                  await context.push<void>(
                                    AppRoutes.verificationDetail,
                                    extra: entries[index].id,
                                  );
                                  if (mounted) _controller.load();
                                },
                              ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  bool _matchesDate(CollectionModel item) {
    final value = DateTime.tryParse(
      item.collectedAt ?? item.updatedAt,
    )?.toLocal();
    if (value == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(value.year, value.month, value.day);
    return switch (_dateFilter) {
      _VerificationDateFilter.today => day == today,
      _VerificationDateFilter.yesterday =>
        day == today.subtract(const Duration(days: 1)),
      _VerificationDateFilter.lastSevenDays =>
        !day.isBefore(today.subtract(const Duration(days: 6))) &&
            !day.isAfter(today),
    };
  }

  Future<void> _showDateFilter() async {
    final selected = await showModalBottomSheet<_VerificationDateFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (context) => _VerificationDateFilterSheet(selected: _dateFilter),
    );
    if (selected != null && mounted) {
      setState(() => _dateFilter = selected);
    }
  }
}

class _VerificationHeader extends StatelessWidget {
  const _VerificationHeader({
    required this.title,
    required this.subtitle,
    required this.onFilter,
  });
  final String title;
  final String subtitle;
  final VoidCallback onFilter;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.semiboldH6_20.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.mediumSH8_14.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 24),
      IconButton(
        key: const Key('verification-date-filter'),
        onPressed: onFilter,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        icon: SvgPicture.asset(
          'assets/icons/records/filter.svg',
          width: 28,
          height: 28,
        ),
      ),
    ],
  );
}

enum _VerificationDateFilter { today, yesterday, lastSevenDays }

class _VerificationDateFilterSheet extends StatelessWidget {
  const _VerificationDateFilterSheet({required this.selected});

  final _VerificationDateFilter selected;

  @override
  Widget build(BuildContext context) {
    final labels = <_VerificationDateFilter, String>{
      _VerificationDateFilter.today: context.l10n.recordsFilterToday,
      _VerificationDateFilter.yesterday: context.l10n.recordsFilterYesterday,
      _VerificationDateFilter.lastSevenDays:
          context.l10n.recordsFilterLastSevenDays,
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
                  key: const Key('verification-filter-close'),
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
            for (final value in _VerificationDateFilter.values)
              InkWell(
                key: Key('verification-date-${value.name}'),
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
                      _VerificationRadio(selected: value == selected),
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

class _VerificationRadio extends StatelessWidget {
  const _VerificationRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 18,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: selected ? AppColors.primary500 : AppColors.cool500,
        width: selected ? 5 : 1.5,
      ),
    ),
  );
}

class _VerificationSearchField extends StatelessWidget {
  const _VerificationSearchField({required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 55,
    child: TextField(
      key: const Key('verification-search-field'),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(16),
          child: SvgPicture.asset('assets/icons/wallet/search.svg'),
        ),
        filled: true,
        fillColor: AppColors.neutral50,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.cool400),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary500),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
