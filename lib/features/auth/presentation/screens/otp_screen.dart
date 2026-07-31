import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/logo_component.dart';
import '../widgets/otp_input.dart';
import '../widgets/primary_button.dart';
import '../widgets/validation_message.dart';

/// OTP verification screen.
///
/// Features:
/// - Six-digit OTP input with auto-focus
/// - Countdown timer for resend
/// - Error state with red highlights
/// - Verify button with loading state
/// - Smooth animations
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  String _otp = '';
  bool _hasError = false;
  bool _isLoading = false;
  bool _isVerified = false;

  // Resend timer
  int _resendSeconds = 30;
  Timer? _resendTimer;

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  bool get _isOtpComplete => _otp.length == 6;

  String get _maskedPhone {
    if (widget.phoneNumber.length >= 10) {
      return '+91 ${widget.phoneNumber.substring(0, 2)}****${widget.phoneNumber.substring(8)}';
    }
    return '+91 ${widget.phoneNumber}';
  }

  void _onOtpCompleted(String otp) {
    setState(() {
      _otp = otp;
      _hasError = false;
    });
  }

  void _onOtpChanged(String otp) {
    setState(() {
      _otp = otp;
      if (_hasError) _hasError = false;
    });
  }

  void _onVerify() {
    if (!_isOtpComplete) return;

    setState(() => _isLoading = true);

    // Simulate verification
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      // Demo: "123456" is correct, anything else fails
      if (_otp == '123456') {
        setState(() {
          _isLoading = false;
          _isVerified = true;
        });

        // Navigate to home after success animation
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) context.go(AppRoutes.home);
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    });
  }

  void _onResend() {
    if (_resendSeconds > 0) return;
    _startResendTimer();
    setState(() => _hasError = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  // ── Scrollable Content ──────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),

                          // Logo
                          const LogoComponent(
                            size: LogoSize.small,
                            showSubtitle: false,
                          ),
                          const SizedBox(height: 36),

                          // Title
                          Text(
                            l10n.otpTitle,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Description
                          Text(
                            l10n.otpDescription(_maskedPhone),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // OTP Input
                          OtpInput(
                            hasError: _hasError,
                            onCompleted: _onOtpCompleted,
                            onChanged: _onOtpChanged,
                          ),

                          // Error Message
                          if (_hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ValidationMessage(
                                message: l10n.invalidOtp,
                              ),
                            ),

                          // Success Message
                          if (_isVerified)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ValidationMessage(
                                message: l10n.otpVerified,
                                type: ValidationType.success,
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Resend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.didntGetOtp,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: _onResend,
                                child: Text(
                                  _resendSeconds > 0
                                      ? '${l10n.resendOtp} (${_resendSeconds}s)'
                                      : l10n.resendOtp,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _resendSeconds > 0
                                        ? AppColors.disabled
                                        : AppColors.primaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Verify Button ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 12),
                    child: PrimaryButton(
                      label: l10n.verifyBtn,
                      isEnabled: _isOtpComplete && !_isLoading && !_isVerified,
                      isLoading: _isLoading,
                      onPressed: _onVerify,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
