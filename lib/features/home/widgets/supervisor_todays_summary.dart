import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'home_assets.dart';
import 'home_styles.dart';

class SupervisorTodaysSummary extends StatefulWidget {
  const SupervisorTodaysSummary({super.key});

  @override
  State<SupervisorTodaysSummary> createState() =>
      _SupervisorTodaysSummaryState();
}

class _SupervisorTodaysSummaryState extends State<SupervisorTodaysSummary> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SupervisorSummaryItem(
        icon: HomeAssets.supervisorActiveAgents,
        iconBackground: AppColors.secondary100,
        label: context.l10n.supervisorActiveAgents,
        value: const TextSpan(text: '03'),
        valueColor: AppColors.secondary500,
      ),
      _SupervisorSummaryItem(
        icon: HomeAssets.supervisorTransportsDone,
        iconBackground: AppColors.orchidLight,
        label: context.l10n.supervisorTransportsDone,
        value: TextSpan(
          children: [
            const TextSpan(
              text: '12',
              style: TextStyle(color: AppColors.orchid),
            ),
            TextSpan(
              text: '/16',
              style: TextStyle(color: AppColors.neutral700),
            ),
          ],
        ),
        valueColor: AppColors.orchid,
      ),
      _SupervisorSummaryItem(
        icon: HomeAssets.supervisorTotalStocks,
        iconBackground: AppColors.purpleLight,
        label: context.l10n.supervisorTotalStocks,
        value: const TextSpan(text: '2,840 KG'),
        valueColor: AppColors.purple,
      ),
      _SupervisorSummaryItem(
        icon: HomeAssets.supervisorPendingExpenses,
        iconBackground: AppColors.yellow50,
        label: context.l10n.supervisorPendingExpenses,
        value: const TextSpan(text: '04'),
        valueColor: AppColors.yellow600,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.todaysSummary,
                style: HomeStyles.sectionTitle,
              ),
            ),
            Semantics(
              button: true,
              toggled: _isVisible,
              label: _isVisible
                  ? context.l10n.hideTodaysSummary
                  : context.l10n.showTodaysSummary,
              child: Tooltip(
                message: _isVisible
                    ? context.l10n.hideTodaysSummary
                    : context.l10n.showTodaysSummary,
                child: InkWell(
                  key: const Key('supervisor-toggle-todays-summary'),
                  onTap: () => setState(() => _isVisible = !_isVisible),
                  borderRadius: BorderRadius.circular(20),
                  child: SvgPicture.asset(
                    _isVisible
                        ? HomeAssets.supervisorSummaryEye
                        : HomeAssets.summaryHide,
                    key: ValueKey(
                      _isVisible
                          ? 'supervisor-summary-visible-icon'
                          : 'supervisor-summary-hidden-icon',
                    ),
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          alignment: Alignment.topCenter,
          child: _isVisible
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth < 320 ? 1 : 2;
                      final width =
                          (constraints.maxWidth - (columns - 1) * 8) / columns;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: items
                            .map(
                              (item) => SizedBox(
                                width: width,
                                child: _SupervisorSummaryCard(item: item),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _SupervisorSummaryItem {
  const _SupervisorSummaryItem({
    required this.icon,
    required this.iconBackground,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String icon;
  final Color iconBackground;
  final String label;
  final InlineSpan value;
  final Color valueColor;
}

class _SupervisorSummaryCard extends StatelessWidget {
  const _SupervisorSummaryCard({required this.item});

  final _SupervisorSummaryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 122,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [HomeStyles.cardShadow],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.iconBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(item.icon),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 48,
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiboldH9_14.copyWith(
                color: AppColors.neutral900,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 70,
            child: Text.rich(
              item.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiboldH6_20.copyWith(
                color: item.valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
