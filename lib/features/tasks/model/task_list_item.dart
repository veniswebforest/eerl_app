enum TaskListStatus { open, closed }

enum TaskPriority { high, normal, low }

class TaskListItem {
  const TaskListItem({
    required this.id,
    required this.status,
    required this.priority,
    required this.scheduleKey,
    required this.timeKey,
  });

  final String id;
  final TaskListStatus status;
  final TaskPriority priority;
  final String scheduleKey;
  final String timeKey;
}
