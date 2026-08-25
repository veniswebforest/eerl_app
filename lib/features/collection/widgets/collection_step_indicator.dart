import 'package:flutter/material.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class CollectionStepIndicator extends StatelessWidget {
  const CollectionStepIndicator({super.key, required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(5, (index) {
      if (index.isOdd) {
        final active = currentStep > (index ~/ 2) + 1;
        return Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: active ? AppColors.primary500 : AppColors.cool400,
          ),
        );
      }
      final step = index ~/ 2 + 1;
      final active = currentStep >= step;
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active && currentStep > step
              ? AppColors.primary50
              : AppColors.neutral50,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? AppColors.primary500 : AppColors.cool400,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '$step',
          style: AppTextStyles.semiboldH7_18.copyWith(
            color: active ? AppColors.primary500 : AppColors.neutral300,
          ),
        ),
      );
    }),
  );
}
