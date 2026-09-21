import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/create_transfer_request_view.dart';
import '../widgets/transfer_material_card.dart';
import '../widgets/transfer_request_success_dialog.dart';

class CreateTransferRequestScreen extends StatefulWidget {
  const CreateTransferRequestScreen({
    super.key,
    required this.onBack,
    required this.onBackToList,
    this.initialView = CreateTransferRequestView.items,
  });

  final VoidCallback onBack;
  final VoidCallback onBackToList;
  final CreateTransferRequestView initialView;

  @override
  State<CreateTransferRequestScreen> createState() =>
      _CreateTransferRequestScreenState();
}

class _CreateTransferRequestScreenState
    extends State<CreateTransferRequestScreen> {
  late final TextEditingController _quantityController;
  int _selectedMaterial = 0;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.initialView == CreateTransferRequestView.error
          ? '27000.00'
          : '',
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .58),
      builder: (dialogContext) => TransferRequestSuccessDialog(
        onBackToList: () {
          Navigator.of(dialogContext).pop();
          widget.onBackToList();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: null,
      onBackTap: widget.onBack,
      backIconAsset: 'assets/icons/records/back.svg',
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(child: _content(context)),
              _BottomAction(onPressed: _continue),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _content(BuildContext context) {
    final materials = [
      (
        context.l10n.configurePetBottles,
        context.l10n.transferAvailableStock('1200.60 KG'),
      ),
      (
        context.l10n.transferPlasticWaste,
        context.l10n.transferCapacity('950.60 KG'),
      ),
      (
        context.l10n.configureMilkPouch,
        context.l10n.transferCapacity('800.60 KG'),
      ),
      (
        context.l10n.transferCardboard,
        context.l10n.transferCapacity('1000.60 KG'),
      ),
      (
        context.l10n.transferPaperWaste,
        context.l10n.transferCapacity('1300.60 KG'),
      ),
    ];

    return SingleChildScrollView(
      key: const Key('create-transfer-scroll'),
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
          _SearchField(hint: context.l10n.transferSearchHint),
          const SizedBox(height: 16),
          for (var index = 0; index < materials.length; index++) ...[
            TransferMaterialCard(
              key: Key('transfer-material-$index'),
              name: materials[index].$1,
              capacity: materials[index].$2,
              selected: _selectedMaterial == index,
              onTap: () => setState(() => _selectedMaterial = index),
              child: _QuantityField(controller: _quantityController),
            ),
            if (index != materials.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint});
  final String hint;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 55,
    child: TextField(
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
  const _QuantityField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.transferEstimatedExpenseLabel,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 55,
        child: TextField(
          key: const Key('transfer-total-kg'),
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.regularB7_14,
          decoration: InputDecoration(
            hintText: context.l10n.transferEstimatedExpenseHint,
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
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
    color: AppColors.backgroundColor,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.primary100,
            border: Border.all(color: AppColors.primary400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/records/ic_true_underline.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.transferTotalKg,
                  style: AppTextStyles.semiboldH9_14,
                ),
              ),
              Container(width: 1, height: 24, color: AppColors.neutral950),
              Expanded(
                child: Text(
                  context.l10n.transferTotalKgValue,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.boldH7_16.copyWith(
                    color: AppColors.primary500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
