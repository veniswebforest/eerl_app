import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/prices/model/price_ui_models.dart';
import 'package:eerl_app/features/prices/view/price_request_detail_screen.dart';
import 'package:eerl_app/features/prices/widgets/prices_ui.dart';

class PriceRequestsScreen extends StatefulWidget {
  const PriceRequestsScreen({super.key});

  @override
  State<PriceRequestsScreen> createState() => _PriceRequestsScreenState();
}

class _PriceRequestsScreenState extends State<PriceRequestsScreen> {
  int _selectedTab = 0;

  static const _waiting = PriceRequestUiModel(
    kind: PriceMaterialKind.pet,
    oldRate: '45.00',
    newRate: '48.00',
    percent: '+6.7%',
    state: PriceRequestState.waiting,
  );

  static const _decided = <PriceRequestUiModel>[
    PriceRequestUiModel(
      kind: PriceMaterialKind.pp,
      oldRate: '28.50',
      newRate: '30.00',
      percent: '+5.3%',
      state: PriceRequestState.approved,
    ),
    PriceRequestUiModel(
      kind: PriceMaterialKind.hdpe,
      oldRate: '32.00',
      newRate: '35.00',
      percent: '+9.4%',
      state: PriceRequestState.rejected,
    ),
  ];

  @override
  Widget build(BuildContext context) => PricesPageFrame(
    title: context.l10n.priceRequestsTitle,
    child: Column(
      children: [
        PriceRequestTabs(
          index: _selectedTab,
          onChanged: (value) => setState(() => _selectedTab = value),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: IndexedStack(
            index: _selectedTab,
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  PriceRequestListCard(
                    request: _waiting,
                    onTap: () => _open(_waiting.state),
                  ),
                ],
              ),
              ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _decided.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final request = _decided[index];
                  return PriceRequestListCard(
                    request: request,
                    onTap: () => _open(request.state),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );

  void _open(PriceRequestState state) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => PriceRequestDetailScreen(state: state),
    ),
  );
}

class PriceRequestListCard extends StatelessWidget {
  const PriceRequestListCard({
    required this.request,
    required this.onTap,
    super.key,
  });

  final PriceRequestUiModel request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isWaiting = request.state == PriceRequestState.waiting;
    final isApproved = request.state == PriceRequestState.approved;
    final item = switch (request.kind) {
      PriceMaterialKind.pet => l10n.pricesPetBottles,
      PriceMaterialKind.hdpe => l10n.pricesHdpeRigid,
      PriceMaterialKind.pp => l10n.pricesPpHardPlastics,
      PriceMaterialKind.cardboard => l10n.pricesCardboard,
    };
    final reason = switch (request.kind) {
      PriceMaterialKind.pet => l10n.priceRequestPetReason,
      PriceMaterialKind.hdpe => l10n.priceRequestHdpeReason,
      PriceMaterialKind.pp => l10n.priceRequestPpReason,
      PriceMaterialKind.cardboard => l10n.priceRequestPetReason,
    };
    final statusColor = isWaiting
        ? const Color(0xFFF9AE00)
        : isApproved
        ? AppColors.primary500
        : AppColors.red500;
    final statusBackground = isWaiting
        ? AppColors.yellow50
        : isApproved
        ? AppColors.primary50
        : AppColors.red50;
    final statusText = isWaiting
        ? l10n.priceRequestWaiting
        : isApproved
        ? l10n.priceRequestApproved
        : l10n.priceRequestRejected;
    final statusIcon = isWaiting
        ? 'status_waiting.svg'
        : isApproved
        ? 'status_approved.svg'
        : 'status_rejected.svg';
    final time = isWaiting
        ? l10n.priceRequestToday1030
        : isApproved
        ? l10n.priceRequestToday0905
        : l10n.priceRequestYesterday1640;

    return Material(
      color: AppColors.neutral50,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.priceRequestItemCentre(
                      item,
                      l10n.pricesCentreSuratSouth,
                    ),
                    style: AppTextStyles.boldH8_14.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.priceRequestChange(
                            request.oldRate,
                            request.newRate,
                            request.percent,
                          ),
                          style: AppTextStyles.semiboldH9_14.copyWith(
                            color: AppColors.neutral950,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reason,
                          style: AppTextStyles.mediumSH8_14.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                        if (isApproved) ...[
                          const SizedBox(height: 4),
                          Text(
                            l10n.priceRequestApprovedBy,
                            style: AppTextStyles.mediumSH8_14.copyWith(
                              color: AppColors.primary500,
                            ),
                          ),
                        ],
                        if (!isWaiting && !isApproved) ...[
                          const SizedBox(height: 4),
                          Text(
                            l10n.priceRequestRejectionReasonShort,
                            style: AppTextStyles.mediumSH8_14.copyWith(
                              color: AppColors.red500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                '$pricesAssetPath/$statusIcon',
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  statusText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.mediumSH8_14.copyWith(
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            color: AppColors.neutral400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              PositionedDirectional(
                end: 0,
                top: 0,
                child: SvgPicture.asset(
                  '$pricesAssetPath/open_request.svg',
                  width: 14,
                  height: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
