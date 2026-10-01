import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class D2dVehicleDetailsCard extends StatelessWidget {
  const D2dVehicleDetailsCard({
    super.key,
    required this.centerLabel,
    required this.centerValue,
    required this.numberLabel,
    required this.number,
  });

  final String centerLabel;
  final String centerValue;
  final String numberLabel;
  final String number;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cool50,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: centerLabel, value: centerValue),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.cool400),
        const SizedBox(height: 12),
        _DetailRow(label: numberLabel, value: number),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.semiboldH9_14.copyWith(
          color: AppColors.neutral600,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        '  •  $value',
        style: AppTextStyles.semiboldH9_14.copyWith(
          color: AppColors.neutral950,
        ),
      ),
    ],
  );
}
