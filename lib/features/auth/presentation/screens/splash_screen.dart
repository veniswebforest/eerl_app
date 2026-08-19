import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widget/loader_widget.dart';
import '../widgets/logo_component.dart';

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
        // Lottie animation completed
        print('Lottie completed');
        context.go(AppRoutes.login);
        // Your callback/action here
      }
    });
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
          debugPrint("lottie start ===>");
          _controller
            ..duration = composition.duration
            ..forward(); // Play once
        },
        // height: 100,
      ),
    );
  }
}
