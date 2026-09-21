enum RagpickerStatus { active, deactivated }

class RagpickerDirectoryItem {
  const RagpickerDirectoryItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    this.registrationId = '#RAG-2026-089',
    this.identityNumber = '8478 8456 63245',
    this.createdAt = '1 May 2026 • 08:15 AM',
  });

  final String id;
  final String name;
  final String phone;
  final RagpickerStatus status;
  final String registrationId;
  final String identityNumber;
  final String createdAt;

  RagpickerDirectoryItem copyWith({
    String? name,
    String? phone,
    RagpickerStatus? status,
    String? registrationId,
    String? identityNumber,
    String? createdAt,
  }) => RagpickerDirectoryItem(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    status: status ?? this.status,
    registrationId: registrationId ?? this.registrationId,
    identityNumber: identityNumber ?? this.identityNumber,
    createdAt: createdAt ?? this.createdAt,
  );
}
