import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import 'home_assets.dart';

/// Top app bar for the home screen.
/// Shows welcome text, date/zone, calendar, and notification icons.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreenHeader(
      title: context.l10n.welcomeBack,
      subtitle: context.l10n.homeDateZone,
      leading: Builder(
        builder: (context) => InkWell(
          key: const Key('home-menu-button'),
          onTap: () => Scaffold.of(context).openDrawer(),
          borderRadius: BorderRadius.circular(8),
          child: SvgPicture.asset(HomeAssets.menu, width: 28, height: 28),
        ),
      ),
      actions: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.cool50,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(HomeAssets.calendar, width: 24, height: 24),
          ),
        ),
        SvgPicture.asset(HomeAssets.notification, width: 45, height: 45),
      ],
    );
  }
}
