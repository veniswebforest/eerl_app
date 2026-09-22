class AuthApiException implements Exception {
  const AuthApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.field,
  });

  final String message;
  final String? code;
  final int? statusCode;
  final String? field;

  @override
  String toString() => 'AuthApiException(code: $code, statusCode: $statusCode)';
}
