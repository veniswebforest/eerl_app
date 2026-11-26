import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/utils/input_formatters.dart';
import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/providers/bluetooth_weight_provider.dart';
import 'package:eerl_app/features/bootstrap/service/item_image_cache_service.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/shared/widgets/app_image_preview_dialog.dart';
import 'package:eerl_app/features/collection/widgets/bluetooth_weight_panel.dart';

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
    required this.weightProvider,
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

  final BluetoothWeightProvider weightProvider;
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
        style: AppTextStyles.semiboldH9_14,
      ),
      const SizedBox(height: 16),
      BluetoothWeightPanel(provider: weightProvider),
      ...selectedItems.map((item) {
        final material = items[item];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _D2dMaterialCard(
            item: item,
            name: material.displayName,
            standardName: material.localName?.trim().isNotEmpty == true
                ? material.name
                : null,
            centreUnitName: material.centreUnitName,
            unitFactor: material.unitFactor,
            imageUrl: material.imageUrl,
            colour: material.colour,
            rate: material.centreUnitName == null
                ? material.rate
                : material.ratePerCentreUnit,
            baseRate: material.rate,
            baseUnitLabel: material.unitCode,
            photos: photos[item] ?? const [],
            collectionWeight: collectionWeights[item] ?? '',
            verifiedWeight: verifiedWeights[item] ?? '',
            unit: units[item] ?? defaultCollectionUnit(material),
            bluetoothTarget: weightProvider.targetItem == item,
            onBluetoothTap:
                material.centreUnitName == null &&
                    (units[item] ?? defaultCollectionUnit(material)) ==
                        D2dMeasureUnit.kg
                ? () => weightProvider.selectTarget(item)
                : null,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [HomeStyles.cardShadow],
          ),
          child: Row(
            children: [
              _PaymentChoice(
                choiceKey: const Key('d2d-payment-cash'),
                label: context.l10n.collectionPaymentCash,
                icon: 'assets/icons/collection/payment_cash.svg',
                selected: paymentMode == D2dPaymentMode.cash,
                onTap: () => onPaymentModeChanged(D2dPaymentMode.cash),
              ),
              const SizedBox(width: 16),
              _PaymentChoice(
                choiceKey: const Key('d2d-payment-upi'),
                label: context.l10n.collectionPaymentUpi,
                icon: 'assets/icons/collection/payment_upi.svg',
                selected: paymentMode == D2dPaymentMode.upi,
                onTap: () => onPaymentModeChanged(D2dPaymentMode.upi),
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
    required this.standardName,
    required this.centreUnitName,
    required this.unitFactor,
    required this.imageUrl,
    required this.colour,
    required this.rate,
    required this.baseRate,
    required this.baseUnitLabel,
    required this.photos,
    required this.collectionWeight,
    required this.verifiedWeight,
    required this.unit,
    required this.bluetoothTarget,
    required this.onBluetoothTap,
    required this.onCollectionWeightChanged,
    required this.onVerifiedWeightChanged,
    required this.onCapture,
    required this.onRemove,
    required this.onPreview,
  });

  final int item;
  final String name;
  final String? standardName;
  final String? centreUnitName;
  final double? unitFactor;
  final String? imageUrl;
  final String? colour;
  final double? rate;
  final double? baseRate;
  final String baseUnitLabel;
  final List<XFile> photos;
  final String collectionWeight;
  final String verifiedWeight;
  final D2dMeasureUnit unit;
  final bool bluetoothTarget;
  final VoidCallback? onBluetoothTap;
  final ValueChanged<String> onCollectionWeightChanged;
  final ValueChanged<String> onVerifiedWeightChanged;
  final VoidCallback onCapture;
  final ValueChanged<int> onRemove;
  final ValueChanged<XFile> onPreview;

  @override
  Widget build(BuildContext context) {
    final unitLabel =
        centreUnitName?.toUpperCase() ??
        (unit == D2dMeasureUnit.kg
            ? context.l10n.collectionUnitKg
            : context.l10n.collectionUnitPcs);
    final headerUnitLabel = centreUnitName == null || unitFactor == null
        ? unitLabel
        : '$_displayUnitLabel '
              '(${_compactNumber(unitFactor!)} ${baseUnitLabel.toLowerCase()})';
    final verifiedQuantity = double.tryParse(verifiedWeight.trim());
    final collectedQuantity = double.tryParse(collectionWeight.trim());
    final materialTotal = rate == null || verifiedQuantity == null
        ? null
        : rate! * verifiedQuantity;
    final moneyFormat = NumberFormat('#,##0.00');
    final rateText = rate == null
        ? null
        : '${context.l10n.collectionDetailRate} '
              '₹${moneyFormat.format(rate)}/$_displayUnitLabel';
    final totalText = materialTotal == null
        ? null
        : '${context.l10n.collectionDetailMaterialTotal} '
              '₹${moneyFormat.format(materialTotal)}';
    final conversionText = centreUnitName == null || unitFactor == null
        ? null
        : _conversionText(
            centreUnitName: centreUnitName!,
            unitFactor: unitFactor!,
            baseUnitLabel: baseUnitLabel,
            collectedQuantity: collectedQuantity,
            baseRate: baseRate,
            moneyFormat: moneyFormat,
          );
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      children: [
                        TextSpan(text: '  •  $headerUnitLabel'),
                        if (standardName != null)
                          TextSpan(
                            text: '\n$standardName',
                            style: AppTextStyles.regularB8_12.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                      ],
                    ),
                    style: AppTextStyles.semiboldH9_14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: _MeasureField(
                        fieldKey: Key('d2d-verified-weight-$item'),
                        labelKey: Key('d2d-verified-label-$item'),
                        label: context.l10n.expenseVerified,
                        required: true,
                        value: verifiedWeight,
                        unit: unitLabel,
                        hint:
                            'ex ${collectionWeight.trim().isEmpty ? '123.00' : collectionWeight.trim()}',
                        bluetoothTarget: bluetoothTarget,
                        onBluetoothTap: onBluetoothTap,
                        textInputAction: TextInputAction.done,
                        onChanged: onVerifiedWeightChanged,
                      ),
                    ),
                  ],
                ),
                if (rateText != null || conversionText != null) ...[
                  const SizedBox(height: 16),
                  DottedBorder(
                    options: const RectDottedBorderOptions(
                      color: AppColors.cool400,
                      dashPattern: [6, 5],
                      padding: EdgeInsets.zero,
                    ),
                    child: const SizedBox(width: double.infinity, height: 0),
                  ),
                ],
                if (rateText != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          rateText,
                          style: AppTextStyles.mediumSH8_14,
                        ),
                      ),
                      if (totalText != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          totalText,
                          style: AppTextStyles.semiboldH9_14.copyWith(
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (conversionText != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      conversionText,
                      style: AppTextStyles.mediumSH9_12.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
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
                                      width: 109,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: InkWell(
                                    onTap: () => onRemove(entry.$1),
                                    child: SvgPicture.asset(
                                      'assets/icons/wallet/expense_remove.svg',
                                      width: 24,
                                      height: 24,
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

  String get _displayUnitLabel {
    final value = centreUnitName?.trim();
    if (value == null || value.isEmpty) {
      return unit == D2dMeasureUnit.pcs ? 'Piece' : baseUnitLabel.toUpperCase();
    }
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String _conversionText({
    required String centreUnitName,
    required double unitFactor,
    required String baseUnitLabel,
    required double? collectedQuantity,
    required double? baseRate,
    required NumberFormat moneyFormat,
  }) {
    final centreUnit = centreUnitName.trim();
    final parts = <String>[
      '1 $centreUnit = ${_compactNumber(unitFactor)} '
          '${baseUnitLabel.toUpperCase()}',
    ];
    if (collectedQuantity != null) {
      final quantityText = _compactNumber(collectedQuantity);
      final pluralUnit = collectedQuantity == 1 ? centreUnit : '${centreUnit}s';
      parts.add(
        '$quantityText $pluralUnit = '
        '${(collectedQuantity * unitFactor).toStringAsFixed(2)} '
        '${baseUnitLabel.toUpperCase()}',
      );
    }
    final conversion = parts.join(' · ');
    return baseRate == null
        ? conversion
        : '$conversion '
              '(₹${moneyFormat.format(baseRate)}/${baseUnitLabel.toUpperCase()})';
  }

  String _compactNumber(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value
            .toStringAsFixed(3)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
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
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.cool400),
          ),
        );
      }
      return Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('material-image-$name'),
          onTap: () => AppImagePreviewDialog.show(
            context,
            imageProvider: FileImage(file),
          ),
          borderRadius: BorderRadius.circular(6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
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

class _MeasureField extends StatefulWidget {
  const _MeasureField({
    required this.fieldKey,
    required this.labelKey,
    required this.label,
    required this.value,
    required this.unit,
    required this.onChanged,
    this.hint,
    this.required = false,
    this.bluetoothTarget = false,
    this.onBluetoothTap,
    this.textInputAction = TextInputAction.next,
  });

  final Key fieldKey;
  final Key labelKey;
  final String label;
  final String value;
  final String unit;
  final String? hint;
  final ValueChanged<String> onChanged;
  final bool required;
  final bool bluetoothTarget;
  final VoidCallback? onBluetoothTap;
  final TextInputAction textInputAction;

  @override
  State<_MeasureField> createState() => _MeasureFieldState();
}

class _MeasureFieldState extends State<_MeasureField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _MeasureField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != widget.value &&
        !_focusNode.hasFocus) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text.rich(
        key: widget.labelKey,
        TextSpan(
          text: widget.label,
          children: widget.required
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
          key: widget.fieldKey,
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          keyboardType: AppKeyboards.decimal,
          textInputAction: widget.textInputAction,
          inputFormatters: AppInputFormatters.quantity(),
          style: AppTextStyles.regularB7_14,
          decoration: InputDecoration(
            hintText:
                widget.hint ??
                (widget.required && widget.value.isEmpty ? '123.00' : '---'),
            hintStyle: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.cool600,
            ),
            prefixIcon: Center(
              child: Text(widget.unit, style: AppTextStyles.semiboldH8_16),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 42,
              maxWidth: 42,
            ),
            contentPadding: const EdgeInsets.only(right: 8),
            suffixIcon: widget.onBluetoothTap == null
                ? null
                : IconButton(
                    key: ValueKey(
                      'verified-weight-bluetooth-${widget.fieldKey}',
                    ),
                    tooltip: 'Use live Bluetooth weight for this item',
                    onPressed: widget.onBluetoothTap,
                    icon: Icon(
                      widget.bluetoothTarget
                          ? Icons.bluetooth_connected_rounded
                          : Icons.bluetooth_rounded,
                      size: 20,
                      color: widget.bluetoothTarget
                          ? AppColors.primary500
                          : AppColors.neutral500,
                    ),
                  ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cool400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cool400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary500),
            ),
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
    borderRadius: BorderRadius.circular(12),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: selected ? AppColors.primary500 : AppColors.cool400,
        ),
        borderRadius: BorderRadius.circular(12),
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
          ),
          const SizedBox(width: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.semiboldH8_16,
          ),
        ],
      ),
    ),
  );
}
