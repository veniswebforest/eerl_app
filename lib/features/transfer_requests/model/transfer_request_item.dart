enum TransferRequestFilter { all, pending, dispatch, closed }

enum TransferRequestStatus { pending, approved, dispatch, rejected }

enum TransferRequestsViewMode { populated, empty }

class TransferRequestItem {
  const TransferRequestItem({
    required this.transferId,
    required this.id,
    required this.destination,
    required this.totalWeight,
    required this.date,
    required this.time,
    required this.status,
  });

  final String transferId;
  final String id;
  final String destination;
  final String totalWeight;
  final String date;
  final String time;
  final TransferRequestStatus status;
}
