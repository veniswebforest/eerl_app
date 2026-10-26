import 'package:flutter/material.dart';

import 'package:eerl_app/shared/widgets/app_mobile_number_field.dart';

/// Mobile number input with a separate fixed country-code box.
class MobileNumberInput extends StatelessWidget {
  const MobileNumberInput({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hasError = false,
    this.countryCode = '+91',
    this.hintText,
    this.onChanged,
    this.onCountryCodeTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final String countryCode;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCountryCodeTap;

  @override
  Widget build(BuildContext context) => AppMobileNumberField(
    controller: controller,
    focusNode: focusNode,
    hasError: hasError,
    countryCode: countryCode,
    onCountryCodeTap: onCountryCodeTap,
    hintText: hintText,
    onChanged: onChanged,
  );
}
