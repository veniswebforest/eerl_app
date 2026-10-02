import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/request_list_item.dart';
import '../widgets/request_list_card.dart';
import '../widgets/request_segmented_control.dart';

enum RequestsViewMode { populated, empty }

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key, this.viewMode = RequestsViewMode.populated});
  final RequestsViewMode viewMode;
  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  RequestListStatus _status = RequestListStatus.open;
  String _query = '';
  late final LocalQueryController<List<RequestModel>> _controller;
  int _bootstrapRevision = -1;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(
      () => EerlLocalRepository.instance.getRequests(search: _query),
    )..load();
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

  bool _closed(RequestModel item) => const {
    'ANSWERED',
    'RESOLVED',
    'CLOSED',
  }.contains(item.status.toUpperCase());

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: context.l10n.requestTitle,
      backIconAsset: 'assets/icons/records/back.svg',
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final all = widget.viewMode == RequestsViewMode.empty
                  ? const <RequestModel>[]
                  : (_controller.data ?? const <RequestModel>[]);
              final openCount = all.where((item) => !_closed(item)).length;
              final closedCount = all.where(_closed).length;
              final items = all
                  .where(
                    (item) => _status == RequestListStatus.closed
                        ? _closed(item)
                        : !_closed(item),
                  )
                  .toList(growable: false);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      children: [
                        RequestSegmentedControl(
                          status: _status,
                          openLabel: context.l10n.requestOpenCount(openCount),
                          closedLabel: context.l10n.requestClosedCount(
                            closedCount,
                          ),
                          onChanged: (value) => setState(() => _status = value),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 52,
                          child: TextField(
                            key: const Key('request-search-field'),
                            onChanged: (value) {
                              _query = value;
                              _controller.load();
                            },
                            style: AppTextStyles.regularB7_14,
                            decoration: InputDecoration(
                              hintText: context.l10n.requestSearchHint,
                              hintStyle: AppTextStyles.regularB7_14.copyWith(
                                color: AppColors.neutral400,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(15),
                                child: SvgPicture.asset(
                                  'assets/icons/wallet/search.svg',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.cool400,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.primary500,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _controller.isLoading && !_controller.hasData
                        ? const Center(child: CircularProgressIndicator())
                        : _controller.error != null
                        ? Center(
                            child: TextButton(
                              onPressed: _controller.load,
                              child: const Text('Retry'),
                            ),
                          )
                        : items.isEmpty
                        ? _RequestEmptyState(
                            label: context.l10n.requestEmptyMessage,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) => RequestListCard(
                              key: ValueKey(items[index].id),
                              item: items[index],
                              onTap: () => context.push(
                                AppRoutes.requestDetail,
                                extra: items[index],
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        key: const Key('raise-request-button'),
                        onPressed: () => context.push(AppRoutes.raiseRequest),
                        child: Text(context.l10n.requestRaiseButton),
                      ),
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
}

class _RequestEmptyState extends StatelessWidget {
  const _RequestEmptyState({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/images/records_empty_drafts.svg',
          width: 120,
          height: 130,
        ),
        const SizedBox(height: 16),
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
