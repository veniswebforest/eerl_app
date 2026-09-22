class VerifyOtpRequest {
  const VerifyOtpRequest({required this.phone, required this.otp});

  final String phone;
  final String otp;

  Map<String, dynamic> toJson() => {'phone': phone, 'otp': otp};

  Map<String, dynamic> toSafeLogJson() => {
    'phone': _maskPhone(phone),
    'otp': '[REDACTED]',
  };

  static String _maskPhone(String value) {
    if (value.length < 4) return '****';
    return '${'*' * (value.length - 4)}${value.substring(value.length - 4)}';
  }
}
