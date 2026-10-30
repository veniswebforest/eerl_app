import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_assets.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_card.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_header.dart';
import 'package:eerl_app/features/tasks/model/task_list_item.dart';
import 'package:eerl_app/features/tasks/widgets/task_segmented_control.dart';
import 'package:eerl_app/shared/widgets/app_top_notification.dart';
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
  String _query = '';
  bool _loading = true;
  List<TaskModel> _allTasks = const [];

  List<TaskModel> get _visibleTasks {
    if (widget.showEmptyState) return const [];
    return _allTasks
        .where((task) {
          final isOpen = task.status.toUpperCase() == 'PENDING';
          return _selectedStatus == TaskListStatus.open ? isOpen : !isOpen;
        })
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
    if (widget.showCancelledBanner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showCancelledNotification();
      });
    }
  }

  void _showCancelledNotification() => AppTopNotification.show(
    context,
    key: const Key('supervisor-task-cancelled-banner'),
    title: context.l10n.supervisorTaskCancelled,
    subtitle: context.l10n.supervisorTaskCancelledSuccess,
    tone: AppTopNotificationTone.error,
  );

  Future<void> _loadTasks() async {
    final tasks = await EerlLocalRepository.instance.getTasks(
      supervisor: true,
      search: _query,
    );
    if (!mounted) return;
    setState(() {
      _allTasks = tasks;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _visibleTasks;
    final openCount = widget.showEmptyState
        ? 0
        : _allTasks
              .where((task) => task.status.toUpperCase() == 'PENDING')
              .length;
    final closedCount = widget.showEmptyState
        ? 0
        : _allTasks
              .where((task) => task.status.toUpperCase() != 'PENDING')
              .length;

    return Scaffold(
      key: const Key('supervisor-tasks-screen'),
      backgroundColor: Colors.white,
      appBar: SupervisorTaskHeader(title: context.l10n.supervisorTaskTitle),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 55,
                              child: TextField(
                                key: const Key('supervisor-task-search'),
                                onChanged: (value) {
                                  _query = value;
                                  _loadTasks();
                                },
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
                            ),                            const SizedBox(height: 8),

                            TaskSegmentedControl(
                              status: _selectedStatus,
                              openLabel: context.l10n.taskOpenCount(openCount),
                              closedLabel: context.l10n.taskClosedCount(
                                closedCount,
                              ),
                              onChanged: (status) =>
                                  setState(() => _selectedStatus = status),
                            ),

                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Expanded(
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : tasks.isEmpty
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
                                      showClosedTimestamp:
                                          _selectedStatus ==
                                          TaskListStatus.closed,
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
                            onPressed: () async {
                              await context.push<void>(
                                AppRoutes.assignSupervisorTask,
                              );
                              await _loadTasks();
                            },
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
          ],
        ),
      ),
    );
  }

  Future<void> _openTask(TaskModel task) async {
    final cancelled = await context.push<bool>(
      AppRoutes.supervisorTaskDetail,
      extra: task,
    );
    if (!mounted || cancelled != true) return;
    setState(() {
      _selectedStatus = TaskListStatus.closed;
    });
    _showCancelledNotification();
    await _loadTasks();
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
