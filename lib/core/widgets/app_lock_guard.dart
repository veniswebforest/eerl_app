import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_lock_provider.dart';
import '../services/app_lock_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/widgets/logo_component.dart';

class AppLockGuard extends StatefulWidget {
  const AppLockGuard({
    super.key,
    required this.child,
    this.lockService,
    this.autoPrompt = true,
    this.onAuthFailed,
  });

  final Widget child;
  final AppLockService? lockService;
  final bool autoPrompt;
  final VoidCallback? onAuthFailed;

  @override
  State<AppLockGuard> createState() => _AppLockGuardState();
}

class _AppLockGuardState extends State<AppLockGuard>
    with WidgetsBindingObserver {
  late final AppLockService _lockService;
  bool _isUnlocked = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _lockService = widget.lockService ?? AppLockService();
    WidgetsBinding.instance.addObserver(this);

    if (widget.autoPrompt) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndAuthenticate();
      });
    } else {
      _isUnlocked = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkAndAuthenticate() async {
    final lockProvider = Provider.of<AppLockProvider?>(context, listen: false);
    if (lockProvider != null && !lockProvider.isLockEnabled) {
      if (mounted) {
        setState(() {
          _isUnlocked = true;
        });
      }
      return;
    }
    await _triggerAuthentication();
  }

  Future<void> _triggerAuthentication() async {
    if (_isAuthenticating || _isUnlocked) return;

    setState(() {
      _isAuthenticating = true;
    });

    final success = await _lockService.authenticate(
      localizedReason: 'Please unlock to access EERL App',
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isUnlocked = true;
        _isAuthenticating = false;
      });
    } else {
      setState(() {
        _isAuthenticating = false;
      });
      // Direct close app if authentication fails or is cancelled
      if (widget.onAuthFailed != null) {
        widget.onAuthFailed!();
      } else {
        AppLockService.closeApp();
      }
    }
  }

  void _handleExit() {
    if (widget.onAuthFailed != null) {
      widget.onAuthFailed!();
    } else {
      AppLockService.closeApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockProvider = Provider.of<AppLockProvider?>(context, listen: true);
    if (lockProvider != null && !lockProvider.isLockEnabled) {
      return widget.child;
    }

    if (_isUnlocked) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FittedBox(
                    child: LogoComponent(
                      size: LogoSize.medium,
                      showSubtitle: false,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary200),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 40,
                      color: AppColors.primary500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'App is Locked',
                    style: AppTextStyles.boldH5_24.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Authenticate with your device lock or biometrics to continue',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.regularB7_14.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      key: const Key('app-lock-unlock-button'),
                      onPressed:
                          _isAuthenticating ? null : _triggerAuthentication,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.primary500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isAuthenticating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Unlock App',
                              style: AppTextStyles.semiboldH8_16.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      key: const Key('app-lock-exit-button'),
                      onPressed: _handleExit,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.cool300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Exit',
                        style: AppTextStyles.semiboldH8_16.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
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
