import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/request_list_item.dart';
import '../widgets/request_list_card.dart';
import '../widgets/request_segmented_control.dart';

enum RequestsViewMode { populated, empty }

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({
    super.key,
    required this.onBack,
    this.onRaiseRequest,
    this.onRequestTap,
    this.viewMode = RequestsViewMode.populated,
  });

  final VoidCallback onBack;
  final VoidCallback? onRaiseRequest;
  final ValueChanged<RequestListItem>? onRequestTap;
  final RequestsViewMode viewMode;

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  RequestListStatus _status = RequestListStatus.open;
  String _query = '';

  static const _items = [
    RequestListItem(
      id: 'request-1',
      status: RequestListStatus.open,
      descriptionKey: 'open1',
      time: '08:00 AM',
    ),
    RequestListItem(
      id: 'request-2',
      status: RequestListStatus.open,
      descriptionKey: 'open2',
      time: '09:00 AM',
    ),
    RequestListItem(
      id: 'request-3',
      status: RequestListStatus.open,
      descriptionKey: 'open3',
      time: '10:00 AM',
    ),
    RequestListItem(
      id: 'request-4',
      status: RequestListStatus.closed,
      descriptionKey: 'closed1',
      time: '08:00 AM',
    ),
    RequestListItem(
      id: 'request-5',
      status: RequestListStatus.closed,
      descriptionKey: 'closed2',
      time: '09:00 AM',
    ),
  ];

  List<RequestListItem> get _visibleItems {
    if (widget.viewMode == RequestsViewMode.empty) return const [];
    final query = _query.trim().toLowerCase();
    return _items
        .where((item) {
          if (item.status != _status) return false;
          return query.isEmpty ||
              _description(item).toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  String _description(RequestListItem item) => switch (item.descriptionKey) {
    'open1' => context.l10n.requestOpenDescriptionOne,
    'open2' => context.l10n.requestOpenDescriptionTwo,
    'open3' => context.l10n.requestOpenDescriptionThree,
    'closed1' => context.l10n.requestClosedDescriptionOne,
    _ => context.l10n.requestClosedDescriptionTwo,
  };

  @override
  Widget build(BuildContext context) {
    final openCount = widget.viewMode == RequestsViewMode.empty ? 0 : 3;
    final closedCount = widget.viewMode == RequestsViewMode.empty ? 0 : 2;
    final items = _visibleItems;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: context.l10n.requestTitle,
        onBackTap: widget.onBack,
        backIconAsset: 'assets/icons/records/back.svg',
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
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
                          onChanged: (value) => setState(() => _query = value),
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
                            contentPadding: EdgeInsets.zero,
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
                  child: items.isEmpty
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
                            description: _description(items[index]),
                            onTap: () =>
                                widget.onRequestTap?.call(items[index]),
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
                      onPressed: widget.onRaiseRequest ?? () {},
                      child: Text(context.l10n.requestRaiseButton),
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
