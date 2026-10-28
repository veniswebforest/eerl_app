import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_dimensions.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class EmptyNotificationsView extends StatelessWidget {
  const EmptyNotificationsView({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Transform.translate(
      offset: Offset(
        0,
        -(MediaQuery.paddingOf(context).top + AppScreenHeaderMetrics.height) /
            2,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          key: const Key('notification-empty-content'),
          constraints: const BoxConstraints(maxWidth: 335),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(child: _EmptyNotificationIllustration()),
              const SizedBox(height: 32),
              Text(
                title,
                key: const Key('notification-empty-title'),
                textAlign: TextAlign.center,
                style: AppTextStyles.boldH5_24.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                key: const Key('notification-empty-message'),
                textAlign: TextAlign.center,
                style: AppTextStyles.mediumSH8_14.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _EmptyNotificationIllustration extends StatelessWidget {
  const _EmptyNotificationIllustration();

  static const _background = 'assets/images/notification_empty_background.svg';
  static const _device = 'assets/images/notification_empty_device.svg';
  static const _bubble = 'assets/images/notification_empty_bubble.svg';

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const Key('notification-empty-illustration'),
    width: 181.061,
    height: 217.466,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(left: 3.2, top: 0, child: SvgPicture.asset(_background)),
        Positioned(left: 31.05, top: 30.67, child: SvgPicture.asset(_device)),
        Positioned(left: 0, top: 73.79, child: SvgPicture.asset(_bubble)),
      ],
    ),
  );
}
