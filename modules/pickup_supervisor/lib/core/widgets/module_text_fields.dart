import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/forms/module_input_rules.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Input decoration with every border cleared, so the host app's
/// `inputDecorationTheme` cannot draw a second border inside our boxes.
const moduleBareInputDecoration = InputDecoration(
  isDense: true,
  filled: false,
  counterText: '',
  contentPadding: EdgeInsets.zero,
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  focusedErrorBorder: InputBorder.none,
);

BoxDecoration _boxDecoration({bool error = false}) => BoxDecoration(
  color: DriverColors.neutral50,
  borderRadius: BorderRadius.circular(10),
  border: Border.all(color: error ? DriverColors.red600 : DriverColors.cool400),
);

/// Red message under a field; [box] gets a red border from its caller.
class ModuleFieldError extends StatelessWidget {
  const ModuleFieldError({super.key, required this.child, this.errorText});

  final Widget child;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    if (errorText == null) return child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 6),
        Text(
          errorText!,
          style: DriverTextStyles.medium12.copyWith(color: DriverColors.red600),
        ),
      ],
    );
  }
}

/// 159px remarks box with "Max 150 Characters" in the bottom-right corner.
class ModuleRemarksField extends StatelessWidget {
  const ModuleRemarksField({
    super.key,
    required this.controller,
    this.fieldKey,
    this.maxChars = 150,
    this.counterLabel,
    this.errorText,
    this.focusNode,
  });

  final TextEditingController controller;
  final Key? fieldKey;
  final int maxChars;
  final String? errorText;
  final FocusNode? focusNode;

  /// Replaces the default "Max 150 Characters".
  final String? counterLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return ModuleFieldError(
      errorText: errorText,
      child: Container(
        height: 159,
        padding: const EdgeInsets.all(16),
        decoration: _boxDecoration(error: errorText != null),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                key: fieldKey,
                controller: controller,
                focusNode: focusNode,
                maxLength: maxChars,
                maxLines: null,
                expands: true,
                // Multiline: Enter adds a line; the keyboard closes on tap out.
                keyboardType: ModuleInputRules.keyboard(
                  ModuleInputKind.multiline,
                ),
                textInputAction: TextInputAction.newline,
                textCapitalization: ModuleInputRules.capitalization(
                  ModuleInputKind.multiline,
                ),
                textAlignVertical: TextAlignVertical.top,
                style: DriverTextStyles.regular14.copyWith(
                  color: DriverColors.neutral950,
                  height: 22 / 14,
                ),
                decoration: moduleBareInputDecoration,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                counterLabel ?? l10n.skMaxChars,
                style: DriverTextStyles.regular12.copyWith(
                  color: DriverColors.neutral400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 55px single-line box: a text field, or a tappable value with a trailing
/// icon when [onTap] is set (date pickers).
class ModuleInputBox extends StatelessWidget {
  const ModuleInputBox({
    super.key,
    this.controller,
    this.value,
    this.trailing,
    this.onTap,
    this.numeric = false,
    this.fieldKey,
    this.prefix,
    this.inputFormatters,
    this.kind,
    this.textInputAction,
    this.errorText,
    this.focusNode,
    this.onSubmitted,
    this.decimals = 3,
  });

  /// Keyboard, capitalisation and filter for the typed value. Overrides
  /// [numeric] (kept for older callers: a decimal number).
  final ModuleInputKind? kind;
  final int decimals;

  /// Next for a middle field, Done for the last one.
  final TextInputAction? textInputAction;
  final String? errorText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  /// Overrides the default digits-and-dot filter of [numeric].
  final List<TextInputFormatter>? inputFormatters;

  /// Shown before the value ("₹ ").
  final String? prefix;

  final TextEditingController? controller;

  /// Shown instead of a text field when there is no [controller].
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool numeric;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    final style = DriverTextStyles.regular14.copyWith(
      color: DriverColors.neutral950,
      height: 22 / 14,
    );
    final inputKind =
        kind ?? (numeric ? ModuleInputKind.decimal : ModuleInputKind.text);
    final content = Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: _boxDecoration(error: errorText != null),
      child: Row(
        children: [
          if (prefix != null) Text(prefix!, style: style),
          Expanded(
            child: controller != null
                ? TextField(
                    key: fieldKey,
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: ModuleInputRules.keyboard(inputKind),
                    textCapitalization: ModuleInputRules.capitalization(
                      inputKind,
                    ),
                    textInputAction: textInputAction,
                    onSubmitted: onSubmitted,
                    inputFormatters:
                        inputFormatters ??
                        ModuleInputRules.formatters(
                          inputKind,
                          decimals: decimals,
                        ),
                    style: style,
                    decoration: moduleBareInputDecoration,
                  )
                : Text(value ?? '', style: style),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
    if (onTap == null) {
      return ModuleFieldError(errorText: errorText, child: content);
    }
    // Picker fields (dates): tapping opens the picker, never a keyboard.
    return ModuleFieldError(
      errorText: errorText,
      child: GestureDetector(
        key: fieldKey,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      ),
    );
  }
}

/// Field label ("Reason *"): medium 14, with a red " *" when [required].
class ModuleFieldLabel extends StatelessWidget {
  const ModuleFieldLabel(this.text, {super.key, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: text,
      children: [
        if (required)
          const TextSpan(
            text: ' *',
            style: TextStyle(color: DriverColors.red600),
          ),
      ],
    ),
    style: DriverTextStyles.medium14.copyWith(color: DriverColors.neutral950),
  );
}

/// Two-line dropdown box: a grey caption over the value and a chevron.
class ModuleSelectBox extends StatelessWidget {
  const ModuleSelectBox({
    super.key,
    required this.caption,
    required this.value,
    required this.trailing,
    required this.onTap,
  });

  final String caption;
  final String value;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: DriverColors.neutral50,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: DriverColors.cool400),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caption,
                    style: DriverTextStyles.medium12.copyWith(
                      color: DriverColors.neutral400,
                    ),
                  ),
                  Text(
                    value,
                    style: DriverTextStyles.semibold14.copyWith(
                      color: DriverColors.neutral950,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    ),
  );
}

/// Multi-line text box with a 12px inset (Details and reason, cancel reason).
class ModuleTextArea extends StatelessWidget {
  const ModuleTextArea({
    super.key,
    required this.controller,
    this.fieldKey,
    this.minHeight = 72,
    this.maxLength = 300,
    this.errorText,
    this.focusNode,
  });

  final TextEditingController controller;
  final Key? fieldKey;
  final double minHeight;
  final int maxLength;
  final String? errorText;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => ModuleFieldError(
    errorText: errorText,
    child: Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(12),
      decoration: _boxDecoration(error: errorText != null),
      child: TextField(
        key: fieldKey,
        controller: controller,
        focusNode: focusNode,
        maxLength: maxLength,
        minLines: 2,
        maxLines: 4,
        keyboardType: ModuleInputRules.keyboard(ModuleInputKind.multiline),
        textInputAction: TextInputAction.newline,
        textCapitalization: ModuleInputRules.capitalization(
          ModuleInputKind.multiline,
        ),
        style: DriverTextStyles.regular14.copyWith(
          color: DriverColors.neutral950,
          height: 22 / 14,
        ),
        decoration: moduleBareInputDecoration,
      ),
    ),
  );
}
