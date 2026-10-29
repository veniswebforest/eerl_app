import 'dart:async';

import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/router/app_route_data.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/utils/image_compressor.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/expense_category_selector.dart';
import '../widgets/log_expense_field.dart';
import '../widgets/receipt_upload_section.dart';
import '../widgets/request_new_expense_category_dialog.dart';
import '../widgets/wallet_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_snackbar.dart';
import 'package:eerl_app/shared/widgets/in_app_camera_screen.dart';
import 'package:go_router/go_router.dart';

typedef ExpenseSaver =
    Future<String> Function({
      required String categoryId,
      required double amount,
      required List<String> receiptPaths,
      String? note,
      String? collectionId,
    });

class LogExpenseScreen extends StatefulWidget {
  const LogExpenseScreen({
    super.key,
    this.receiptPhotoPicker,
    this.initialCategories,
    this.expenseSaver,
  });

  final Future<XFile?> Function()? receiptPhotoPicker;
  final List<ExpenseCategoryModel>? initialCategories;
  final ExpenseSaver? expenseSaver;

  @override
  State<LogExpenseScreen> createState() => _LogExpenseScreenState();
}

class _LogExpenseScreenState extends State<LogExpenseScreen> {
  static const _cameraRecoveryId = 'expense.log.receipt';
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<XFile> _receiptPhotos = [];
  List<ExpenseCategoryModel> _categories = const [];
  int? _selectedCategory;
  bool _categoryOpen = false;
  bool _isSubmitting = false;

  bool get _canSubmit =>
      !_isSubmitting &&
      _selectedCategory != null &&
      _selectedCategory! < _categories.length &&
      (double.tryParse(_amountController.text.trim()) ?? 0) > 0 &&
      _receiptPhotos.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_refresh);
    final initialCategories = widget.initialCategories;
    if (initialCategories != null) {
      _categories = initialCategories;
    } else {
      unawaited(_loadCategories());
    }
    _restoreCameraResult();
  }

  Future<void> _restoreCameraResult() async {
    final photo = await ImageCompressor.claimRecoveredImage(_cameraRecoveryId);
    if (photo == null || !mounted || _receiptPhotos.length >= 2) return;
    setState(() => _receiptPhotos.add(photo));
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

  Future<void> _loadCategories() async {
    try {
      final selectedId =
          _selectedCategory != null && _selectedCategory! < _categories.length
          ? _categories[_selectedCategory!].id
          : null;
      final categories = await EerlLocalRepository.instance
          .getExpenseCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        if (selectedId != null) {
          final refreshedIndex = categories.indexWhere(
            (category) => category.id == selectedId,
          );
          _selectedCategory = refreshedIndex < 0 ? null : refreshedIndex;
        }
        _categoryOpen = false;
      });
    } catch (error) {
      AppLogger.error('EXPENSE_CATEGORY_LOAD', error.toString());
    }
  }

  Future<void> _refreshExpenseData() async {
    await _loadCategories();
  }

  Future<void> _captureReceipt() async {
    if (_receiptPhotos.length >= 2) return;
    final picker = widget.receiptPhotoPicker;
    final photo = picker != null
        ? await picker()
        : await InAppCameraScreen.capture(
            context,
            picker: _imagePicker,
            recoveryId: _cameraRecoveryId,
            title: 'Capture Receipt Photo',
          );
    if (photo == null || !mounted) return;
    setState(() => _receiptPhotos.add(photo));
  }

  Future<void> _submitExpense() async {
    if (!_canSubmit) return;
    final selectedCategory = _categories[_selectedCategory!];
    final amount = double.parse(_amountController.text.trim());
    setState(() => _isSubmitting = true);
    try {
      final saver =
          widget.expenseSaver ?? EerlLocalRepository.instance.saveExpense;
      await saver(
        categoryId: selectedCategory.id,
        amount: amount,
        receiptPaths: _receiptPhotos
            .map((photo) => photo.path)
            .toList(growable: false),
        note: _descriptionController.text,
      );
      unawaited(BootstrapSyncService.instance.triggerAfterLocalMutation());
      if (!mounted) return;
      double? remainingBalance;
      try {
        final summary = await EerlLocalRepository.instance.getWalletSummary();
        remainingBalance = summary.balanceNow;
      } catch (error) {
        AppLogger.error('EXPENSE_BALANCE_LOAD', error.toString());
      }
      if (!mounted) return;
      final submitted = await context.push<bool>(
        AppRoutes.expenseSubmitted,
        extra: ExpenseSubmittedRouteData(
          amount: amount,
          remainingBalance: remainingBalance,
        ),
      );
      if (submitted == true && mounted) Navigator.of(context).pop();
    } catch (error) {
      AppLogger.error('EXPENSE_SAVE', error.toString());
      if (mounted) {
        AppSnackbar.error(context, message: error.toString());
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = _categories
        .map((category) => category.name)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          key: const Key('log-expense-refresh'),
          onRefresh: _refreshExpenseData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      WalletScreenHeader(title: l10n.logExpense),
                      const SizedBox(height: 24),
                      LogExpenseField(
                        label: l10n.expenseReasonLabel,
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
                          requestNewCategoryLabel:
                              l10n.requestNewExpenseCategory,
                          onRequestNewCategory: () async {
                            setState(() => _categoryOpen = false);
                            final saved = await showDialog<bool>(
                              context: context,
                              builder: (_) =>
                                  const RequestNewExpenseCategoryDialog(),
                            );
                            if (saved == true && context.mounted) {
                              AppSnackbar.success(
                                context,
                                message: context
                                    .l10n
                                    .expenseCategoryRequestSavedForSync,
                              );
                            }
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
                        requiredField: _receiptPhotos.isEmpty,
                        child: ReceiptUploadSection(
                          captureLabel: l10n.capturePhoto,
                          helperText: l10n.receiptSupportMessage,
                          receiptPaths: _receiptPhotos
                              .map((photo) => photo.path)
                              .toList(growable: false),
                          onCapture: _captureReceipt,
                          onRemove: (index) =>
                              setState(() => _receiptPhotos.removeAt(index)),
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
                          onPressed: _canSubmit ? _submitExpense : null,
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
                          child: _isSubmitting
                              ? const SizedBox.square(
                                  dimension: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(l10n.submitExpenseClaim),
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
      ),
    );
  }
}
