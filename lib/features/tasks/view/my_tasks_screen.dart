import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/task_list_item.dart';
import '../widgets/task_list_card.dart';
import '../widgets/task_segmented_control.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key, required this.onBack, this.onTaskTap});

  final VoidCallback onBack;
  final ValueChanged<TaskListItem>? onTaskTap;

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  TaskListStatus _status = TaskListStatus.open;
  String _query = '';

  static const _items = [
    TaskListItem(
      id: 'task-1',
      status: TaskListStatus.open,
      priority: TaskPriority.high,
      scheduleKey: 'today',
    ),
    TaskListItem(
      id: 'task-2',
      status: TaskListStatus.open,
      priority: TaskPriority.normal,
      scheduleKey: 'tomorrow',
    ),
    TaskListItem(
      id: 'task-3',
      status: TaskListStatus.open,
      priority: TaskPriority.low,
      scheduleKey: 'date',
    ),
    TaskListItem(
      id: 'task-4',
      status: TaskListStatus.closed,
      priority: TaskPriority.high,
      scheduleKey: 'completed',
    ),
    TaskListItem(
      id: 'task-5',
      status: TaskListStatus.closed,
      priority: TaskPriority.normal,
      scheduleKey: 'completed',
    ),
    TaskListItem(
      id: 'task-6',
      status: TaskListStatus.closed,
      priority: TaskPriority.low,
      scheduleKey: 'completed',
    ),
  ];

  List<TaskListItem> get _visibleItems {
    final items = _items.where((item) => item.status == _status);
    if (_query.trim().isEmpty) return items.toList(growable: false);
    final query = _query.trim().toLowerCase();
    return items
        .where(
          (_) =>
              context.l10n.taskSupervisorName.toLowerCase().contains(query) ||
              context.l10n.taskDescription.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: context.l10n.myTasks,
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    children: [
                      TaskSegmentedControl(
                        status: _status,
                        openLabel: context.l10n.taskOpenCount(3),
                        closedLabel: context.l10n.taskClosedCount(3),
                        onChanged: (status) => setState(() => _status = status),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 56,
                        child: TextField(
                          key: const Key('task-search-field'),
                          onChanged: (value) => setState(() => _query = value),
                          style: AppTextStyles.regularB7_14,
                          decoration: InputDecoration(
                            hintText: context.l10n.recordsSearchHint,
                            hintStyle: AppTextStyles.regularB7_14.copyWith(
                              color: AppColors.neutral400,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SvgPicture.asset(
                                'assets/icons/wallet/search.svg',
                                width: 24,
                                height: 24,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.cool600,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.cool400,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: AppColors.primary500,
                              ),
                              borderRadius: BorderRadius.circular(10),
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
                      ? _EmptyTasks(label: context.l10n.taskEmptyMessage)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) => TaskListCard(
                            key: ValueKey(items[index].id),
                            item: items[index],
                            onTap: () => widget.onTaskTap?.call(items[index]),
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

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/images/records_empty_drafts.svg',
          width: 174,
          height: 186,
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ],
    ),
  );
}
