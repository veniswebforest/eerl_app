import 'package:eerl_app/core/providers/auth_provider.dart';
import 'package:eerl_app/core/theme/app_palette.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/otp_input.dart';
import '../widgets/primary_button.dart';

/// OTP verification screen using AuthProvider for state management.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
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

    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideUp = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String get _maskedPhone {
    if (widget.phoneNumber.length >= 10) {
      return '+91 ${widget.phoneNumber.substring(0, 2)}****${widget.phoneNumber.substring(8)}';
    }
    return '+91 ${widget.phoneNumber}';
  }

  void _onOtpCompleted(String otp) {
    final authProvider = context.read<AuthProvider>();
    authProvider.setOtp(otp);
  }

  void _onOtpChanged(String otp) {
    final authProvider = context.read<AuthProvider>();
    authProvider.setOtp(otp);
  }

  void _onVerify() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp();
    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = context.isDarkMode;
    final authProvider = context.watch<AuthProvider>();

    final isOtpComplete = authProvider.isOtpComplete;
    final hasError = authProvider.hasOtpError;
    final isLoading = authProvider.isLoading;
    final isVerified = authProvider.isVerified;
    final resendSeconds = authProvider.resendSeconds;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const CustomAppBar(),
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
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),

                        Text(
                          l10n.otpTitle,
                          style: AppTextStyles.boldH5_24.copyWith(
                            color: context.palette.primary900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.otpDescription(_maskedPhone),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.regularB7_14.copyWith(
                            color: context.palette.neutral950,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // OTP Input
                        OtpInput(
                          hasError: hasError,
                          isVerified: isVerified,
                          onCompleted: _onOtpCompleted,
                          onChanged: _onOtpChanged,
                        ),

                        // Error Message
                        if (hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              'This Code has expired. Please Request New One.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.palette.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),

                  // ── Bottom Section ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PrimaryButton(
                          label: l10n.verifyBtn,
                          isEnabled:
                              isOtpComplete &&
                              !isLoading &&
                              !isVerified &&
                              !hasError,
                          isLoading: isLoading,
                          onPressed: _onVerify,
                        ),
                        const SizedBox(height: 16),
                        if (isVerified)
                          Text(
                            'Code Will Expire in 01:13',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.palette.primary,
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.didntGetOtp,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.neutral400
                                      : AppColors.neutral600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: authProvider.resendOtp,
                                child: Text(
                                  resendSeconds > 0
                                      ? '${l10n.resendOtp} (${resendSeconds}s)'
                                      : l10n.resendOtp,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: resendSeconds > 0
                                        ? AppColors.neutral300
                                        : context.palette.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
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
