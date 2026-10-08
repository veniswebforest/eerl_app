import 'dart:async';

import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'log_expense_field.dart';

class RequestNewExpenseCategoryDialog extends StatefulWidget {
  const RequestNewExpenseCategoryDialog({super.key, this.onSubmit});

  final Future<void> Function(String name, String? reason)? onSubmit;

  @override
  State<RequestNewExpenseCategoryDialog> createState() =>
      _RequestNewExpenseCategoryDialogState();
}

class _RequestNewExpenseCategoryDialogState
    extends State<RequestNewExpenseCategoryDialog> {
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _saving = false;

  bool get _canSubmit => !_saving && _categoryController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _categoryController.addListener(_refresh);
  }

  @override
  void dispose() {
    _categoryController
      ..removeListener(_refresh)
      ..dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _saving = true);
    try {
      final name = _categoryController.text.trim();
      final reason = _descriptionController.text.trim();
      final submit = widget.onSubmit;
      if (submit != null) {
        await submit(name, reason);
      } else {
        await EerlLocalRepository.instance.saveCategoryRequest(
          name: name,
          reason: reason,
        );
        unawaited(BootstrapSyncService.instance.triggerAfterLocalMutation());
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      debugPrint('Expense category request save failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.expenseCategoryRequestSaveFailed)),
      );
      setState(() => _saving = false);
    }
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
                          onPressed: _canSubmit ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primary500,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox.square(
                                  dimension: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(l10n.collectionSubmit),
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
