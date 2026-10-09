import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/create_transfer_request_view.dart';
import '../widgets/transfer_material_card.dart';
import '../widgets/transfer_request_success_dialog.dart';

class CreateTransferRequestScreen extends StatefulWidget {
  const CreateTransferRequestScreen({
    super.key,
    this.initialView = CreateTransferRequestView.items,
    this.stockLoader,
  });

  final CreateTransferRequestView initialView;
  final Future<List<StockModel>> Function()? stockLoader;

  @override
  State<CreateTransferRequestScreen> createState() =>
      _CreateTransferRequestScreenState();
}

class _CreateTransferRequestScreenState
    extends State<CreateTransferRequestScreen> {
  late final LocalQueryController<List<StockModel>> _controller;
  final Map<String, TextEditingController> _quantityControllers = {};
  final TextEditingController _estimatedExpenseController =
      TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _selectedItemId;
  String _query = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(
      widget.stockLoader ?? EerlLocalRepository.instance.getTransferStockInHand,
    )..load();
    _estimatedExpenseController.addListener(_quantityChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _estimatedExpenseController.dispose();
    _noteController.dispose();
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _quantityController(String itemId) =>
      _quantityControllers.putIfAbsent(itemId, () {
        final controller = TextEditingController();
        controller.addListener(_quantityChanged);
        return controller;
      });

  void _quantityChanged() {
    if (mounted) setState(() {});
  }

  bool get _hasValidQuantities {
    final itemId = _selectedItemId;
    if (itemId == null) return false;
    final stockByItem = {
      for (final stock in _controller.data ?? const <StockModel>[])
        stock.itemId: stock.qty,
    };
    final quantity = double.tryParse(_quantityControllers[itemId]?.text ?? '');
    final available = stockByItem[itemId];
    return quantity != null &&
        quantity > 0 &&
        available != null &&
        quantity <= available;
  }

  double? get _estimatedExpense =>
      double.tryParse(_estimatedExpenseController.text.trim());

  bool get _hasValidExpense =>
      _estimatedExpense != null &&
      _estimatedExpense!.isFinite &&
      _estimatedExpense! >= 0;

  Map<String, double> get _selectedQuantities {
    final itemId = _selectedItemId;
    if (itemId == null) return const {};
    return {itemId: double.parse(_quantityControllers[itemId]!.text)};
  }

  void _toggleItem(String itemId) {
    setState(() {
      _selectedItemId = _selectedItemId == itemId ? null : itemId;
    });
  }

  Future<void> _continue() async {
    if (!_hasValidQuantities || !_hasValidExpense || _saving) return;
    setState(() => _saving = true);
    try {
      await EerlLocalRepository.instance.saveTransferRequest(
        itemQuantities: _selectedQuantities,
        estimatedExpense: _estimatedExpense!,
        note: _noteController.text,
      );
      unawaited(BootstrapSyncService.instance.triggerAfterLocalMutation());
      if (!mounted) return;
      final submitted = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: .58),
        builder: (_) => const TransferRequestSuccessDialog(),
      );
      if (submitted == true && mounted) Navigator.of(context).pop();
    } on TransferStockUnavailableException catch (error) {
      if (!mounted) return;
      AppLogger.diagnostic('TRANSFER_VALIDATION', error.toString());
      await _controller.load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text(context.l10n.transferStockValidation),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      AppLogger.error('TRANSFER_SAVE', error.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text(
            'Transfer request could not be saved. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: null,
      backIconAsset: 'assets/icons/records/back.svg',
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    if (_controller.isLoading && !_controller.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (_controller.error != null) {
                      return Center(
                        child: TextButton(
                          onPressed: _controller.load,
                          child: const Text('Retry'),
                        ),
                      );
                    }
                    return _content(
                      context,
                      _controller.data ?? const <StockModel>[],
                    );
                  },
                ),
              ),
              _BottomAction(
                onPressed: _hasValidQuantities && _hasValidExpense && !_saving
                    ? _continue
                    : null,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _content(BuildContext context, List<StockModel> stocks) {
    final normalizedQuery = _query.trim().toLowerCase();
    final visibleStocks = stocks
        .where(
          (stock) =>
              normalizedQuery.isEmpty ||
              (stock.name ?? stock.itemId).toLowerCase().contains(
                normalizedQuery,
              ),
        )
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        key: const Key('create-transfer-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.transferSelectItemsTitle,
              style: AppTextStyles.semiboldH7_18.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.transferSelectItemsSubtitle,
              style: AppTextStyles.mediumSH8_14.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 24),
            _SearchField(
              hint: context.l10n.transferSearchHint,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),
            if (visibleStocks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(child: Text(context.l10n.transferEmptyMessage)),
              )
            else
              for (var index = 0; index < visibleStocks.length; index++) ...[
                Builder(
                  builder: (context) {
                    final stock = visibleStocks[index];
                    final selected = _selectedItemId == stock.itemId;
                    final enteredQuantity = double.tryParse(
                      _quantityControllers[stock.itemId]?.text ?? '',
                    );
                    return TransferMaterialCard(
                      key: Key('transfer-material-${stock.itemId}'),
                      name: stock.name ?? stock.itemId,
                      capacity: context.l10n.transferAvailableStock(
                        '${stock.qty.toStringAsFixed(2)} ${stock.unitCode ?? 'KG'}',
                      ),
                      selected: selected,
                      onTap: () => _toggleItem(stock.itemId),
                      child: _QuantityField(
                        itemId: stock.itemId,
                        controller: _quantityController(stock.itemId),
                        errorText:
                            enteredQuantity != null &&
                                enteredQuantity > stock.qty
                            ? context.l10n.transferStockValidation
                            : null,
                      ),
                    );
                  },
                ),
                if (index != visibleStocks.length - 1)
                  const SizedBox(height: 12),
              ],
            const SizedBox(height: 20),
            _TransferRequestFields(
              estimatedExpenseController: _estimatedExpenseController,
              noteController: _noteController,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferRequestFields extends StatelessWidget {
  const _TransferRequestFields({
    required this.estimatedExpenseController,
    required this.noteController,
  });

  final TextEditingController estimatedExpenseController;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.transferEstimatedExpenseLabel,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 8),
      TextField(
        key: const Key('transfer-estimated-expense'),
        controller: estimatedExpenseController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: _inputDecoration(context.l10n.transferEstimatedExpenseHint),
      ),
      const SizedBox(height: 16),
      Text(
        context.l10n.transferNoteLabel,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 8),
      TextField(
        key: const Key('transfer-note'),
        controller: noteController,
        maxLines: 3,
        decoration: _inputDecoration(context.l10n.transferNoteHint),
      ),
    ],
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.regularB7_14.copyWith(color: AppColors.neutral400),
    filled: true,
    fillColor: AppColors.neutral50,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primary500),
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 55,
    child: TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.regularB7_14.copyWith(
          color: AppColors.neutral400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(15),
          child: SvgPicture.asset('assets/icons/wallet/search.svg'),
        ),
        filled: true,
        fillColor: AppColors.neutral50,
        contentPadding: EdgeInsets.zero,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.cool400),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary500),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

class _QuantityField extends StatelessWidget {
  const _QuantityField({
    required this.itemId,
    required this.controller,
    this.errorText,
  });
  final String itemId;
  final TextEditingController controller;
  final String? errorText;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.transferTotalKgLabel,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: errorText == null ? 55 : 78,
        child: TextField(
          key: Key('transfer-item-kg-$itemId'),
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.regularB7_14,
          decoration: InputDecoration(
            errorText: errorText,
            hintText: context.l10n.transferTotalKgHint,
            hintStyle: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.neutral400,
            ),
            filled: true,
            fillColor: AppColors.neutral50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.cool400),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primary500),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    ],
  );
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
    color: AppColors.backgroundColor,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            key: const Key('transfer-continue'),
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: AppColors.neutral50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.transferContinuePlain,
                  style: AppTextStyles.semiboldH9_14,
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  'assets/icons/profile/arrow_right.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.neutral50,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
