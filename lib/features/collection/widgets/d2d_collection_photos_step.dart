import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/bootstrap/service/item_image_cache_service.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';

enum D2dMeasureUnit { kg, pcs }

enum D2dPaymentMode { cash, upi }

D2dMeasureUnit defaultCollectionUnit(ItemModel item) {
  final code = item.unitCode.trim().toUpperCase();
  return code == 'PCS' || code == 'PC' || code == 'PIECE'
      ? D2dMeasureUnit.pcs
      : D2dMeasureUnit.kg;
}

class D2dCollectionPhotosStep extends StatelessWidget {
  const D2dCollectionPhotosStep({
    super.key,
    required this.selectedItems,
    required this.items,
    required this.photos,
    required this.collectionWeights,
    required this.verifiedWeights,
    required this.units,
    required this.paymentMode,
    this.showPaymentMode = true,
    required this.onCollectionWeightChanged,
    required this.onVerifiedWeightChanged,
    required this.onCapture,
    required this.onRemove,
    required this.onPreview,
    required this.onPaymentModeChanged,
  });

  final List<int> selectedItems;
  final List<ItemModel> items;
  final Map<int, List<XFile>> photos;
  final Map<int, String> collectionWeights;
  final Map<int, String> verifiedWeights;
  final Map<int, D2dMeasureUnit> units;
  final D2dPaymentMode paymentMode;
  final bool showPaymentMode;
  final void Function(int item, String value) onCollectionWeightChanged;
  final void Function(int item, String value) onVerifiedWeightChanged;
  final ValueChanged<int> onCapture;
  final void Function(int item, int photoIndex) onRemove;
  final ValueChanged<XFile> onPreview;
  final ValueChanged<D2dPaymentMode> onPaymentModeChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.collectionCaptureInstructionShort,
        style: AppTextStyles.mediumSH8_14,
      ),
      const SizedBox(height: 16),
      ...selectedItems.map((item) {
        final material = items[item];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _D2dMaterialCard(
            item: item,
            name: material.name,
            imageUrl: material.imageUrl,
            colour: material.colour,
            rate: material.rate,
            photos: photos[item] ?? const [],
            collectionWeight: collectionWeights[item] ?? '',
            verifiedWeight: verifiedWeights[item] ?? '',
            unit: units[item] ?? defaultCollectionUnit(material),
            onCollectionWeightChanged: (value) =>
                onCollectionWeightChanged(item, value),
            onVerifiedWeightChanged: (value) =>
                onVerifiedWeightChanged(item, value),
            onCapture: () => onCapture(item),
            onRemove: (index) => onRemove(item, index),
            onPreview: onPreview,
          ),
        );
      }),
      if (showPaymentMode)
        Container(
          key: const Key('d2d-payment-mode'),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [HomeStyles.cardShadow],
          ),
          child: Row(
            children: [
              Expanded(
                child: _PaymentChoice(
                  choiceKey: const Key('d2d-payment-cash'),
                  label: context.l10n.collectionPaymentCash,
                  icon: 'assets/icons/home/wallet.svg',
                  selected: paymentMode == D2dPaymentMode.cash,
                  onTap: () => onPaymentModeChanged(D2dPaymentMode.cash),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PaymentChoice(
                  choiceKey: const Key('d2d-payment-upi'),
                  label: context.l10n.collectionPaymentUpi,
                  icon: 'assets/icons/wallet/expense_claim_currency.svg',
                  selected: paymentMode == D2dPaymentMode.upi,
                  onTap: () => onPaymentModeChanged(D2dPaymentMode.upi),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _D2dMaterialCard extends StatelessWidget {
  const _D2dMaterialCard({
    required this.item,
    required this.name,
    required this.imageUrl,
    required this.colour,
    required this.rate,
    required this.photos,
    required this.collectionWeight,
    required this.verifiedWeight,
    required this.unit,
    required this.onCollectionWeightChanged,
    required this.onVerifiedWeightChanged,
    required this.onCapture,
    required this.onRemove,
    required this.onPreview,
  });

  final int item;
  final String name;
  final String? imageUrl;
  final String? colour;
  final double? rate;
  final List<XFile> photos;
  final String collectionWeight;
  final String verifiedWeight;
  final D2dMeasureUnit unit;
  final ValueChanged<String> onCollectionWeightChanged;
  final ValueChanged<String> onVerifiedWeightChanged;
  final VoidCallback onCapture;
  final ValueChanged<int> onRemove;
  final ValueChanged<XFile> onPreview;

  @override
  Widget build(BuildContext context) {
    final unitLabel = unit == D2dMeasureUnit.kg
        ? context.l10n.collectionUnitKg
        : context.l10n.collectionUnitPcs;
    final verifiedQuantity = double.tryParse(verifiedWeight.trim());
    final materialTotal = rate == null || verifiedQuantity == null
        ? null
        : rate! * verifiedQuantity;
    final rateText = rate == null
        ? '${context.l10n.collectionDetailRate} —'
        : '${context.l10n.collectionDetailRate} '
              '₹${rate!.toStringAsFixed(2)}/$unitLabel';
    final totalText = materialTotal == null
        ? '${context.l10n.collectionDetailMaterialTotal} —'
        : '${context.l10n.collectionDetailMaterialTotal} '
              '₹${materialTotal.toStringAsFixed(2)}';
    return Container(
      key: Key('d2d-material-card-$item'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cool400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            color: AppColors.cool200,
            child: Row(
              children: [
                _MaterialThumbnail(
                  name: name,
                  imageUrl: imageUrl,
                  colour: colour,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: name,
                      children: [TextSpan(text: '  •  $unitLabel')],
                    ),
                    style: AppTextStyles.regularB7_14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _MeasureField(
                        fieldKey: Key('d2d-collection-weight-$item'),
                        labelKey: Key('d2d-collection-label-$item'),
                        label: context.l10n.collectionCollected,
                        value: collectionWeight,
                        unit: unitLabel,
                        required: true,
                        onChanged: onCollectionWeightChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MeasureField(
                        fieldKey: Key('d2d-verified-weight-$item'),
                        labelKey: Key('d2d-verified-label-$item'),
                        label: context.l10n.expenseVerified,
                        required: true,
                        value: verifiedWeight,
                        unit: unitLabel,
                        onChanged: onVerifiedWeightChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DottedBorder(
                  options: const RectDottedBorderOptions(
                    color: AppColors.cool400,
                    dashPattern: [6, 5],
                    padding: EdgeInsets.zero,
                  ),
                  child: const SizedBox(width: double.infinity, height: 0),
                ),
                if (rate != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          rateText,
                          style: AppTextStyles.regularB8_12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        totalText,
                        style: AppTextStyles.regularB8_12.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                InkWell(
                  key: Key('d2d-capture-photo-$item'),
                  onTap: photos.length < 2 ? onCapture : null,
                  borderRadius: BorderRadius.circular(10),
                  child: DottedBorder(
                    options: const RoundedRectDottedBorderOptions(
                      radius: Radius.circular(10),
                      color: AppColors.primary500,
                      dashPattern: [4, 3],
                      strokeWidth: 1,
                      padding: EdgeInsets.zero,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 82,
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/collection/capture_camera.svg',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              text: context.l10n.collectionCapturePhoto,
                              children: const [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: AppColors.red600),
                                ),
                              ],
                            ),
                            style: AppTextStyles.semiboldH9_14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (photos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: photos.indexed
                          .map(
                            (entry) => Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: InkWell(
                                    onTap: () => onPreview(entry.$2),
                                    child: Image.file(
                                      File(entry.$2.path),
                                      width: 108,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 5,
                                  top: 5,
                                  child: InkWell(
                                    onTap: () => onRemove(entry.$1),
                                    child: SvgPicture.asset(
                                      'assets/icons/wallet/expense_remove.svg',
                                      width: 22,
                                      height: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialThumbnail extends StatelessWidget {
  const _MaterialThumbnail({
    required this.name,
    required this.imageUrl,
    required this.colour,
  });

  final String name;
  final String? imageUrl;
  final String? colour;

  @override
  Widget build(BuildContext context) => FutureBuilder<File?>(
    future: ItemImageCacheService.instance.localFileForUrl(imageUrl),
    builder: (context, snapshot) {
      final file = snapshot.data;
      if (file == null) {
        return Container(
          key: Key('material-colour-swatch-$name'),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _parseMaterialColour(colour),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cool400),
          ),
        );
      }
      return Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('material-image-$name'),
          onTap: () => showDialog<void>(
            context: context,
            barrierColor: Colors.black87,
            builder: (dialogContext) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  InteractiveViewer(
                    child: Image.file(file, fit: BoxFit.contain),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton.filled(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(file, width: 40, height: 40, fit: BoxFit.cover),
          ),
        ),
      );
    },
  );
}

Color _parseMaterialColour(String? value) {
  final normalized = value?.trim().replaceFirst('#', '');
  if (normalized == null) return AppColors.primary100;
  final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? AppColors.primary100 : Color(parsed);
}

class _MeasureField extends StatelessWidget {
  const _MeasureField({
    required this.fieldKey,
    required this.labelKey,
    required this.label,
    required this.value,
    required this.unit,
    required this.onChanged,
    this.required = false,
  });

  final Key fieldKey;
  final Key labelKey;
  final String label;
  final String value;
  final String unit;
  final ValueChanged<String> onChanged;
  final bool required;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text.rich(
        key: labelKey,
        TextSpan(
          text: label,
          children: required
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.red600),
                  ),
                ]
              : const [],
        ),
        maxLines: 2,
        style: AppTextStyles.mediumSH8_14,
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 44,
        child: TextFormField(
          key: fieldKey,
          initialValue: value,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.regularB7_14,
          decoration: InputDecoration(
            hintText: required && value.isEmpty ? '123.00' : '---',
            prefixIcon: Center(
              child: Text(unit, style: AppTextStyles.semiboldH9_14),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 42,
              maxWidth: 42,
            ),
            contentPadding: const EdgeInsets.only(right: 8),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ),
    ],
  );
}

class _PaymentChoice extends StatelessWidget {
  const _PaymentChoice({
    required this.choiceKey,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final Key choiceKey;
  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    key: choiceKey,
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: selected ? AppColors.primary500 : AppColors.cool400,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: selected ? AppColors.primary500 : AppColors.cool500,
              ),
            ),
            child: selected
                ? const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          SvgPicture.asset(
            icon,
            key: ValueKey('payment-icon-$label'),
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.neutral900,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiboldH8_16,
            ),
          ),
        ],
      ),
    ),
  );
}
