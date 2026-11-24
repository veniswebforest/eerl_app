import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/features/prices/view/price_request_detail_screen.dart';
import 'package:eerl_app/features/prices/widgets/prices_ui.dart';

class PriceRequestsScreen extends StatefulWidget {
  const PriceRequestsScreen({super.key, this.centerId});

  final String? centerId;

  @override
  State<PriceRequestsScreen> createState() => _PriceRequestsScreenState();
}

class _PriceRequestsScreenState extends State<PriceRequestsScreen> {
  int _selectedTab = 0;
  late final LocalQueryController<List<PriceRequestModel>> _query;

  @override
  void initState() {
    super.initState();
    _query = LocalQueryController(
      () => EerlLocalRepository.instance.getPriceRequests(
        centerId: widget.centerId,
      ),
    )..addListener(_changed);
    unawaited(_query.load());
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
    final requests = _query.data ?? const <PriceRequestModel>[];
    final waiting = requests
        .where((request) => request.status == 'PENDING')
        .toList(growable: false);
    final decided = requests
        .where((request) => request.status != 'PENDING')
        .toList(growable: false);
    return PricesPageFrame(
      title: context.l10n.priceRequestsTitle,
      child: Column(
        children: [
          PriceRequestTabs(
            index: _selectedTab,
            waitingCount: waiting.length,
            decidedCount: decided.length,
            onChanged: (value) => setState(() => _selectedTab = value),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _query.isLoading && _query.data == null
                ? const Center(child: CircularProgressIndicator())
                : IndexedStack(
                    index: _selectedTab,
                    children: [
                      _RequestList(requests: waiting),
                      _RequestList(requests: decided),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({required this.requests});
  final List<PriceRequestModel> requests;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(child: Text(context.l10n.priceRequestsEmpty));
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final request = requests[index];
        return PriceRequestListCard(
          request: request,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => PriceRequestDetailScreen(request: request),
            ),
          ),
        );
      },
    );
  }
}

class PriceRequestListCard extends StatelessWidget {
  const PriceRequestListCard({
    required this.request,
    required this.onTap,
    super.key,
  });

  final PriceRequestModel request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isWaiting = request.status == 'PENDING';
    final isApproved = request.status == 'APPROVED';
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
    final itemName = request.itemName ?? request.itemId;
    final centreName = request.centerName ?? request.centerId;
    final decidedNote = isApproved
        ? request.decidedByName?.trim().isNotEmpty == true
              ? l10n.priceRequestApprovedByPerson(request.decidedByName!)
              : null
        : request.rejectionReason?.trim().isNotEmpty == true
        ? l10n.priceRequestReasonValue(request.rejectionReason!)
        : null;

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
                    l10n.priceRequestItemCentre(itemName, centreName),
                    style: AppTextStyles.boldH8_14.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cool100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.priceRequestChange(
                            _rate(request.currentRate),
                            _rate(request.requestedRate),
                            _percent(
                              request.currentRate,
                              request.requestedRate,
                            ),
                          ),
                          style: AppTextStyles.semiboldH9_14.copyWith(
                            color: AppColors.neutral950,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.reason,
                          style: AppTextStyles.mediumSH8_14.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                        if (decidedNote != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            decidedNote,
                            style: AppTextStyles.mediumSH8_14.copyWith(
                              color: isApproved
                                  ? AppColors.primary500
                                  : AppColors.red500,
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
                          _time(context, request.raisedAt),
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

String _rate(double? value) => value?.toStringAsFixed(2) ?? '0.00';

String _percent(double? current, double requested) {
  if (current == null || current == 0) return '+0.0%';
  final value = ((requested - current) / current) * 100;
  return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}%';
}

String _time(BuildContext context, String value) {
  final parsed = DateTime.tryParse(value)?.toLocal();
  if (parsed == null) return value;
  return DateFormat(
    'd MMM, h:mm a',
    Localizations.localeOf(context).toString(),
  ).format(parsed);
}
