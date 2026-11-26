import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:eerl_app/core/utils/input_formatters.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/prices/model/price_ui_models.dart';
import 'package:eerl_app/features/prices/view/price_request_detail_screen.dart';
import 'package:eerl_app/features/prices/widgets/prices_ui.dart';

class AskPriceChangeScreen extends StatefulWidget {
  const AskPriceChangeScreen({required this.requestContext, super.key});

  final PriceRequestContext requestContext;

  @override
  State<AskPriceChangeScreen> createState() => _AskPriceChangeScreenState();
}

class _AskPriceChangeScreenState extends State<AskPriceChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rateController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _rateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PricesPageFrame(
    title: context.l10n.priceAskTitle,
    bottom: PrimaryPriceButton(
      label: context.l10n.priceAskSendRequest,
      onPressed: _saving ? null : _submit,
    ),
    child: Form(
      key: _formKey,
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
          _PriceField(
            controller: _rateController,
            label: context.l10n.priceAskNewPrice,
            keyboardType: AppKeyboards.decimal,
            textInputAction: TextInputAction.next,
            inputFormatters: AppInputFormatters.money(
              maxValue: AppInputLimits.maxRate,
            ),
            validator: _validateRate,
          ),
          const SizedBox(height: 24),
          _PriceField(
            controller: _reasonController,
            label: context.l10n.priceAskReason,
            helper: context.l10n.priceAskMaxCharacters1000,
            maxLines: 4,
            maxLength: 1000,
            keyboardType: AppKeyboards.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            validator: _validateReason,
          ),
        ],
      ),
    ),
  );

  String? _validateRate(String? value) {
    final normalized = value?.trim() ?? '';
    final rate = double.tryParse(normalized);
    if (rate == null ||
        !rate.isFinite ||
        rate < 0 ||
        rate > 99999999.99 ||
        !RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(normalized)) {
      return context.l10n.priceAskInvalidRate;
    }
    return null;
  }

  String? _validateReason(String? value) {
    final reason = value?.trim() ?? '';
    if (reason.isEmpty || reason.length > 1000) {
      return context.l10n.priceAskInvalidReason;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final id = await EerlLocalRepository.instance.savePriceRequest(
        itemId: widget.requestContext.itemId,
        requestedRate: double.parse(_rateController.text.trim()),
        reason: _reasonController.text.trim(),
      );
      final request = await EerlLocalRepository.instance.getPriceRequest(id);
      if (request == null) {
        throw StateError('Saved price request is unavailable.');
      }
      unawaited(BootstrapSyncService.instance.triggerAfterLocalMutation());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.priceRequestSaved)));
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => PriceRequestDetailScreen(request: request),
        ),
      );
    } on LocalWriteValidationException catch (error) {
      if (!mounted) return;
      final message = error.field == 'materialItemId'
          ? context.l10n.priceRequestAlreadyWaiting
          : error.field == 'requestedRate'
          ? context.l10n.priceAskInvalidRate
          : context.l10n.priceAskInvalidReason;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.priceAskSubmitFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.controller,
    required this.label,
    this.helper,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String? helper;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

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
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: AppTextStyles.regularB7_14.copyWith(color: AppColors.neutral950),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.neutral50,
          contentPadding: const EdgeInsets.all(16),
          helperText: helper,
          counterText: '',
          helperStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            color: AppColors.neutral400,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.cool400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary500),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.red500),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.red500),
          ),
        ),
      ),
    ],
  );
}
