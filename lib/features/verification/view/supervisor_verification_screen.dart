import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/verification_entry.dart';
import '../widgets/verification_entry_card.dart';
import '../widgets/verification_filter_chips.dart';
import '../widgets/verification_segmented_control.dart';
import 'package:go_router/go_router.dart';

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
  String _query = '';

  @override
  void didUpdateWidget(covariant SupervisorVerificationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatus != widget.initialStatus) {
      _status = widget.initialStatus;
      _selectedFilter = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries(context);

    return ColoredBox(
      key: ValueKey('verification-status-${_status.name}'),
      color: AppColors.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              key: const PageStorageKey('supervisor-verification-scroll'),
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
                        ),
                        const SizedBox(height: 20),
                        _VerificationSearchField(
                          hint: context.l10n.verificationSearchHint,
                          onChanged: (value) => setState(() => _query = value),
                        ),
                        const SizedBox(height: 16),
                        VerificationSegmentedControl(
                          value: _status,
                          pendingLabel: context.l10n.verificationPending,
                          processedLabel: context.l10n.verificationProcessed,
                          onChanged: (value) => setState(() {
                            _status = value;
                            _selectedFilter = 0;
                          }),
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
                          onSelected: (index) =>
                              setState(() => _selectedFilter = index),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                if (entries.isEmpty)
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
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => VerificationEntryCard(
                        key: ValueKey(
                          '${_status.name}-${entries[index].person}-$index',
                        ),
                        entry: entries[index],
                        onTap: () => context.push<void>(
                          AppRoutes.verificationDetail,
                          extra: switch (entries[index].result) {
                            VerificationResult.pending =>
                              VerificationDetailStatus.pending,
                            VerificationResult.verified =>
                              VerificationDetailStatus.approved,
                            VerificationResult.rejected =>
                              VerificationDetailStatus.rejected,
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<VerificationEntry> _filteredEntries(BuildContext context) {
    final entries = _entries(context, _status);
    final query = _query.trim().toLowerCase();
    return entries
        .where((entry) {
          final matchesFilter = switch (_selectedFilter) {
            1 => entry.collectionType == context.l10n.verificationFilterD2d,
            2 => entry.collectionType == context.l10n.verificationFilterMrf,
            3 => entry.collectionType == context.l10n.verificationFilterRamp,
            _ => true,
          };
          final matchesQuery =
              query.isEmpty ||
              entry.person.toLowerCase().contains(query) ||
              entry.collectionType.toLowerCase().contains(query) ||
              entry.collectionIdAndTime.toLowerCase().contains(query) ||
              entry.facility.toLowerCase().contains(query);
          return matchesFilter && matchesQuery;
        })
        .toList(growable: false);
  }

  List<VerificationEntry> _entries(
    BuildContext context,
    VerificationListStatus status,
  ) {
    final l10n = context.l10n;
    if (status == VerificationListStatus.pending) {
      return [
        VerificationEntry(
          person: l10n.verificationRahulPatel,
          collectionType: l10n.verificationFilterD2d,
          weightAndAmount: l10n.verificationWeightAmount,
          collectionIdAndTime: l10n.verificationIdTime0925,
          facility: l10n.verificationSuratSouth,
          result: VerificationResult.pending,
          highlighted: true,
        ),
        VerificationEntry(
          person: l10n.verificationAmitShah,
          collectionType: l10n.verificationMrfStation,
          weightAndAmount: l10n.verificationWeightAmount,
          collectionIdAndTime: l10n.verificationIdTime1125,
          facility: l10n.verificationSuratNorth,
          result: VerificationResult.pending,
        ),
        VerificationEntry(
          person: l10n.verificationNareshModi,
          collectionType: l10n.verificationFilterRamp,
          weightAndAmount: l10n.verificationWeightAmount,
          collectionIdAndTime: l10n.verificationIdTime1225,
          facility: l10n.verificationSuratWest,
          result: VerificationResult.pending,
        ),
        VerificationEntry(
          person: l10n.verificationAmitShah,
          collectionType: l10n.verificationFilterRamp,
          weightAndAmount: l10n.verificationWeightAmount,
          collectionIdAndTime: l10n.verificationIdTime0225,
          facility: l10n.verificationSuratSouth,
          result: VerificationResult.pending,
        ),
      ];
    }

    return [
      VerificationEntry(
        person: l10n.verificationAmitShah,
        collectionType: l10n.verificationMrfStation,
        weightAndAmount: l10n.verificationWeightAmount,
        collectionIdAndTime: l10n.verificationIdTime1125,
        facility: l10n.verificationSuratSouth,
        result: VerificationResult.rejected,
      ),
      VerificationEntry(
        person: l10n.verificationRahulPatel,
        collectionType: l10n.verificationFilterD2d,
        weightAndAmount: l10n.verificationWeightAmount,
        collectionIdAndTime: l10n.verificationIdTime0925,
        facility: l10n.verificationSuratNorth,
        result: VerificationResult.verified,
        highlighted: true,
      ),
      VerificationEntry(
        person: l10n.verificationNareshModi,
        collectionType: l10n.verificationFilterRamp,
        weightAndAmount: l10n.verificationWeightAmount,
        collectionIdAndTime: l10n.verificationIdTime1225,
        facility: l10n.verificationSuratWest,
        result: VerificationResult.verified,
      ),
      VerificationEntry(
        person: l10n.verificationAmitShah,
        collectionType: l10n.verificationFilterRamp,
        weightAndAmount: l10n.verificationWeightAmount,
        collectionIdAndTime: l10n.verificationIdTime0225,
        facility: l10n.verificationSuratSouth,
        result: VerificationResult.rejected,
      ),
    ];
  }
}

class _VerificationHeader extends StatelessWidget {
  const _VerificationHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

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
        key: const Key('verification-filter-button'),
        onPressed: () {},
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
        icon: SvgPicture.asset(
          'assets/icons/records/filter.svg',
          width: 28,
          height: 28,
        ),
      ),
    ],
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
      style: AppTextStyles.regularB7_14.copyWith(color: AppColors.neutral900),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.regularB7_14.copyWith(
          color: AppColors.neutral500,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(16),
          child: SvgPicture.asset(
            'assets/icons/wallet/search.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.cool600,
              BlendMode.srcIn,
            ),
          ),
        ),
        filled: true,
        fillColor: AppColors.neutral50,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
