enum RequestListStatus { open, closed }

class RequestListItem {
  const RequestListItem({
    required this.id,
    required this.status,
    required this.descriptionKey,
    required this.time,
  });

  final String id;
  final RequestListStatus status;
  final String descriptionKey;
  final String time;
}
