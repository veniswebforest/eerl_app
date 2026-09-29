enum SupervisorAgentRequestStatus { pending, resolved }

enum SupervisorAgentRequestsViewMode { populated, empty }

enum SupervisorAgentRequestDetailView { resolve, completed }

class SupervisorAgentRequest {
  const SupervisorAgentRequest({required this.id, required this.status});

  final String id;
  final SupervisorAgentRequestStatus status;
}
