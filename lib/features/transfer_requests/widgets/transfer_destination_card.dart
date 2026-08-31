import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/transfer_destination.dart';

class TransferDestinationCard extends StatelessWidget {
  const TransferDestinationCard({
    super.key,
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final TransferDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.neutral50,
    borderRadius: BorderRadius.circular(10),
    elevation: 2,
    shadowColor: const Color(0x16000000),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary500 : AppColors.cool100,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: AppTextStyles.semiboldH8_16.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/home/location.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary700,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          destination.address,
                          style: AppTextStyles.regularB7_14.copyWith(
                            color: AppColors.neutral950,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary500 : AppColors.neutral500,
                ),
              ),
              child: selected
                  ? const DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    ),
  );
}
