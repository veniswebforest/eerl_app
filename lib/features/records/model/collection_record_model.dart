enum CollectionRecordStatus { pending, verified, rejected }

class CollectionRecordModel {
  const CollectionRecordModel({
    required this.name,
    required this.receipt,
    required this.weight,
    required this.status,
  });

  final String name;
  final String receipt;
  final String weight;
  final CollectionRecordStatus status;
}

class CollectionDraftModel {
  const CollectionDraftModel({
    required this.name,
    required this.date,
    required this.weight,
    required this.itemCount,
  });

  final String name;
  final String date;
  final String weight;
  final String itemCount;
}
