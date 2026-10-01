import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_labeled_dropdown.dart';
import 'package:eerl_app/shared/widgets/app_square_back_button.dart';

class D2dVehicleForm extends StatelessWidget {
  const D2dVehicleForm({
    super.key,
    required this.editing,
    required this.numberController,
    required this.centerOptions,
    required this.selectedCenter,
    required this.centerExpanded,
    required this.onCenterToggle,
    required this.onCenterSelected,
    required this.onBack,
    required this.onCancel,
    required this.onSave,
  });

  final bool editing;
  final TextEditingController numberController;
  final List<String> centerOptions;
  final int selectedCenter;
  final bool centerExpanded;
  final VoidCallback onCenterToggle;
  final ValueChanged<int> onCenterSelected;
  final VoidCallback onBack;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppSquareBackButton(
                        key: const Key('d2d-vehicle-form-back'),
                        onTap: onBack,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      editing
                          ? context.l10n.d2dEditVehicleTitle
                          : context.l10n.d2dAddNewVehicleTitle,
                      style: AppTextStyles.semiboldH6_20.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppLabeledDropdown(
                      label: context.l10n.d2dSelectCollectionCenter,
                      hint: context.l10n.d2dSelectCenter,
                      options: centerOptions,
                      selectedIndex: selectedCenter,
                      expanded: centerExpanded,
                      requiredField: true,
                      selectorKey: const Key('d2d-form-center-selector'),
                      optionsKey: const Key('d2d-form-center-options'),
                      optionKeyPrefix: 'd2d-form-center',
                      onToggle: onCenterToggle,
                      onSelected: onCenterSelected,
                    ),
                    const SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        text: context.l10n.d2dVehicleNumber,
                        children: const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: AppColors.red500),
                          ),
                        ],
                      ),
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 55,
                      child: TextField(
                        key: const Key('d2d-vehicle-number-field'),
                        controller: numberController,
                        textCapitalization: TextCapitalization.characters,
                        style: AppTextStyles.regularB7_14.copyWith(
                          color: AppColors.neutral950,
                        ),
                        decoration: InputDecoration(
                          hintText: context.l10n.d2dVehicleNumberHint,
                          hintStyle: AppTextStyles.regularB7_14.copyWith(
                            color: AppColors.neutral500,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.cool400,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.primary500,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.d2dVehicleNumberExample,
                      style: AppTextStyles.regularB8_12.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          key: const Key('d2d-form-cancel'),
                          onPressed: onCancel,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.cool200,
                            foregroundColor: AppColors.neutral950,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: AppTextStyles.mediumSH7_16,
                          ),
                          child: Text(context.l10n.cancel),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          key: const Key('d2d-form-save'),
                          onPressed: onSave,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primary500,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: AppTextStyles.boldH7_16,
                          ),
                          child: Text(context.l10n.d2dSave),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
