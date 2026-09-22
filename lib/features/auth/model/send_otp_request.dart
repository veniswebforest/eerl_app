class SendOtpRequest {
  const SendOtpRequest({required this.phone});

  final String phone;

  Map<String, dynamic> toJson() => {'phone': phone};

  Map<String, dynamic> toSafeLogJson() => {'phone': _maskPhone(phone)};

  static String _maskPhone(String value) {
    if (value.length < 4) return '****';
    return '${'*' * (value.length - 4)}${value.substring(value.length - 4)}';
  }
}
