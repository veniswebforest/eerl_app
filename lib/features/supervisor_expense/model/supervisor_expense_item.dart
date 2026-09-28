enum SupervisorExpenseStatus { pending, approved, rejected }

class SupervisorExpenseItem {
  const SupervisorExpenseItem({
    required this.agentName,
    required this.role,
    required this.category,
    required this.date,
    required this.amount,
    required this.status,
  });

  final String agentName;
  final String role;
  final String category;
  final String date;
  final String amount;
  final SupervisorExpenseStatus status;
}
