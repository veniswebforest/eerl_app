import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/logo_component.dart';
import '../widgets/mobile_input.dart';
import '../widgets/primary_button.dart';
import '../widgets/validation_message.dart';

/// Login screen with mobile number input.
///
/// Features:
/// - Logo header
/// - Welcome message (localized)
/// - Country code selector + mobile number input
/// - Real-time validation
/// - Continue button (enabled only when valid)
/// - Keyboard-aware layout
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

  bool _hasAttempted = false;
  bool _isLoading = false;

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

    _phoneFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool get _isValid => _phoneController.text.length == 10;

  bool get _hasError =>
      _hasAttempted && _phoneController.text.isNotEmpty && !_isValid;

  void _onContinue() {
    setState(() => _hasAttempted = true);

    if (!_isValid) return;

    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.push(
        '${AppRoutes.otp}?phone=${_phoneController.text}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),

                          // Logo
                          const Center(
                            child: LogoComponent(size: LogoSize.medium),
                          ),
                          const SizedBox(height: 40),

                          // Welcome Text
                          Text(
                            l10n.loginWelcome,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.loginSubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Label
                          Text(
                            l10n.mobileNumberLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Mobile Input
                          MobileNumberInput(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            hasError: _hasError,
                            hintText: l10n.mobileNumberHint,
                            onChanged: (_) => setState(() {}),
                          ),

                          // Validation
                          if (_hasError)
                            ValidationMessage(
                              message: l10n.invalidMobileNumber,
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom Button ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 12),
                    child: PrimaryButton(
                      label: l10n.continueBtn,
                      isEnabled: _isValid && !_isLoading,
                      isLoading: _isLoading,
                      onPressed: _onContinue,
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
