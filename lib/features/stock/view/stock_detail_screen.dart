import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/features/records/widgets/collection_detail_assets.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import '../model/stock_item.dart';
import '../widgets/stock_material_card.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({
    super.key,
    required this.stage,
    this.stockLoader,
    this.centerNameLoader,
  });

  final StockStage stage;
  final Future<List<StockModel>> Function(String stage)? stockLoader;
  final Future<String?> Function()? centerNameLoader;
  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late final LocalQueryController<List<StockModel>> _controller;
  String? _activeCenterName;

  String get _stage => switch (widget.stage) {
    StockStage.rawMaterial => 'RM',
    StockStage.sortedRawMaterial => 'SRM',
    StockStage.workInProgress => 'WIP',
    StockStage.finishedGoods => 'FG',
  };

  String _title(BuildContext context) => switch (widget.stage) {
    StockStage.rawMaterial => context.l10n.stockRmDetail,
    StockStage.sortedRawMaterial => context.l10n.stockSrmDetail,
    StockStage.workInProgress => context.l10n.stockWipDetail,
    StockStage.finishedGoods => context.l10n.stockFgDetail,
  };

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(
      () =>
          widget.stockLoader?.call(_stage) ??
          EerlLocalRepository.instance.getStock(stage: _stage),
    )..load();
    _loadActiveCenterName();
  }

  Future<void> _loadActiveCenterName() async {
    final name =
        await (widget.centerNameLoader?.call() ?? _readActiveCenterName());
    if (!mounted) return;
    setState(() => _activeCenterName = name);
  }

  Future<String?> _readActiveCenterName() async {
    final repository = EerlLocalRepository.instance;
    final centerId = await repository.activeCenterId;
    if (centerId == null || centerId.isEmpty) return null;
    return (await repository.getCenter(centerId))?.name;
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final items = _controller.data ?? const <StockModel>[];
              final centerName =
                  items.firstOrNull?.centerName?.trim().isNotEmpty == true
                  ? items.first.centerName
                  : _activeCenterName;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      AppScreenHeaderMetrics.topInset,
                      20,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppScreenHeader(
                          leading: _BackButton(
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _title(context),
                          style: AppTextStyles.semiboldH6_20.copyWith(
                            color: AppColors.neutral950,
                          ),
                        ),
                        if (centerName?.trim().isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.stockCenterName(centerName!),
                            style: AppTextStyles.mediumSH8_14.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _controller.isLoading && !_controller.hasData
                        ? const Center(child: CircularProgressIndicator())
                        : items.isEmpty
                        ? const _StockEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return StockMaterialCard(
                                item: item,
                                fallbackImage: _fallbackImage(item, index),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );

  String _fallbackImage(StockModel item, int index) {
    final name = (item.name ?? item.itemId).toLowerCase();
    if (name.contains('pet')) return 'assets/images/stock/rm_2.png';
    if (name.contains('hdpe') ||
        name.contains('rigid') ||
        name.contains('pipe')) {
      return 'assets/images/stock/rm_1.png';
    }
    if (name.contains('metal')) return 'assets/images/stock/rm_3.png';
    if (name.contains('glass')) return 'assets/images/stock/rm_4.png';
    if (name.contains('paper') || name.contains('cardboard')) {
      return 'assets/images/stock/rm_5.png';
    }
    return 'assets/images/stock/rm_${(index % 5) + 1}.png';
  }
}

class _StockEmptyState extends StatelessWidget {
  const _StockEmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/images/tasks/empty.svg',
          width: 213,
          height: 236,
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.stockEmptyMessage,
          style: AppTextStyles.semiboldH8_16.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    ),
  );
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    key: const Key('stock-detail-back'),
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary500,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SvgPicture.asset(CollectionDetailAssets.back),
    ),
  );
}
