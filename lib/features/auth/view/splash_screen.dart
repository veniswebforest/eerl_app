import 'dart:async';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/providers/app_lock_provider.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/features/auth/presentation/auth_provider.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:eerl_app/shared/widgets/loader_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthAndNavigate();
      }
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    final isValidSession = await authProvider.checkSessionValidity();
    if (!mounted) return;

    if (isValidSession) {
      unawaited(
        BootstrapSyncService.instance.triggerBootstrap(
          trigger: BootstrapTrigger.appOpen,
        ),
      );
      final appLockProvider = context.read<AppLockProvider>();
      if (appLockProvider.isLockEnabled) {
        context.go(AppRoutes.appLock);
      } else {
        final role = await _storedDashboardRole();
        if (mounted) context.go(AppRoutes.home, extra: role);
      }
    } else {
      context.go(AppRoutes.login);
    }
  }

  Future<DashboardUserRole> _storedDashboardRole() async {
    final role = await AppDatabase.instance.getSyncMeta('active_role');
    return DashboardUserRoleX.fromKey(role);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    // final screenSize = context.screenSize;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Lottie.asset(
        controller: _controller,
        "${AppConstants.assetLottie}ic_splash.json",
        decoder: customDecoder,
        repeat: false,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.cover,

        onLoaded: (composition) {
          _controller
            ..duration = composition.duration
            ..forward(); // Play once
        },
        // height: 100,
      ),
    );
  }
}
