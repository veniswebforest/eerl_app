enum RecentCollectionStatus { pending, verified, rejected }

class RecentCollectionItemModel {
  const RecentCollectionItemModel({
    required this.title,
    required this.receiptNumber,
    required this.weight,
    required this.statusLabel,
    required this.status,
  });

  final String title;
  final String receiptNumber;
  final String weight;
  final String statusLabel;
  final RecentCollectionStatus status;
}
