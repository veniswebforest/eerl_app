import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/transfer_request_item.dart';
import '../widgets/transfer_request_card.dart';
import '../widgets/transfer_request_filter_bar.dart';
import 'package:go_router/go_router.dart';

class TransferRequestsScreen extends StatefulWidget {
  const TransferRequestsScreen({
    super.key,
    this.viewMode = TransferRequestsViewMode.populated,
    this.initialFilter = TransferRequestFilter.all,
    this.transferLoader,
    this.roleLoader,
  });

  final TransferRequestsViewMode viewMode;
  final TransferRequestFilter initialFilter;
  final Future<List<TransferModel>> Function()? transferLoader;
  final Future<String?> Function()? roleLoader;

  @override
  State<TransferRequestsScreen> createState() => _TransferRequestsScreenState();
}

class _TransferRequestsScreenState extends State<TransferRequestsScreen> {
  late TransferRequestFilter _filter = widget.initialFilter;
  final _searchController = TextEditingController();
  String _query = '';
  late final LocalQueryController<List<TransferModel>> _controller;
  int _bootstrapRevision = -1;
  bool _isSupervisor = false;
  bool _roleLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(
      widget.transferLoader ?? EerlLocalRepository.instance.getTransfers,
    )..load();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role =
        await (widget.roleLoader?.call() ??
            EerlLocalRepository.instance.activeRole);
    if (!mounted) return;

    setState(() {
      _isSupervisor = role?.toUpperCase().contains('SUPERVISOR') == true;
      _roleLoaded = true;
    });
  }

  @override
  void didUpdateWidget(covariant TransferRequestsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilter != widget.initialFilter) {
      _filter = widget.initialFilter;
    }
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
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<TransferRequestItem> get _visibleItems {
    if (widget.viewMode == TransferRequestsViewMode.empty) return const [];
    final normalizedQuery = _query.trim().toLowerCase();
    return (_controller.data ?? const <TransferModel>[])
        .map(_toRequestItem)
        .where((item) {
          final matchesFilter = switch (_filter) {
            TransferRequestFilter.all => true,
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
                  item.id.toLowerCase().contains(normalizedQuery) ||
                  item.destination.toLowerCase().contains(normalizedQuery));
        })
        .toList(growable: false);
  }

  TransferRequestItem _toRequestItem(TransferModel transfer) {
    final requestedAt = DateTime.tryParse(transfer.requestedAt)?.toLocal();
    final quantity = transfer.fixedQty ?? transfer.totalQty;
    return TransferRequestItem(
      transferId: transfer.id,
      id: transfer.number ?? transfer.id,
      destination: transfer.destinationName ?? transfer.destinationId ?? '-',
      totalWeight: '${quantity.toStringAsFixed(2)} KG',
      date: requestedAt == null
          ? transfer.requestedAt
          : DateFormat('dd MMM yyyy').format(requestedAt),
      time: requestedAt == null
          ? ''
          : DateFormat('hh:mm a').format(requestedAt),
      status: _requestStatus(transfer.status),
    );
  }

  TransferRequestStatus _requestStatus(String value) {
    final status = value.toUpperCase();
    if (status.contains('REJECT')) return TransferRequestStatus.rejected;
    if (status.contains('DISPATCH') || status.contains('LOADING')) {
      return TransferRequestStatus.dispatch;
    }
    if (status.contains('APPROV') ||
        status.contains('COMPLET') ||
        status.contains('CLOSED') ||
        status.contains('HAND')) {
      return TransferRequestStatus.approved;
    }
    return TransferRequestStatus.pending;
  }

  @override
  Widget build(BuildContext context) {
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
        backIconAsset: 'assets/icons/records/back.svg',
      ),
      floatingActionButton: _roleLoaded && !_isSupervisor
          ? _TransferAddButton(
              onTap: () async {
                await context.push<void>(AppRoutes.createTransferRequest);
                if (mounted) await _controller.load();
              },
            )
          : null,
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
                Expanded(child: _buildTransferList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransferList() => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) {
      if (_controller.isLoading && !_controller.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_controller.error != null) {
        return Center(
          child: TextButton(
            onPressed: _controller.load,
            child: const Text('Retry'),
          ),
        );
      }
      final items = _visibleItems;
      if (items.isEmpty) {
        return RefreshIndicator(
          onRefresh: _controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 420,
                child: _EmptyTransferRequests(
                  label: context.l10n.transferEmptyMessage,
                ),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: _controller.load,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (_, index) => TransferRequestCard(
            key: ValueKey(items[index].transferId),
            item: items[index],
            highlighted: index == 0,
            onTap: () => _openRequest(items[index]),
          ),
        ),
      );
    },
  );

  Future<void> _openRequest(TransferRequestItem request) async {
    await context.push<void>(
      AppRoutes.transferRequestDetail,
      extra: request.transferId,
    );
    if (mounted) await _controller.load();
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
