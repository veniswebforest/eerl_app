import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/transfer_request_item.dart';
import '../widgets/transfer_request_card.dart';
import '../widgets/transfer_request_filter_bar.dart';

class TransferRequestsScreen extends StatefulWidget {
  const TransferRequestsScreen({
    super.key,
    required this.onBack,
    this.viewMode = TransferRequestsViewMode.populated,
    this.initialFilter = TransferRequestFilter.all,
    this.onAddTap,
    this.onRequestTap,
  });

  final VoidCallback onBack;
  final TransferRequestsViewMode viewMode;
  final TransferRequestFilter initialFilter;
  final VoidCallback? onAddTap;
  final ValueChanged<TransferRequestItem>? onRequestTap;

  @override
  State<TransferRequestsScreen> createState() => _TransferRequestsScreenState();
}

class _TransferRequestsScreenState extends State<TransferRequestsScreen> {
  late TransferRequestFilter _filter = widget.initialFilter;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void didUpdateWidget(covariant TransferRequestsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilter != widget.initialFilter) {
      _filter = widget.initialFilter;
    }
  }

  static const _items = [
    TransferRequestItem(
      id: '#TRF-2026-089',
      totalWeight: '240.00 KG',
      date: '22 October',
      time: '11:15 AM',
      status: TransferRequestStatus.pending,
    ),
    TransferRequestItem(
      id: '#TRF-2026-089',
      totalWeight: '240.00 KG',
      date: '22 October',
      time: '11:15 AM',
      status: TransferRequestStatus.rejected,
    ),
    TransferRequestItem(
      id: '#TRF-2026-089',
      totalWeight: '240.20 KG',
      date: '21 October',
      time: '09:15 AM',
      status: TransferRequestStatus.approved,
    ),
    TransferRequestItem(
      id: '#TRF-2026-089',
      totalWeight: '240.20 KG',
      date: '21 October',
      time: '09:15 AM',
      status: TransferRequestStatus.dispatch,
    ),
    TransferRequestItem(
      id: '#TRF-2026-089',
      totalWeight: '240.00 KG',
      date: '20 October',
      time: '12:15 PM',
      status: TransferRequestStatus.rejected,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransferRequestItem> get _visibleItems {
    if (widget.viewMode == TransferRequestsViewMode.empty) return const [];
    final normalizedQuery = _query.trim().toLowerCase();
    return _items
        .where((item) {
          final matchesFilter = switch (_filter) {
            TransferRequestFilter.all =>
              item.status != TransferRequestStatus.rejected,
            TransferRequestFilter.pending =>
              item.status == TransferRequestStatus.pending,
            TransferRequestFilter.dispatch =>
              item.status == TransferRequestStatus.dispatch,
            TransferRequestFilter.closed =>
              item.status == TransferRequestStatus.approved ||
                  item.status == TransferRequestStatus.rejected,
          };
          return matchesFilter &&
              (normalizedQuery.isEmpty ||
                  item.id.toLowerCase().contains(normalizedQuery));
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;
    final labels = {
      TransferRequestFilter.all: context.l10n.transferFilterAll,
      TransferRequestFilter.pending: context.l10n.transferFilterPending,
      TransferRequestFilter.dispatch: context.l10n.transferFilterDispatch,
      TransferRequestFilter.closed: context.l10n.transferFilterClosed,
    };

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: context.l10n.transferRequests,
        onBackTap: widget.onBack,
        backIconAsset: 'assets/icons/records/back.svg',
      ),
      floatingActionButton: _TransferAddButton(onTap: widget.onAddTap ?? () {}),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      TransferRequestFilterBar(
                        searchHint: context.l10n.transferSearchHint,
                        searchController: _searchController,
                        selectedFilter: _filter,
                        labels: labels,
                        onSearchChanged: (value) =>
                            setState(() => _query = value),
                        onFilterChanged: (value) =>
                            setState(() => _filter = value),
                      ),
                      // const _DestinationCard(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: items.isEmpty
                      ? _EmptyTransferRequests(
                          label: context.l10n.transferEmptyMessage,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, index) => TransferRequestCard(
                            key: ValueKey('${items[index].status.name}-$index'),
                            item: items[index],
                            highlighted: index == 0,
                            onTap: () =>
                                widget.onRequestTap?.call(items[index]),
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
}

class _EmptyTransferRequests extends StatelessWidget {
  const _EmptyTransferRequests({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/transfer_request_empty.jpg',
          width: 180,
          height: 92,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: AppTextStyles.regularB7_14.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ],
    ),
  );
}

class _TransferAddButton extends StatelessWidget {
  const _TransferAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    width: 72,
    height: 72,
    padding: const EdgeInsets.all(5),
    decoration: const BoxDecoration(
      color: AppColors.primary200,
      shape: BoxShape.circle,
    ),
    child: Container(
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: AppColors.primary300,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: AppColors.primary500,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          key: const Key('transfer-request-add'),
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/help_support/add.svg',
              width: 34,
              height: 34,
              colorFilter: const ColorFilter.mode(
                AppColors.neutral50,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
