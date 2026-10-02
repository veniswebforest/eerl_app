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
import '../model/task_list_item.dart';
import '../widgets/task_list_card.dart';
import '../widgets/task_segmented_control.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  TaskListStatus _status = TaskListStatus.open;
  String _query = '';
  late final LocalQueryController<List<TaskModel>> _controller;
  int _bootstrapRevision = -1;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(
      () => EerlLocalRepository.instance.getTasks(search: _query),
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

  bool _closed(TaskModel item) =>
      const {'COMPLETED', 'CLOSED'}.contains(item.status.toUpperCase());

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: context.l10n.myTasks,
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
              final all = _controller.data ?? const <TaskModel>[];
              final openCount = all.where((item) => !_closed(item)).length;
              final closedCount = all.where(_closed).length;
              final items = all
                  .where(
                    (item) => _status == TaskListStatus.closed
                        ? _closed(item)
                        : !_closed(item),
                  )
                  .toList(growable: false);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      children: [
                        TaskSegmentedControl(
                          status: _status,
                          openLabel: context.l10n.taskOpenCount(openCount),
                          closedLabel: context.l10n.taskClosedCount(
                            closedCount,
                          ),
                          onChanged: (status) =>
                              setState(() => _status = status),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 56,
                          child: TextField(
                            key: const Key('task-search-field'),
                            onChanged: (value) {
                              _query = value;
                              _controller.load();
                            },
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
                        ? _EmptyTasks(label: context.l10n.taskEmptyMessage)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) => TaskListCard(
                              key: ValueKey(items[index].id),
                              item: items[index],
                              onTap: () => context.push(
                                AppRoutes.taskDetail,
                                extra: items[index],
                              ),
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
