import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_tasks/model/supervisor_task_item.dart';
import 'package:eerl_app/features/supervisor_tasks/model/supervisor_task_detail_status.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_assets.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_card.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_header.dart';
import 'package:eerl_app/features/tasks/model/task_list_item.dart';
import 'package:eerl_app/features/tasks/widgets/task_segmented_control.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SupervisorTasksScreen extends StatefulWidget {
  const SupervisorTasksScreen({
    super.key,
    this.showEmptyState = false,
    this.showCancelledBanner = false,
  });

  final bool showEmptyState;
  final bool showCancelledBanner;

  @override
  State<SupervisorTasksScreen> createState() => _SupervisorTasksScreenState();
}

class _SupervisorTasksScreenState extends State<SupervisorTasksScreen> {
  late TaskListStatus _selectedStatus = widget.showCancelledBanner
      ? TaskListStatus.closed
      : TaskListStatus.open;
  late bool _showCancelledBanner = widget.showCancelledBanner;
  String _query = '';

  static const _openTasks = [
    SupervisorTaskItem(
      id: 'open-1',
      status: SupervisorTaskStatus.pending,
      timeKey: 'today',
    ),
    SupervisorTaskItem(
      id: 'open-2',
      status: SupervisorTaskStatus.pending,
      timeKey: 'yesterday',
      hasAttachment: false,
    ),
    SupervisorTaskItem(
      id: 'open-3',
      status: SupervisorTaskStatus.pending,
      timeKey: 'october',
      hasAttachment: false,
    ),
  ];

  static const _closedTasks = [
    SupervisorTaskItem(
      id: 'closed-1',
      status: SupervisorTaskStatus.resolved,
      timeKey: 'today',
    ),
    SupervisorTaskItem(
      id: 'closed-2',
      status: SupervisorTaskStatus.resolved,
      timeKey: 'today',
    ),
    SupervisorTaskItem(
      id: 'closed-3',
      status: SupervisorTaskStatus.cancelled,
      timeKey: 'today',
    ),
  ];

  List<SupervisorTaskItem> get _visibleTasks {
    if (widget.showEmptyState || _query.trim().isNotEmpty) {
      return const [];
    }
    return _selectedStatus == TaskListStatus.open ? _openTasks : _closedTasks;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _visibleTasks;
    final openCount = widget.showEmptyState ? 0 : 2;
    final closedCount = widget.showEmptyState ? 0 : 4;

    return Scaffold(
      key: const Key('supervisor-tasks-screen'),
      backgroundColor: Colors.white,
      appBar: _showCancelledBanner
          ? null
          : SupervisorTaskHeader(title: context.l10n.supervisorTaskTitle),
      body: SafeArea(
        top: _showCancelledBanner,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: _showCancelledBanner ? 76 : 0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                        child: Column(
                          children: [
                            TaskSegmentedControl(
                              status: _selectedStatus,
                              openLabel: context.l10n.taskOpenCount(openCount),
                              closedLabel: context.l10n.taskClosedCount(
                                closedCount,
                              ),
                              onChanged: (status) =>
                                  setState(() => _selectedStatus = status),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              height: 55,
                              child: TextField(
                                key: const Key('supervisor-task-search'),
                                onChanged: (value) =>
                                    setState(() => _query = value),
                                style: AppTextStyles.regularB7_14,
                                decoration: InputDecoration(
                                  hintText: context.l10n.recordsSearchHint,
                                  hintStyle: AppTextStyles.regularB7_14
                                      .copyWith(color: AppColors.neutral500),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: SvgPicture.asset(
                                      SupervisorTaskAssets.search,
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
                      const SizedBox(height: 22),
                      Expanded(
                        child: tasks.isEmpty
                            ? const _SupervisorTasksEmptyState()
                            : ListView.separated(
                                key: const Key('supervisor-task-list'),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  16,
                                ),
                                itemCount: tasks.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) =>
                                    SupervisorTaskCard(
                                      item: tasks[index],
                                      onTap: () => _openTask(tasks[index]),
                                    ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            key: const Key('supervisor-assign-new-task'),
                            onPressed: () => context.push<void>(
                              AppRoutes.assignSupervisorTask,
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColors.primary500,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              context.l10n.supervisorAssignNewTask,
                              style: AppTextStyles.boldH7_16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_showCancelledBanner)
              Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AppMessageBanner(
                        key: const Key('supervisor-task-cancelled-banner'),
                        title: context.l10n.supervisorTaskCancelled,
                        subtitle: context.l10n.supervisorTaskCancelledSuccess,
                        color: AppColors.red500,
                        backgroundColor: AppColors.red50,
                        borderColor: AppColors.cool300,
                        borderRadius: 12,
                        padding: const EdgeInsets.all(16),
                        leadingGap: 12,
                        iconBackgroundColor: AppColors.red500,
                        iconPadding: const EdgeInsets.all(5),
                        icon: SvgPicture.asset(
                          SupervisorTaskAssets.cancelBanner,
                          width: 20,
                          height: 20,
                        ),
                        closeIcon: SvgPicture.asset(
                          SupervisorTaskAssets.close,
                          width: 20,
                          height: 20,
                        ),
                        onClose: () =>
                            setState(() => _showCancelledBanner = false),
                        subtitleStyle: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTask(SupervisorTaskItem task) async {
    final cancelled = await context.push<bool>(
      AppRoutes.supervisorTaskDetail,
      extra: switch (task.status) {
        SupervisorTaskStatus.pending => SupervisorTaskDetailStatus.inProgress,
        SupervisorTaskStatus.resolved => SupervisorTaskDetailStatus.completed,
        SupervisorTaskStatus.cancelled => SupervisorTaskDetailStatus.cancelled,
      },
    );
    if (!mounted || cancelled != true) return;
    setState(() {
      _selectedStatus = TaskListStatus.closed;
      _showCancelledBanner = true;
    });
  }
}

class _SupervisorTasksEmptyState extends StatelessWidget {
  const _SupervisorTasksEmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(SupervisorTaskAssets.empty, width: 213, height: 236),
        const SizedBox(height: 16),
        Text(
          context.l10n.taskEmptyMessage,
          style: AppTextStyles.semiboldH8_16.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    ),
  );
}
