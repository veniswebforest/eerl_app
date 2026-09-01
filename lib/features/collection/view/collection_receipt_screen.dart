import 'package:flutter/material.dart';
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Color(0x18000000), blurRadius: 8),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/collection_detail/eer_logo.png',
                        width: 141,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'RCP-2026-000245',
                        style: AppTextStyles.boldH8_14.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                      const Divider(height: 32),
                      _receiptRow(
                        context.l10n.collectionDetailId,
                        '#COL-2026-089',
                      ),
                      _receiptRow(
                        context.l10n.collectionReceiptDate,
                        '24 Oct 2026',
                      ),
                      _receiptRow(
                        context.l10n.collectionReceiptTime,
                        '03:45 PM',
                      ),
                      _receiptRow(context.l10n.collectionDetailType, 'D2D'),
                      const Divider(height: 32),
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
                      ),
                      const SizedBox(height: 16),
                      _receiptItem(
                        context.l10n.collectionDetailHdpeRigid,
                        context.l10n.collectionHdpeReceiptDetail,
                        '₹726.75',
                      ),
                      const SizedBox(height: 16),
                      _receiptItem(
                        context.l10n.collectionDetailPpHardPlastics,
                        context.l10n.collectionPpReceiptDetail,
                        '₹540.00',
                      ),
                      const Divider(height: 32),
                      _receiptRow(
                        context.l10n.collectionTotalWeight,
                        '217.5 KG',
                      ),
                      const Divider(height: 32),
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
                      const Divider(height: 32),
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
            const SizedBox(height: 32),
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
                        Flexible(child: Text(context.l10n.collectionShareSlip)),
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
                        Flexible(child: Text(context.l10n.collectionPrintSlip)),
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
        Text(value, style: AppTextStyles.mediumSH8_14),
      ],
    ),
  );

  Widget _receiptItem(String name, String detail, String price) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: AppTextStyles.mediumSH8_14),
            const SizedBox(height: 4),
            Text(
              detail,
              style: AppTextStyles.mediumSH9_12.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
      Text(price, style: AppTextStyles.mediumSH8_14),
    ],
  );
}
