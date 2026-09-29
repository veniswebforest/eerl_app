enum SupervisorCategoryRequestStatus { pending, resolved, rejected }

class SupervisorCategoryRequest {
  const SupervisorCategoryRequest({
    required this.agent,
    required this.facility,
    required this.category,
    required this.description,
    required this.date,
    required this.status,
  });

  final String agent;
  final String facility;
  final String category;
  final String description;
  final String date;
  final SupervisorCategoryRequestStatus status;
}
