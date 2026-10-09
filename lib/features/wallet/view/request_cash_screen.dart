import 'dart:async';

import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
import 'package:eerl_app/shared/widgets/app_snackbar.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import '../widgets/request_cash_field.dart';
import '../widgets/request_cash_reason_selector.dart';
import '../widgets/request_cash_success_dialog.dart';
import '../widgets/wallet_screen_header.dart';

class RequestCashScreen extends StatefulWidget {
  const RequestCashScreen({super.key});

  @override
  State<RequestCashScreen> createState() => _RequestCashScreenState();
}

class _RequestCashScreenState extends State<RequestCashScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _selectedReason;
  bool _reasonOpen = false;
  bool _isSubmitting = false;

  bool get _canSubmit =>
      !_isSubmitting &&
      (double.tryParse(_amountController.text.trim()) ?? 0) > 0 &&
      _selectedReason != null;

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
    final reasons = [
      l10n.cashReasonEmergencyFuel,
      l10n.cashReasonDailyAdvance,
      l10n.cashReasonBulkPurchase,
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  AppScreenHeaderMetrics.topInset,
                  20,
                  24,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WalletScreenHeader(title: l10n.cashRequestTitle),
                          const SizedBox(height: 24),
                          RequestCashField(
                            label: l10n.cashRequestedAmount,
                            requiredField: true,
                            child: RequestCashInput(
                              controller: _amountController,
                              hint: l10n.cashAmountHint,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  '₹',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.regularB7_14.copyWith(
                                    color: AppColors.neutral950,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(height: 24),
                          RequestCashField(
                            label: l10n.cashReasonPurpose,
                            requiredField: true,
                            child: RequestCashReasonSelector(
                              placeholder: l10n.cashReasonHint,
                              options: reasons,
                              isOpen: _reasonOpen,
                              selectedIndex: _selectedReason,
                              onToggle: () =>
                                  setState(() => _reasonOpen = !_reasonOpen),
                              onSelected: (index) => setState(() {
                                _selectedReason = index;
                                _reasonOpen = false;
                              }),
                            ),
                          ),
                          const SizedBox(height: 24),
                          RequestCashField(
                            label: l10n.expenseDescriptionLabel,
                            child: RequestCashInput(
                              controller: _descriptionController,
                              hint: l10n.expenseDescriptionHint,
                              maxLines: 5,
                              maxLength: 150,
                              counterText: l10n.expenseDescriptionCounter,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                  color: AppColors.secondary500,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    l10n.cashCreditsAfterApproval,
                                    style: AppTextStyles.regularB8_12.copyWith(
                                      color: AppColors.secondary500,
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
                ],
              ),
            ),
            _SubmitArea(
              enabled: _canSubmit,
              isSubmitting: _isSubmitting,
              onSubmit: () => _submitRequest(reasons),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRequest(List<String> reasons) async {
    if (!_canSubmit) return;
    final amount = double.parse(_amountController.text.trim());
    final purpose = reasons[_selectedReason!];
    final description = _descriptionController.text.trim();
    final reason = description.isEmpty ? purpose : '$purpose: $description';
    setState(() => _isSubmitting = true);
    try {
      await EerlLocalRepository.instance.saveCashRequest(
        amount: amount,
        reason: reason,
      );
      unawaited(BootstrapSyncService.instance.triggerAfterLocalMutation());
      if (!mounted) return;
      await _showSuccessDialog();
    } on CashRequestBalanceUnavailableException catch (error) {
      AppLogger.diagnostic('CASH_REQUEST_VALIDATION', error.toString());
      if (mounted) {
        AppSnackbar.error(context, message: error.toString());
      }
    } catch (error) {
      AppLogger.error('CASH_REQUEST_SAVE', error.toString());
      if (mounted) {
        AppSnackbar.error(context, message: error.toString());
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showSuccessDialog() async {
    final submitted = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.neutral950.withValues(alpha: 0.64),
      builder: (_) =>
          RequestCashSuccessDialog(amount: _amountController.text.trim()),
    );
    if (submitted == true && mounted) Navigator.of(context).pop();
  }
}

class _SubmitArea extends StatelessWidget {
  const _SubmitArea({
    required this.enabled,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final bool enabled;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const Key('submit-cash-request'),
                  onPressed: enabled ? onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    disabledBackgroundColor: AppColors.neutral400,
                    foregroundColor: AppColors.neutral50,
                    disabledForegroundColor: AppColors.neutral50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: AppTextStyles.semiboldH9_14,
                  ),
                  child: isSubmitting
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(context.l10n.cashSubmitRequest),
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text.rich(
                  TextSpan(
                    text: context.l10n.cashPendingPrefix,
                    children: [
                      TextSpan(
                        text: context.l10n.cashPendingStatus,
                        style: const TextStyle(color: AppColors.yellow600),
                      ),
                      TextSpan(text: context.l10n.cashPendingSuffix),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regularB8_12.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
