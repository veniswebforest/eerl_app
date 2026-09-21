import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class CollectionReceiptScreen extends StatelessWidget {
  const CollectionReceiptScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  static Route<void> route() => MaterialPageRoute<void>(
    builder: (routeContext) =>
        CollectionReceiptScreen(onBack: () => Navigator.of(routeContext).pop()),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: AppColors.primary500,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      key: const Key('collection-receipt-back'),
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SvgPicture.asset(
                          'assets/icons/records/back.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Color(0x18000000), blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/collection_detail/eer_logo.png',
                        width: 141,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      _receiptRow(
                        context.l10n.collectionReceiptId,
                        '#REC-2026-002',
                      ),
                      _receiptRow(
                        context.l10n.collectionReceiptDate,
                        '24 Oct 2026',
                      ),
                      _receiptRow(
                        context.l10n.collectionReceiptTime,
                        '03:45 PM',
                      ),
                      _receiptRow(
                        context.l10n.collectionReceiptCenter,
                        'EERL - Surat Zone',
                      ),
                      _receiptRow(
                        context.l10n.collectionReceiptAgent,
                        'Rahul Patel',
                      ),
                      _receiptRow(context.l10n.collectionDetailType, 'MRF'),
                      _receiptRow(
                        context.l10n.collectionReceiptSupervisor,
                        'Mohan Prasad',
                      ),
                      _receiptRow(
                        context.l10n.collectionGivenBy,
                        'Chunilal Yadav',
                      ),
                      _receiptRow(
                        context.l10n.collectionReceiptLabor,
                        'Vikram Singh (••• 4321)',
                      ),
                      const _ReceiptDivider(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.l10n.collectionCollectedItems,
                          style: AppTextStyles.boldH8_14.copyWith(
                            color: AppColors.cool950,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _receiptItem(
                        context.l10n.collectionDetailPetBottles,
                        context.l10n.collectionPetReceiptDetail,
                        '₹1,440.00',
                        context: context,
                        unit: context.l10n.collectionUnitKg,
                        quantity: '120.00',
                      ),
                      const _ReceiptDivider(),
                      _receiptItem(
                        context.l10n.collectionDetailHdpeRigid,
                        context.l10n.collectionReceiptHdpePieces,
                        '₹726.75',
                        context: context,
                        unit: context.l10n.collectionUnitPcs,
                        quantity: '80',
                      ),
                      const _ReceiptDivider(),
                      _receiptItem(
                        context.l10n.collectionDetailPpHardPlastics,
                        context.l10n.collectionPpReceiptDetail,
                        '₹540.00',
                        context: context,
                        unit: context.l10n.collectionUnitKg,
                        quantity: '120.00',
                      ),
                      const _ReceiptDivider(),
                      _quantityBlock(
                        context,
                        context.l10n.collectionReceiptKgBlock,
                        '217.5 ${context.l10n.collectionUnitKg}',
                        '-20.00 ${context.l10n.collectionUnitKg}',
                      ),
                      const _ReceiptDivider(),
                      _quantityBlock(
                        context,
                        context.l10n.collectionReceiptPcsBlock,
                        '80 ${context.l10n.collectionUnitPcs}',
                        '00 ${context.l10n.collectionUnitPcs}',
                      ),
                      const _ReceiptDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.collectionReceiptTotal,
                            style: AppTextStyles.mediumSH6_18,
                          ),
                          Text(
                            '₹2,706.75',
                            style: AppTextStyles.mediumSH6_18.copyWith(
                              color: AppColors.primary500,
                            ),
                          ),
                        ],
                      ),
                      const _ReceiptDivider(),
                      Text(
                        context.l10n.collectionReceiptAgent,
                        style: AppTextStyles.mediumSH9_12.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Rahul Patel', style: AppTextStyles.mediumSH8_14),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.collectionThankYou,
                        style: AppTextStyles.boldH8_14.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.collectionSystemGeneratedSlip,
                        style: AppTextStyles.mediumSH9_12.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SvgPicture.asset(
                        'assets/icons/collection/receipt_dots.svg',
                        width: 116,
                        height: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.collectionPrinterHint,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mediumSH9_12.copyWith(
                    color: AppColors.cool600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/collection/share_slip.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(context.l10n.collectionShareSlip),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/collection/print_slip.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(context.l10n.collectionPrintSlip),
                            ),
                          ],
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
    ),
  );

  Widget _receiptRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.regularB7_14,
          ),
        ),
      ],
    ),
  );

  Widget _quantityBlock(
    BuildContext context,
    String title,
    String total,
    String difference,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTextStyles.semiboldH9_14),
      const SizedBox(height: 8),
      _receiptRow(context.l10n.collectionReceiptCollectedTotal, total),
      _receiptRow(context.l10n.collectionReceiptVerifiedTotal, total),
      _receiptRow(context.l10n.collectionReceiptDifference, difference),
    ],
  );

  Widget _receiptItem(
    String name,
    String detail,
    String price, {
    required BuildContext context,
    required String unit,
    required String quantity,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.mediumSH8_14),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: AppTextStyles.regularB8_12.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(price, style: AppTextStyles.regularB7_14),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _quantity(context.l10n.collectionCollected, unit, quantity),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _quantity(context.l10n.expenseVerified, unit, quantity),
          ),
        ],
      ),
    ],
  );

  Widget _quantity(String label, String unit, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.regularB8_12),
      const SizedBox(height: 4),
      Text('$unit   $value', style: AppTextStyles.regularB7_14),
    ],
  );
}

class _ReceiptDivider extends StatelessWidget {
  const _ReceiptDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: DottedBorder(
      options: const RectDottedBorderOptions(
        color: AppColors.cool400,
        dashPattern: [3, 4],
        padding: EdgeInsets.zero,
      ),
      child: const SizedBox(width: double.infinity, height: 0),
    ),
  );
}
