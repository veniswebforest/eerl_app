import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/home/widgets/home_assets.dart';
import 'package:eerl_app/features/home/widgets/zone_selector.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import '../model/stock_item.dart';
import '../widgets/stock_stage_card.dart';

class FacilityStockScreen extends StatefulWidget {
  const FacilityStockScreen({super.key});
  @override
  State<FacilityStockScreen> createState() => _FacilityStockScreenState();
}

class _FacilityStockScreenState extends State<FacilityStockScreen> {
  String? _centerId;
  late final LocalQueryController<
    ({List<CenterModel> centers, List<StockModel> stock, SyncStatusModel sync})
  >
  _controller;
  int _bootstrapRevision = -1;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(() async {
      _centerId ??= await EerlLocalRepository.instance.activeCenterId;
      final values = await Future.wait([
        EerlLocalRepository.instance.getCenters(),
        EerlLocalRepository.instance.getStock(centerId: _centerId),
        EerlLocalRepository.instance.getSyncStatus(),
      ]);
      return (
        centers: values[0] as List<CenterModel>,
        stock: values[1] as List<StockModel>,
        sync: values[2] as SyncStatusModel,
      );
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

  (double, int) _totals(List<StockModel> rows, String stage) {
    final matching = rows.where((row) => row.stage.toUpperCase() == stage);
    return (
      matching.fold<double>(0, (sum, row) => sum + row.qty),
      matching.length,
    );
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.backgroundColor,
    child: SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isLoading && !_controller.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = _controller.data;
              final centers = data?.centers ?? const <CenterModel>[];
              final stock = data?.stock ?? const <StockModel>[];
              return ListView(
                key: const PageStorageKey('facility-stock-scroll'),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.stockTitle,
                              style: AppTextStyles.semiboldH6_20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.startYourCollections,
                              style: AppTextStyles.mediumSH8_14.copyWith(
                                color: AppColors.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SvgPicture.asset(
                        HomeAssets.notification,
                        width: 45,
                        height: 45,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (centers.isNotEmpty)
                    ZoneSelector(
                      key: ValueKey(_centerId),
                      initialLabel: centers
                          .firstWhere(
                            (center) => center.id == _centerId,
                            orElse: () => centers.first,
                          )
                          .name,
                      options: centers.map((center) => center.name).toList(),
                      onSelected: (index) async {
                        _centerId = centers[index].id;
                        await EerlLocalRepository.instance.selectCenter(
                          _centerId!,
                        );
                        _controller.load();
                      },
                    ),
                  const SizedBox(height: 16),
                  _UpdatedBanner(
                    label: context.l10n.stockLastUpdated,
                    value: data?.sync.lastBootstrapAt ?? '-',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.stockStageOverview,
                    style: AppTextStyles.semiboldH7_18,
                  ),
                  const SizedBox(height: 16),
                  ..._stageCards(context, stock),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );

  List<Widget> _stageCards(BuildContext context, List<StockModel> stock) {
    final definitions = <(String, StockStage, String, String, Color, Color)>[
      (
        'RM',
        StockStage.rawMaterial,
        context.l10n.stockRawMaterial,
        'assets/icons/stock_stage_rm.svg',
        AppColors.purple,
        AppColors.purpleLight,
      ),
      (
        'SRM',
        StockStage.sortedRawMaterial,
        context.l10n.stockSortedRawMaterial,
        'assets/icons/stock_stage_srm.svg',
        AppColors.secondary500,
        AppColors.secondary100,
      ),
      (
        'WIP',
        StockStage.workInProgress,
        context.l10n.stockWorkInProgress,
        'assets/icons/stock_stage_wip.svg',
        AppColors.orchid,
        AppColors.orchidLight,
      ),
      (
        'FG',
        StockStage.finishedGoods,
        context.l10n.stockFinishedGoods,
        'assets/icons/stock_stage_fg.svg',
        AppColors.orange,
        AppColors.orangeLight,
      ),
    ];
    return [
      for (final definition in definitions) ...[
        Builder(
          builder: (_) {
            final totals = _totals(stock, definition.$1);
            return StockStageCard(
              code: definition.$1,
              description: definition.$3,
              weight: '${totals.$1.toStringAsFixed(2)} kg',
              itemCount: '${totals.$2} items',
              icon: definition.$4,
              foreground: definition.$5,
              iconBackground: definition.$6,
              onTap: () => context.push<void>(
                AppRoutes.stockDetail,
                extra: definition.$2,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    ];
  }
}

class _UpdatedBanner extends StatelessWidget {
  const _UpdatedBanner({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: AppColors.primary50,
      border: Border.all(color: AppColors.primary500),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(Icons.circle, size: 10, color: AppColors.primary500),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppTextStyles.semiboldH9_14)),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
      ],
    ),
  );
}
