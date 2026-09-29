import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:eerl_app/features/supervisor_requests/model/supervisor_agent_request.dart';
import 'package:eerl_app/features/supervisor_requests/widgets/supervisor_agent_request_card.dart';
import 'package:eerl_app/features/supervisor_requests/widgets/supervisor_request_assets.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SupervisorAgentRequestsScreen extends StatefulWidget {
  const SupervisorAgentRequestsScreen({
    super.key,
    this.initialStatus = SupervisorAgentRequestStatus.pending,
    this.viewMode = SupervisorAgentRequestsViewMode.populated,
  });

  final SupervisorAgentRequestStatus initialStatus;
  final SupervisorAgentRequestsViewMode viewMode;

  @override
  State<SupervisorAgentRequestsScreen> createState() =>
      _SupervisorAgentRequestsScreenState();
}

class _SupervisorAgentRequestsScreenState
    extends State<SupervisorAgentRequestsScreen> {
  late SupervisorAgentRequestStatus _status = widget.initialStatus;
  String _query = '';

  static const _pendingItems = [
    SupervisorAgentRequest(
      id: 'open-1',
      status: SupervisorAgentRequestStatus.pending,
    ),
    SupervisorAgentRequest(
      id: 'open-2',
      status: SupervisorAgentRequestStatus.pending,
    ),
    SupervisorAgentRequest(
      id: 'open-3',
      status: SupervisorAgentRequestStatus.pending,
    ),
  ];

  static const _resolvedItems = [
    SupervisorAgentRequest(
      id: 'closed-1',
      status: SupervisorAgentRequestStatus.resolved,
    ),
    SupervisorAgentRequest(
      id: 'closed-2',
      status: SupervisorAgentRequestStatus.resolved,
    ),
    SupervisorAgentRequest(
      id: 'closed-3',
      status: SupervisorAgentRequestStatus.resolved,
    ),
  ];

  List<SupervisorAgentRequest> get _items {
    if (widget.viewMode == SupervisorAgentRequestsViewMode.empty ||
        _query.trim().isNotEmpty) {
      return const [];
    }
    return _status == SupervisorAgentRequestStatus.pending
        ? _pendingItems
        : _resolvedItems;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const Key('supervisor-agent-requests-screen'),
    backgroundColor: Colors.white,
    appBar: SupervisorTaskHeader(
      title: context.l10n.supervisorAgentRequestsTitle,
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  children: [
                    _RequestTabs(
                      status: _status,
                      openLabel: context.l10n.requestOpenCount(
                        widget.viewMode == SupervisorAgentRequestsViewMode.empty
                            ? 0
                            : 3,
                      ),
                      closedLabel: context.l10n.requestClosedCount(
                        widget.viewMode == SupervisorAgentRequestsViewMode.empty
                            ? 0
                            : 3,
                      ),
                      onChanged: (value) => setState(() => _status = value),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 55,
                      child: TextField(
                        key: const Key('supervisor-agent-request-search'),
                        onChanged: (value) => setState(() => _query = value),
                        style: AppTextStyles.regularB7_14,
                        decoration: InputDecoration(
                          hintText: context.l10n.requestSearchHint,
                          hintStyle: AppTextStyles.regularB7_14.copyWith(
                            color: AppColors.neutral500,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(15),
                            child: SvgPicture.asset(
                              SupervisorRequestAssets.search,
                              width: 24,
                              height: 24,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.cool400,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _items.isEmpty
                    ? const _EmptyRequests()
                    : ListView.separated(
                        key: const Key('supervisor-agent-request-list'),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: _items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return SupervisorAgentRequestCard(
                            item: item,
                            onTap: () => _openRequest(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _openRequest(SupervisorAgentRequest request) async {
    if (request.status == SupervisorAgentRequestStatus.resolved) {
      await context.push<void>(AppRoutes.supervisorCompletedRequest);
      return;
    }

    final resolved = await context.push<bool>(
      AppRoutes.supervisorResolveRequest,
    );
    if (mounted && resolved == true) {
      setState(() => _status = SupervisorAgentRequestStatus.resolved);
    }
  }
}

class _RequestTabs extends StatelessWidget {
  const _RequestTabs({
    required this.status,
    required this.openLabel,
    required this.closedLabel,
    required this.onChanged,
  });

  final SupervisorAgentRequestStatus status;
  final String openLabel;
  final String closedLabel;
  final ValueChanged<SupervisorAgentRequestStatus> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [HomeStyles.cardShadow],
    ),
    child: Row(
      children: [
        Expanded(
          child: _Tab(
            key: const Key('supervisor-agent-requests-open-tab'),
            label: openLabel,
            selected: status == SupervisorAgentRequestStatus.pending,
            onTap: () => onChanged(SupervisorAgentRequestStatus.pending),
          ),
        ),
        Expanded(
          child: _Tab(
            key: const Key('supervisor-agent-requests-closed-tab'),
            label: closedLabel,
            selected: status == SupervisorAgentRequestStatus.resolved,
            onTap: () => onChanged(SupervisorAgentRequestStatus.resolved),
          ),
        ),
      ],
    ),
  );
}

class _Tab extends StatelessWidget {
  const _Tab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.primary500 : Colors.transparent,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.semiboldH9_14.copyWith(
            color: selected ? Colors.white : AppColors.neutral700,
          ),
        ),
      ),
    ),
  );
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          SupervisorRequestAssets.empty,
          width: 213,
          height: 236.348,
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.requestEmptyMessage,
          style: AppTextStyles.semiboldH8_16.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    ),
  );
}
