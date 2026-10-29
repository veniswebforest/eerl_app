import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'home_assets.dart';
import 'home_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';

class SupervisorTodaysSummary extends StatefulWidget {
  const SupervisorTodaysSummary({super.key});

  @override
  State<SupervisorTodaysSummary> createState() =>
      _SupervisorTodaysSummaryState();
}

class _SupervisorTodaysSummaryState extends State<SupervisorTodaysSummary> {
  bool _isVisible = true;
  int _bootstrapRevision = -1;
  late final LocalQueryController<SupervisorHomeSummaryModel> _controller;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(
      EerlLocalRepository.instance.getSupervisorHomeSummary,
    )..load();
    _bootstrapRevision = BootstrapSyncService.instance.revision;
    BootstrapSyncService.instance.addListener(_reloadAfterBootstrap);
    EerlLocalRepository.instance.activeCenterNotifier.addListener(
      _reloadAfterCenterChange,
    );
  }

  void _reloadAfterCenterChange() {
    if (mounted) _controller.load();
  }

  void _reloadAfterBootstrap() {
    final revision = BootstrapSyncService.instance.revision;
    if (revision == _bootstrapRevision) return;
    _bootstrapRevision = revision;
    _controller.load();
  }

  @override
  void dispose() {
    EerlLocalRepository.instance.activeCenterNotifier.removeListener(
      _reloadAfterCenterChange,
    );
    BootstrapSyncService.instance.removeListener(_reloadAfterBootstrap);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final summary = _controller.data;
        final items = [
          _SupervisorSummaryItem(
            icon: HomeAssets.supervisorActiveAgents,
            iconBackground: AppColors.secondary100,
            label: context.l10n.supervisorActiveAgents,
            value: TextSpan(text: '${summary?.activeAgents ?? 0}'),
            valueColor: AppColors.secondary500,
            onTap: () => context.push(AppRoutes.agentStatus),
          ),
          _SupervisorSummaryItem(
            icon: HomeAssets.supervisorTransportsDone,
            iconBackground: AppColors.orchidLight,
            label: context.l10n.supervisorTransportsDone,
            value: TextSpan(
              children: [
                TextSpan(
                  text: '${summary?.transfersDone ?? 0}',
                  style: TextStyle(color: AppColors.orchid),
                ),
                TextSpan(
                  text: '/${summary?.totalTransfers ?? 0}',
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
            value: TextSpan(
              text: '${(summary?.stockKg ?? 0).toStringAsFixed(2)} KG',
            ),
            valueColor: AppColors.purple,
          ),
          _SupervisorSummaryItem(
            icon: HomeAssets.supervisorPendingExpenses,
            iconBackground: AppColors.yellow50,
            label: context.l10n.supervisorPendingExpenses,
            value: TextSpan(text: '${summary?.pendingExpenses ?? 0}'),
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
                              (constraints.maxWidth - (columns - 1) * 8) /
                              columns;
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
      },
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
    this.onTap,
  });

  final String icon;
  final Color iconBackground;
  final String label;
  final InlineSpan value;
  final Color valueColor;
  final VoidCallback? onTap;
}

class _SupervisorSummaryCard extends StatelessWidget {
  const _SupervisorSummaryCard({required this.item});

  final _SupervisorSummaryItem item;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: 125,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [HomeStyles.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.iconBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(item.icon),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiboldH9_14.copyWith(
                color: AppColors.neutral900,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                item.value,
                maxLines: 1,
                style: AppTextStyles.semiboldH7_18.copyWith(
                  color: item.valueColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (item.onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: card,
        ),
      );
    }
    return card;
  }
}
