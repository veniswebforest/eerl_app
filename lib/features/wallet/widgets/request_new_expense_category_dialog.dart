import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'log_expense_field.dart';

class RequestNewExpenseCategoryDialog extends StatefulWidget {
  const RequestNewExpenseCategoryDialog({super.key});

  @override
  State<RequestNewExpenseCategoryDialog> createState() =>
      _RequestNewExpenseCategoryDialogState();
}

class _RequestNewExpenseCategoryDialogState
    extends State<RequestNewExpenseCategoryDialog> {
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    l10n.requestNewExpenseCategory,
                    style: AppTextStyles.boldH7_16.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                LogExpenseField(
                  label: l10n.expenseCategoryName,
                  requiredField: true,
                  child: LogExpenseInput(
                    controller: _categoryController,
                    hint: l10n.expenseCategoryNameHint,
                  ),
                ),
                const SizedBox(height: 16),
                LogExpenseField(
                  label: l10n.expenseReasonDescription,
                  child: LogExpenseInput(
                    controller: _descriptionController,
                    hint: l10n.expenseDescriptionHint,
                    maxLines: 4,
                    maxLength: 150,
                    counterText: l10n.expenseDescriptionCounter,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            foregroundColor: AppColors.neutral950,
                            backgroundColor: AppColors.cool200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          key: const Key('submit-new-expense-category'),
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primary500,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(l10n.collectionSubmit),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
