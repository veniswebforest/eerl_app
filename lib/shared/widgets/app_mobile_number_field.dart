import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

/// App-wide Indian mobile-number control with a fixed country-code box.
class AppMobileNumberField extends StatefulWidget {
  const AppMobileNumberField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.onChanged,
    this.hasError = false,
    this.countryCode = '+91',
    this.onCountryCodeTap,
    this.countryCodeKey,
    this.phoneFieldKey,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final String countryCode;
  final VoidCallback? onCountryCodeTap;
  final Key? countryCodeKey;
  final Key? phoneFieldKey;

  @override
  State<AppMobileNumberField> createState() => _AppMobileNumberFieldState();
}

class _AppMobileNumberFieldState extends State<AppMobileNumberField> {
  FocusNode? _ownedFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant AppMobileNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode == widget.focusNode) return;
    (oldWidget.focusNode ?? _ownedFocusNode)?.removeListener(
      _handleFocusChange,
    );
    _ownedFocusNode?.dispose();
    _ownedFocusNode = null;
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color),
    borderRadius: BorderRadius.circular(10),
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final idleColor = widget.hasError ? palette.error : palette.cool400;
    final activeColor = widget.hasError ? palette.error : palette.primary500;
    final countryBorderColor = _focusNode.hasFocus ? activeColor : idleColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.onCountryCodeTap,
          child: AnimatedContainer(
            key: widget.countryCodeKey,
            duration: const Duration(milliseconds: 180),
            width: 72,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.neutral50,
              border: Border.all(color: countryBorderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.countryCode,
              style: AppTextStyles.mediumSH7_16.copyWith(
                color: palette.neutral950,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: TextField(
              key: widget.phoneFieldKey,
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              maxLength: 10,
              onChanged: widget.onChanged,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: AppTextStyles.regularB7_14.copyWith(
                color: palette.neutral950,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.regularB7_14.copyWith(
                  color: palette.cool500,
                ),
                counterText: '',
                filled: true,
                fillColor: palette.neutral50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: _border(idleColor),
                enabledBorder: _border(idleColor),
                focusedBorder: _border(activeColor),
                errorBorder: _border(palette.error),
                focusedErrorBorder: _border(palette.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
