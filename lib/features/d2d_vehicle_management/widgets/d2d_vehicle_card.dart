import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/d2d_vehicle_item.dart';

class D2dVehicleCard extends StatelessWidget {
  const D2dVehicleCard({
    super.key,
    required this.item,
    required this.activeLabel,
    required this.deactivatedLabel,
    required this.onTap,
  });

  final D2dVehicleItem item;
  final String activeLabel;
  final String deactivatedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = item.status == D2dVehicleStatus.active;
    final color = active ? AppColors.primary500 : AppColors.red500;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('d2d-vehicle-${item.number}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 86),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.number,
                    style: AppTextStyles.semiboldH7_18.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      active
                          ? Icon(
                              Icons.check_circle_outline,
                              size: 18,
                              color: color,
                            )
                          : SvgPicture.asset(
                              'assets/icons/ragpicker_deactivated.svg',
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                color,
                                BlendMode.srcIn,
                              ),
                            ),
                      const SizedBox(width: 5),
                      Text(
                        active ? activeLabel : deactivatedLabel,
                        style: AppTextStyles.mediumSH9_12.copyWith(
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: SvgPicture.asset(
                  'assets/icons/ragpicker_open_details.svg',
                  width: 14,
                  height: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
