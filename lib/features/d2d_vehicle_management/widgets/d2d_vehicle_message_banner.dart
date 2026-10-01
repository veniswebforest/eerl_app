import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';

class D2dVehicleMessageBanner extends StatelessWidget {
  const D2dVehicleMessageBanner({
    super.key,
    required this.deactivated,
    required this.onClose,
  });

  final bool deactivated;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => AppMessageBanner(
    key: ValueKey(
      deactivated
          ? 'd2d-vehicle-deactivated-banner'
          : 'd2d-vehicle-saved-banner',
    ),
    padding: const EdgeInsets.all(12),
    title: deactivated
        ? context.l10n.d2dVehicleDeactivatedSuccess
        : context.l10n.d2dVehicleSaved,
    subtitle: deactivated
        ? context.l10n.d2dVehicleDeactivatedSubtitle
        : context.l10n.d2dVehicleSavedSubtitle,
    color: deactivated ? AppColors.red500 : AppColors.primary500,
    backgroundColor: deactivated ? AppColors.red50 : AppColors.primary50,
    borderColor: AppColors.cool400,
    autoDismiss: false,
    subtitleStyle: AppTextStyles.regularB7_14.copyWith(
      color: AppColors.neutral500,
    ),
    iconBackgroundColor: deactivated ? AppColors.red500 : AppColors.primary500,
    iconPadding: const EdgeInsets.all(5),
    icon: deactivated
        ? SvgPicture.asset(
            'assets/icons/ragpicker_deactivated.svg',
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          )
        : const Icon(Icons.check, size: 18, color: Colors.white),
    onClose: onClose,
  );
}
