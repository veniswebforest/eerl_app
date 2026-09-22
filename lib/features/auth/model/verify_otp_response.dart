class VerifyOtpResponse {
  const VerifyOtpResponse({
    required this.accessToken,
    required this.sessionExpiresAt,
  });

  final String? accessToken;
  final DateTime? sessionExpiresAt;

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final rawToken = json['accessToken'];
    final rawExpiry = json['sessionExpiresAt'];
    return VerifyOtpResponse(
      accessToken: rawToken is String ? rawToken : null,
      sessionExpiresAt: rawExpiry is String
          ? DateTime.tryParse(rawExpiry)
          : null,
    );
  }

  bool get hasValidSession =>
      accessToken != null &&
      accessToken!.isNotEmpty &&
      sessionExpiresAt != null;

  Map<String, dynamic> toSafeLogJson() => {
    'accessToken': _maskToken(accessToken),
    'sessionExpiresAt': sessionExpiresAt?.toIso8601String(),
  };

  static String? _maskToken(String? token) {
    if (token == null) return null;
    if (token.length <= 10) return '[REDACTED]';
    return '${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }
}
