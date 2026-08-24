import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../widgets/expense_category_selector.dart';
import '../widgets/log_expense_field.dart';
import '../widgets/receipt_upload_section.dart';
import '../widgets/wallet_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';

class LogExpenseScreen extends StatefulWidget {
  const LogExpenseScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<LogExpenseScreen> createState() => _LogExpenseScreenState();
}

class _LogExpenseScreenState extends State<LogExpenseScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _selectedCategory;
  bool _categoryOpen = false;
  bool _hasReceipts = false;

  bool get _canSubmit =>
      _selectedCategory != null &&
      _amountController.text.trim().isNotEmpty &&
      _hasReceipts;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_refresh);
  }

  @override
  void dispose() {
    _amountController
      ..removeListener(_refresh)
      ..dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = [
      l10n.expenseCategoryLabour,
      l10n.expenseCategoryFuel,
      l10n.expenseCategoryVehicle,
      l10n.expenseCategoryFood,
      l10n.expenseCategorySupplies,
      l10n.expenseCategoryOther,
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            AppScreenHeaderMetrics.topInset,
            20,
            32,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WalletScreenHeader(
                      title: l10n.logExpense,
                      onBack: widget.onBack,
                    ),
                    const SizedBox(height: 24),
                    LogExpenseField(
                      label: l10n.expenseCategoryLabel,
                      requiredField: true,
                      child: ExpenseCategorySelector(
                        placeholder: l10n.selectExpenseCategory,
                        items: categories,
                        isOpen: _categoryOpen,
                        selectedIndex: _selectedCategory,
                        onToggle: () {
                          setState(() => _categoryOpen = !_categoryOpen);
                        },
                        onSelected: (index) {
                          setState(() {
                            _selectedCategory = index;
                            _categoryOpen = false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    LogExpenseField(
                      label: l10n.expenseAmountLabel,
                      requiredField: true,
                      child: LogExpenseInput(
                        controller: _amountController,
                        hint: l10n.expenseAmountHint,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 24),
                    LogExpenseField(
                      label: l10n.uploadReceiptLabel,
                      requiredField: !_hasReceipts,
                      child: ReceiptUploadSection(
                        captureLabel: l10n.capturePhoto,
                        helperText: l10n.receiptSupportMessage,
                        hasReceipts: _hasReceipts,
                        onCapture: () => setState(() => _hasReceipts = true),
                        onRemove: () => setState(() => _hasReceipts = false),
                      ),
                    ),
                    const SizedBox(height: 24),
                    LogExpenseField(
                      label: l10n.expenseDescriptionLabel,
                      child: LogExpenseInput(
                        controller: _descriptionController,
                        hint: l10n.expenseDescriptionHint,
                        maxLines: 5,
                        maxLength: 150,
                        counterText: l10n.expenseDescriptionCounter,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        key: const Key('submit-expense-button'),
                        onPressed: _canSubmit ? () {} : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          disabledBackgroundColor: AppColors.neutral400,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: AppTextStyles.boldH7_16,
                        ),
                        child: Text(l10n.submitExpenseClaim),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 270),
                        child: Text.rich(
                          TextSpan(
                            text: l10n.expensePendingPrefix,
                            children: [
                              TextSpan(
                                text: l10n.expensePendingStatus,
                                style: const TextStyle(
                                  color: AppColors.yellow600,
                                ),
                              ),
                              TextSpan(text: l10n.expensePendingSuffix),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.mediumSH9_12.copyWith(
                            color: AppColors.cool600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
