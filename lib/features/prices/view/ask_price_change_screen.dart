import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/prices/model/price_ui_models.dart';
import 'package:eerl_app/features/prices/view/price_request_detail_screen.dart';
import 'package:eerl_app/features/prices/widgets/prices_ui.dart';

class AskPriceChangeScreen extends StatelessWidget {
  const AskPriceChangeScreen({super.key});

  @override
  Widget build(BuildContext context) => PricesPageFrame(
    title: context.l10n.priceAskTitle,
    bottom: PrimaryPriceButton(
      label: context.l10n.priceAskSendRequest,
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) =>
              const PriceRequestDetailScreen(state: PriceRequestState.waiting),
        ),
      ),
    ),
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(
          context.l10n.priceAskDescription,
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 84),
        _StaticField(
          label: context.l10n.priceAskNewPrice,
          initialValue: context.l10n.priceAskMockValue,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 24),
        _StaticField(
          label: context.l10n.priceAskReason,
          initialValue: context.l10n.priceRequestPetReason,
          helper: context.l10n.priceAskMaxCharacters,
          maxLines: 4,
        ),
      ],
    ),
  );
}

class _StaticField extends StatelessWidget {
  const _StaticField({
    required this.label,
    required this.initialValue,
    this.helper,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final String initialValue;
  final String? helper;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: AppTextStyles.regularB7_14.copyWith(color: AppColors.neutral950),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.neutral50,
          contentPadding: const EdgeInsets.all(16),
          helperText: helper,
          helperStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            color: AppColors.neutral400,
          ),
          helperMaxLines: 1,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.cool400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary500),
          ),
        ),
      ),
    ],
  );
}
