import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/features/records/widgets/collection_detail_assets.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import '../model/stock_item.dart';
import '../widgets/stock_material_card.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({super.key, required this.stage});
  final StockStage stage;
  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late final LocalQueryController<List<StockModel>> _controller;

  String get _stage => switch (widget.stage) {
    StockStage.rawMaterial => 'RM',
    StockStage.sortedRawMaterial => 'SRM',
    StockStage.workInProgress => 'WIP',
    StockStage.finishedGoods => 'FG',
  };

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(
      () => EerlLocalRepository.instance.getStock(stage: _stage),
    )..load();
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
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  AppScreenHeaderMetrics.topInset,
                  20,
                  24,
                ),
                itemCount: items.length + 1,
                separatorBuilder: (_, index) =>
                    SizedBox(height: index == 0 ? 24 : 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppScreenHeader(
                          leading: _BackButton(
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _stage,
                          style: AppTextStyles.semiboldH6_20.copyWith(
                            color: AppColors.neutral950,
                          ),
                        ),
                        if (items.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            items.first.centerName ?? items.first.centerId,
                            style: AppTextStyles.mediumSH8_14.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ],
                    );
                  }
                  return StockMaterialCard(item: items[index - 1]);
                },
              );
            },
          ),
        ),
      ),
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
