import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Six-digit OTP input with auto-focus and auto-next behavior.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.onCompleted,
    this.hasError = false,
    this.isVerified = false,
    this.length = 6,
    this.onChanged,
    this.initialOtp,
  });

  final int length;
  final bool hasError;
  final bool isVerified;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final String? initialOtp;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    for (final node in _focusNodes) {
      node.addListener(() => setState(() {}));
    }

    final initialOtp = widget.initialOtp;
    if (_isValidOtp(initialOtp)) {
      _populateControllers(initialOtp!);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged?.call(initialOtp);
        widget.onCompleted(initialOtp);
      });
    }
  }

  @override
  void didUpdateWidget(covariant OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialOtp != oldWidget.initialOtp) {
      if (_isValidOtp(widget.initialOtp)) {
        _populateControllers(widget.initialOtp!);
      } else if (widget.initialOtp?.isEmpty == true) {
        for (final controller in _controllers) {
          controller.clear();
        }
        if (_focusNodes.every((node) => !node.hasFocus)) {
          _focusNodes.first.requestFocus();
        }
      }
    }
  }

  bool _isValidOtp(String? value) =>
      value != null &&
      value.length == widget.length &&
      RegExp(r'^\d+$').hasMatch(value);

  void _populateControllers(String otp) {
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = otp[i];
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final otp = _otp;
    widget.onChanged?.call(otp);

    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isComplete = _otp.length == widget.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = constraints.maxWidth < 340 ? 6.0 : 10.0;
        return Row(
          children: List.generate(widget.length, (index) {
            final isFocused = _focusNodes[index].hasFocus;

            final Color borderColor;
            if (widget.hasError) {
              borderColor = palette.error;
            } else if (widget.isVerified || isComplete) {
              borderColor = palette.success;
            } else if (isFocused) {
              borderColor = palette.primary;
            } else {
              borderColor = palette.border;
            }

            final Color textColor;
            if (widget.isVerified) {
              textColor = palette.success;
            } else if (widget.hasError) {
              textColor = palette.error;
            } else {
              textColor = palette.textPrimary;
            }

            return Expanded(
              child: Container(
                key: Key('otp-digit-container-$index'),
                height: 56,
                margin: EdgeInsets.only(
                  right: index < widget.length - 1 ? spacing : 0,
                ),
                child: Focus(
                  onKeyEvent: (_, event) {
                    _onKeyEvent(index, event);
                    return KeyEventResult.ignored;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor,
                        width:
                            (widget.isVerified || widget.hasError || isFocused)
                            ? 1.3
                            : 1,
                      ),
                      // color: palette.surface,
                    ),
                    child: TextField(
                      key: Key('otp-digit-$index'),
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      autofocus:
                          index == 0 && (widget.initialOtp?.isEmpty ?? true),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      textInputAction: index == widget.length - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                      autofillHints: index == 0
                          ? const [AutofillHints.oneTimeCode]
                          : null,
                      maxLength: 1,
                      onChanged: (value) => _onChanged(index, value),
                      onSubmitted: (_) {
                        if (index == widget.length - 1) {
                          _focusNodes[index].unfocus();
                        }
                      },
                      cursorColor: palette.primary,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      decoration: const InputDecoration(filled: false,
                        counterText: '',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
