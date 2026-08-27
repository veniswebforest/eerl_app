enum TransferRequestFilter { all, pending, dispatch, closed }

enum TransferRequestStatus { pending, approved, dispatch, rejected }

enum TransferRequestsViewMode { populated, empty }

class TransferRequestItem {
  const TransferRequestItem({
    required this.id,
    required this.totalWeight,
    required this.date,
    required this.time,
    required this.status,
  });

  final String id;
  final String totalWeight;
  final String date;
  final String time;
  final TransferRequestStatus status;
}
