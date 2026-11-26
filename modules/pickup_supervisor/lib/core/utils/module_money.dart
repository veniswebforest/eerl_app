/// Indian rupee amounts for the static UI: 4850 → "₹4,850",
/// 125000 → "₹1,25,000". A [sign] is put before the ₹ ("+₹5,000").
String moduleRupees(int amount, {String sign = ''}) {
  final digits = amount.abs().toString();
  String grouped;
  if (digits.length <= 3) {
    grouped = digits;
  } else {
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    grouped = '${parts.join(',')},$last3';
  }
  return '$sign₹$grouped';
}
