enum SupervisorTaskStatus { pending, resolved, cancelled }

class SupervisorTaskItem {
  const SupervisorTaskItem({
    required this.id,
    required this.status,
    required this.timeKey,
    this.hasAttachment = true,
  });

  final String id;
  final SupervisorTaskStatus status;
  final String timeKey;
  final bool hasAttachment;
}
