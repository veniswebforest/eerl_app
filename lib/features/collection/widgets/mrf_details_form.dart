import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class MrfDetailsForm extends StatelessWidget {
  const MrfDetailsForm({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FieldLabel(text: context.l10n.collectionTypes, required: true),
      const SizedBox(height: 8),
      Container(
        key: const Key('mrf-fixed-collection-type'),
        width: double.infinity,
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cool200,
          border: Border.all(color: AppColors.cool400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/home/collection_mrf.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.neutral900,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.collectionMrfShort,
              style: AppTextStyles.regularB7_14,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Text(
        context.l10n.collectionMrfDetails,
        style: AppTextStyles.mediumSH8_14,
      ),
      const SizedBox(height: 8),
      const _ContactCard(
        cardKey: Key('mrf-supervisor-details'),
        fullName: 'Chunilal Yadav',
        mobileNumber: '1234567890',
      ),
      const SizedBox(height: 8),
      Text.rich(
        key: const Key('mrf-team-verification'),
        TextSpan(
          text: context.l10n.collectionTeamVerifiedBy,
          children: [
            TextSpan(
              text: context.l10n.collectionSupervisor,
              style: AppTextStyles.regularB8_12.copyWith(
                color: AppColors.primary500,
              ),
            ),
          ],
        ),
        style: AppTextStyles.regularB8_12.copyWith(color: AppColors.cool600),
      ),
      const SizedBox(height: 24),
      Text(context.l10n.collectionLaborOne, style: AppTextStyles.mediumSH8_14),
      const SizedBox(height: 8),
      const _ContactCard(
        cardKey: Key('mrf-labor-details'),
        fullName: 'Haresh Matiya',
        mobileNumber: '0987654321',
      ),
    ],
  );
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.cardKey,
    required this.fullName,
    required this.mobileNumber,
  });

  final Key cardKey;
  final String fullName;
  final String mobileNumber;

  @override
  Widget build(BuildContext context) => Container(
    key: cardKey,
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
    decoration: BoxDecoration(
      color: AppColors.cool200,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailLine(label: context.l10n.collectionFullName, value: fullName),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, color: AppColors.cool400),
        ),
        _DetailLine(
          label: context.l10n.collectionMobileNumber,
          value: mobileNumber,
        ),
      ],
    ),
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.regularB8_12.copyWith(color: AppColors.neutral700),
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.neutral900,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiboldH9_14,
            ),
          ),
        ],
      ),
    ],
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: text,
      children: required
          ? const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.red600),
              ),
            ]
          : const [],
    ),
    style: AppTextStyles.mediumSH8_14,
  );
}
