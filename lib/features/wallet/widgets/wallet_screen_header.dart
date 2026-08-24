import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import 'wallet_assets.dart';

class WalletScreenHeader extends StatelessWidget {
  const WalletScreenHeader({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppScreenHeader(
      title: title,
      leading: WalletBackButton(onPressed: onBack),
    );
  }
}

class WalletBackButton extends StatelessWidget {
  const WalletBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary500,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(WalletAssets.back, width: 20, height: 20),
        ),
      ),
    );
  }
}
