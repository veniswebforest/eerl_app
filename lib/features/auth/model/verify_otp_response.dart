class VerifyOtpResponse {
  const VerifyOtpResponse({
    required this.accessToken,
    required this.sessionExpiresAt,
    this.roles = const <String>[],
  });

  final String? accessToken;
  final DateTime? sessionExpiresAt;
  final List<String> roles;

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final rawToken = json['accessToken'];
    final rawExpiry = json['sessionExpiresAt'];
    final rawUser = json['user'];
    final user = rawUser is Map<String, dynamic> ? rawUser : null;
    return VerifyOtpResponse(
      accessToken: rawToken is String ? rawToken : null,
      sessionExpiresAt: rawExpiry is String
          ? DateTime.tryParse(rawExpiry)
          : null,
      roles: _parseRoleKeys(
        json['roles'] ?? json['role'] ?? user?['roles'] ?? user?['role'],
      ),
    );
  }

  bool get hasValidSession =>
      accessToken != null &&
      accessToken!.isNotEmpty &&
      sessionExpiresAt != null;

  Map<String, dynamic> toSafeLogJson() => {
    'accessToken': _maskToken(accessToken),
    'sessionExpiresAt': sessionExpiresAt?.toIso8601String(),
    'roles': roles,
  };

  bool get isDriver =>
      roles.any((role) => role.trim().toUpperCase() == 'DRIVER');

  static List<String> _parseRoleKeys(Object? value) {
    final values = value is List<Object?> ? value : <Object?>[value];
    return values
        .map((role) {
          if (role is String) return role;
          if (role is Map<String, dynamic>) {
            final key = role['key'] ?? role['roleKey'] ?? role['name'];
            return key is String ? key : null;
          }
          return null;
        })
        .whereType<String>()
        .map((role) => role.trim().toUpperCase())
        .where((role) => role.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  static String? _maskToken(String? token) {
    if (token == null) return null;
    if (token.length <= 10) return '[REDACTED]';
    return '${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }
}
