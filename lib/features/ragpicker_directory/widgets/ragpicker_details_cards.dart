import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';

class RagpickerRegistrationCard extends StatelessWidget {
  const RagpickerRegistrationCard({super.key, required this.registrationId});

  final String registrationId;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(8),
    decoration: _cardDecoration(12),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SvgPicture.asset('assets/icons/ragpicker_profile.svg'),
        ),
        const SizedBox(width: 10),
        Text(
          registrationId,
          style: AppTextStyles.semiboldH8_16.copyWith(
            color: AppColors.neutral900,
          ),
        ),
      ],
    ),
  );
}

class RagpickerInformationCard extends StatelessWidget {
  const RagpickerInformationCard({
    super.key,
    required this.item,
    required this.fullNameLabel,
    required this.mobileLabel,
    required this.identityLabel,
    required this.dateLabel,
    this.zoneLabel,
    this.zoneValue,
  });

  final RagpickerModel item;
  final String fullNameLabel;
  final String mobileLabel;
  final String identityLabel;
  final String dateLabel;
  final String? zoneLabel;
  final String? zoneValue;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      (fullNameLabel, item.name),
      (mobileLabel, item.phone ?? '—'),
      (identityLabel, item.idNumber ?? '—'),
      if (zoneLabel != null && zoneValue != null) (zoneLabel!, zoneValue!),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(12),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rows[index].$1,
                    style: AppTextStyles.semiboldH9_14.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '  •  ${rows[index].$2}',
                    style: AppTextStyles.semiboldH9_14.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                ],
              ),
            ),
            if (index != rows.length - 1) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.cool400),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class RagpickerProofCard extends StatelessWidget {
  const RagpickerProofCard({super.key, required this.title, this.photoUrl});

  final String title;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.semiboldH7_18),
        const SizedBox(height: 12),
        if (photoUrl != null && photoUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              photoUrl!,
              width: 109,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          )
        else
          const Text('—'),
      ],
    ),
  );
}

BoxDecoration _cardDecoration(double radius) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: const [
    BoxShadow(color: Color(0x1F000000), blurRadius: 4, offset: Offset(0, 2)),
  ],
);
