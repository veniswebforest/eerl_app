import 'package:eerl_app/features/auth/presentation/auth_provider.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/loader_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import '../widgets/mobile_input.dart';
import '../widgets/primary_button.dart';
import '../widgets/validation_message.dart';

/// Login screen using AuthProvider for state management.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const String _debugDummyPhone = '9876543210';
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

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

    _phoneFocusNode.addListener(() => setState(() {}));

    _phoneController.addListener(() {
      context.read<AuthProvider>().setPhoneNumber(_phoneController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final savedPhone = authProvider.phoneNumber;
      if (savedPhone.isNotEmpty) {
        _phoneController.text = savedPhone;
        return;
      }

      // Keep test autofill local to debug so release builds start empty.
      if (kDebugMode) {
        _phoneController.text = _debugDummyPhone;
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onContinue() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendOtp();
    if (success && mounted) {
      context.push('${AppRoutes.otp}?phone=${authProvider.phoneNumber}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = context.isDarkMode;
    final authProvider = context.watch<AuthProvider>();

    final isValid = authProvider.isPhoneValid;
    final hasError = authProvider.hasLoginError;
    final isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Stack(
        children: [
          SafeArea(
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
                          children: [
                            const SizedBox(height: 48),
                            Image.asset(
                              'assets/images/ic_logo.png',
                              width: 200,
                              height: 80,
                            ),
                            const SizedBox(height: 40),
                            Text(
                              l10n.loginWelcome,
                              style: AppTextStyles.boldH3_32.copyWith(
                                color: context.palette.primary900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.loginSubtitle,
                              style: AppTextStyles.regularB7_14.copyWith(
                                color: context.palette.neutral950,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Label
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                l10n.mobileNumberLabel,
                                style: AppTextStyles.mediumSH8_14.copyWith(
                                  color: context.palette.primary900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Mobile Input
                            MobileNumberInput(
                              controller: _phoneController,
                              focusNode: _phoneFocusNode,
                              hasError: hasError,
                              hintText: l10n.mobileNumberHint,
                              onChanged: (_) {},
                            ),

                            // Validation
                            if (hasError)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ValidationMessage(
                                  message: l10n.invalidMobileNumber,
                                  showIcon: false,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // ── Bottom Button ───────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24, top: 12),
                        child: PrimaryButton(
                          label: l10n.continueBtn,
                          isEnabled: isValid && !isLoading,
                          isLoading: isLoading,
                          onPressed: _onContinue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          LoadingWidget(isLoading: isLoading),
        ],
      ),
    );
  }
}
