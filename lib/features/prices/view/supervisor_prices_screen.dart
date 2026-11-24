import 'dart:async';

import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/features/prices/model/price_ui_models.dart';
import 'package:eerl_app/features/prices/view/ask_price_change_screen.dart';
import 'package:eerl_app/features/prices/view/price_request_detail_screen.dart';
import 'package:eerl_app/features/prices/view/price_requests_screen.dart';
import 'package:eerl_app/features/prices/widgets/prices_ui.dart';

class SupervisorPricesScreen extends StatefulWidget {
  const SupervisorPricesScreen({super.key});

  @override
  State<SupervisorPricesScreen> createState() => _SupervisorPricesScreenState();
}

class _SupervisorPricesScreenState extends State<SupervisorPricesScreen> {
  late final LocalQueryController<_PricesData> _query;

  @override
  void initState() {
    super.initState();
    _query = LocalQueryController(_load)..addListener(_changed);
    unawaited(_query.load());
  }

  Future<_PricesData> _load() async {
    final repository = EerlLocalRepository.instance;
    final centers = await repository.getCenters();
    final activeCenterId = await repository.activeCenterId;
    final results = await Future.wait<Object>([
      repository.getCenterPrices(centerId: activeCenterId),
      repository.getPriceRequests(centerId: activeCenterId),
    ]);
    return _PricesData(
      centers: centers,
      activeCenterId: activeCenterId,
      prices: results[0] as List<CenterPriceModel>,
      requests: results[1] as List<PriceRequestModel>,
    );
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _query.removeListener(_changed);
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _query.data;
    return PricesPageFrame(
      title: context.l10n.pricesTitle,
      subtitle: context.l10n.pricesSubtitle,
      child: _query.isLoading && data == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  PriceCentreSelector(
                    centers: data?.centers ?? const [],
                    activeCenterId: data?.activeCenterId,
                    onSelected: _selectCenter,
                  ),
                  const SizedBox(height: 16),
                  PriceRequestsBanner(
                    waitingCount:
                        data?.requests
                            .where((request) => request.status == 'PENDING')
                            .length ??
                        0,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            PriceRequestsScreen(centerId: data?.activeCenterId),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.pricesMaterials,
                    style: AppTextStyles.semiboldH7_18.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_query.error != null)
                    _MessageCard(context.l10n.priceRequestLoadFailed)
                  else if (data?.prices.isEmpty ?? true)
                    _MessageCard(context.l10n.pricesNoMaterials)
                  else
                    for (
                      var index = 0;
                      index < data!.prices.length;
                      index++
                    ) ...[
                      PriceMaterialCard(
                        material: _uiMaterial(data.prices[index], index),
                        onTap: () => _openMaterial(data.prices[index]),
                      ),
                      const SizedBox(height: 16),
                    ],
                ],
              ),
            ),
    );
  }

  Future<void> _selectCenter(String centerId) async {
    await EerlLocalRepository.instance.selectCenter(centerId);
    await _query.load();
  }

  Future<void> _refresh() async {
    await BootstrapSyncService.instance.triggerBootstrap(
      trigger: BootstrapTrigger.pullToRefresh,
    );
    await _query.load();
  }

  void _openMaterial(CenterPriceModel price) {
    final page = price.waitingRate == null
        ? AskPriceChangeScreen(
            requestContext: PriceRequestContext(
              itemId: price.itemId,
              itemName: price.itemName,
              unitCode: price.unitCode,
              currentRate: price.rate,
              fromName: price.fromName,
              fromLevel: price.fromLevel,
            ),
          )
        : PriceRequestDetailScreen(
            request: _query.data!.requests.firstWhere(
              (request) =>
                  request.itemId == price.itemId && request.status == 'PENDING',
            ),
          );
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  PriceMaterialUiModel _uiMaterial(CenterPriceModel price, int index) {
    final visual = _visuals[index % _visuals.length];
    final source = price.rate == null
        ? context.l10n.pricesAskForOne
        : price.own
        ? context.l10n.pricesOwnPrice
        : price.fromName?.trim().isNotEmpty == true
        ? context.l10n.pricesFromSource(
            price.fromName!,
            _levelLabel(price.fromLevel),
          )
        : context.l10n.pricesOwnPrice;
    return PriceMaterialUiModel(
      kind: visual.kind,
      itemId: price.itemId,
      name: price.itemName,
      categoryName: price.categoryName,
      unitCode: price.unitCode,
      rate: price.rate,
      source: source,
      waitingRate: price.waitingRate,
      accent: visual.accent,
      background: visual.background,
      iconAsset: visual.icon,
      openIconAsset: visual.openIcon,
    );
  }

  String _levelLabel(String? value) {
    final normalized = value?.trim().replaceAll('_', ' ').toLowerCase();
    if (normalized == null || normalized.isEmpty) return '';
    return normalized
        .split(' ')
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

class _PricesData {
  const _PricesData({
    required this.centers,
    required this.activeCenterId,
    required this.prices,
    required this.requests,
  });

  final List<CenterModel> centers;
  final String? activeCenterId;
  final List<CenterPriceModel> prices;
  final List<PriceRequestModel> requests;
}

class _PriceVisual {
  const _PriceVisual({
    required this.kind,
    required this.accent,
    required this.background,
    required this.icon,
    required this.openIcon,
  });
  final PriceMaterialKind kind;
  final Color accent;
  final Color background;
  final String icon;
  final String openIcon;
}

const _visuals = <_PriceVisual>[
  _PriceVisual(
    kind: PriceMaterialKind.pet,
    accent: AppColors.purple,
    background: AppColors.purpleLight,
    icon: '$pricesAssetPath/pet.svg',
    openIcon: '$pricesAssetPath/open_purple.svg',
  ),
  _PriceVisual(
    kind: PriceMaterialKind.hdpe,
    accent: AppColors.secondary500,
    background: AppColors.secondary100,
    icon: '$pricesAssetPath/hdpe.svg',
    openIcon: '$pricesAssetPath/open_blue.svg',
  ),
  _PriceVisual(
    kind: PriceMaterialKind.pp,
    accent: AppColors.orchid,
    background: AppColors.orchidLight,
    icon: '$pricesAssetPath/pp.svg',
    openIcon: '$pricesAssetPath/open_orchid.svg',
  ),
  _PriceVisual(
    kind: PriceMaterialKind.cardboard,
    accent: AppColors.orange,
    background: AppColors.orangeLight,
    icon: '$pricesAssetPath/cardboard.svg',
    openIcon: '$pricesAssetPath/open_orange.svg',
  ),
];

class _MessageCard extends StatelessWidget {
  const _MessageCard(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(message, textAlign: TextAlign.center),
  );
}
