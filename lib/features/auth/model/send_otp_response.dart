class SendOtpResponse {
  const SendOtpResponse({
    required this.message,
    required this.supervisorName,
    required this.supervisorPhone,
    required this.expiresInSeconds,
  });

  final String? message;
  final String? supervisorName;
  final String? supervisorPhone;
  final int? expiresInSeconds;

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    final rawExpiry = json['expiresInSeconds'];
    return SendOtpResponse(
      message: json['message'] as String?,
      supervisorName: json['supervisorName'] as String?,
      supervisorPhone: json['supervisorPhone'] as String?,
      expiresInSeconds: rawExpiry is int
          ? rawExpiry
          : int.tryParse(rawExpiry?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toSafeLogJson() => {
    'message': message == null ? null : '[REDACTED]',
    'supervisorName': supervisorName == null ? null : '[REDACTED]',
    'supervisorPhone': supervisorPhone == null
        ? null
        : _maskPhone(supervisorPhone!),
    'expiresInSeconds': expiresInSeconds,
  };

  static String _maskPhone(String value) {
    if (value.length < 4) return '****';
    return '${'*' * (value.length - 4)}${value.substring(value.length - 4)}';
  }
}
