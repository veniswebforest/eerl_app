import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/local_database/app_database.dart';
import '../../../core/providers/app_lock_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/app_lock_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../dashboard/model/bottom_nav_item_model.dart';
import '../widgets/logo_component.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({
    super.key,
    this.lockService,
    this.autoPrompt = true,
    this.onAuthSuccess,
    this.onAuthFailed,
  });

  final AppLockService? lockService;
  final bool autoPrompt;
  final VoidCallback? onAuthSuccess;
  final VoidCallback? onAuthFailed;

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  late final AppLockService _lockService;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppLockProvider?>();
    _lockService =
        widget.lockService ?? provider?.lockService ?? AppLockService();

    if (widget.autoPrompt) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerAuthentication();
      });
    }
  }

  Future<void> _triggerAuthentication() async {
    if (_isAuthenticating || !mounted) return;

    setState(() {
      _isAuthenticating = true;
    });

    final success = await _lockService.authenticate(
      localizedReason: 'Please unlock to access EERL App',
    );

    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
    });

    if (success) {
      if (widget.onAuthSuccess != null) {
        widget.onAuthSuccess!();
      } else {
        final storedRole = await AppDatabase.instance.getSyncMeta(
          'active_role',
        );
        if (!mounted) return;
        final role = storedRole == 'SUPERVISOR'
            ? DashboardUserRole.supervisor
            : storedRole == 'ADMIN'
            ? DashboardUserRole.admin
            : storedRole == 'COLLECTION_MANAGER'
            ? DashboardUserRole.collectionManager
            : storedRole == 'IEC_AGENT'
            ? DashboardUserRole.iecAgent
            : DashboardUserRole.collectionAgent;
        context.go(AppRoutes.home, extra: role);
      }
    } else {
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
                      onPressed: _isAuthenticating
                          ? null
                          : _triggerAuthentication,
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
