enum VerificationListStatus { pending, processed }

enum VerificationResult { pending, verified, rejected }

enum VerificationDetailStatus { pending, approved, rejected }

class VerificationEntry {
  const VerificationEntry({
    required this.person,
    required this.collectionType,
    required this.weightAndAmount,
    required this.collectionIdAndTime,
    required this.facility,
    required this.result,
    this.highlighted = false,
  });

  final String person;
  final String collectionType;
  final String weightAndAmount;
  final String collectionIdAndTime;
  final String facility;
  final VerificationResult result;
  final bool highlighted;
}
