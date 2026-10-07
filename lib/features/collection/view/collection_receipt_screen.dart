import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:go_router/go_router.dart';

class CollectionReceiptScreen extends StatefulWidget {
  const CollectionReceiptScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  State<CollectionReceiptScreen> createState() =>
      _CollectionReceiptScreenState();
}

class _CollectionReceiptScreenState extends State<CollectionReceiptScreen> {
  final GlobalKey _receiptBoundaryKey = GlobalKey();
  _ReceiptAction? _activeAction;

  late final LocalQueryController<
    ({
      CollectionModel? collection,
      List<CollectionItemModel> items,
      String? supervisorName,
    })
  >
  _controller;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(() async {
      final repository = EerlLocalRepository.instance;
      final collection = await repository.getCollection(widget.collectionId);
      if (collection == null) {
        return (
          collection: null,
          items: const <CollectionItemModel>[],
          supervisorName: null,
        );
      }
      final items = await repository.getCollectionItems(collection.id);
      String? supervisorName = collection.verifiedByName;
      if (collection.mrfPersonId != null) {
        final people = await repository.getMrfPeople(
          centerId: collection.centerId,
          activeOnly: false,
        );
        for (final person in people) {
          if (person.id == collection.mrfPersonId) {
            supervisorName = person.name;
            break;
          }
        }
      }
      return (
        collection: collection,
        items: items,
        supervisorName: supervisorName,
      );
    })..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Uint8List> _captureReceiptImage() async {
    await WidgetsBinding.instance.endOfFrame;
    final boundary = _receiptBoundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) {
      throw StateError('The collection slip is not ready to capture.');
    }

    // Keep the shared image sharp without allowing unusually long receipts to
    // allocate an excessive bitmap.
    const maxPixels = 12000000.0;
    final maxRatioForSize = math.sqrt(
      maxPixels / (boundary.size.width * boundary.size.height),
    );
    final pixelRatio = math.min(3.0, math.max(1.0, maxRatioForSize));
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('The collection slip image could not be created.');
      }
      return byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
    } finally {
      image.dispose();
    }
  }

  Future<void> _shareReceipt(
    BuildContext shareContext,
    CollectionModel collection,
  ) => _runReceiptAction(_ReceiptAction.share, () async {
    final imageBytes = await _captureReceiptImage();
    if (!mounted || !shareContext.mounted) return;
    final renderBox = shareContext.findRenderObject();
    final shareOrigin = renderBox is RenderBox && renderBox.hasSize
        ? renderBox.localToGlobal(Offset.zero) & renderBox.size
        : null;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(imageBytes, mimeType: 'image/png')],
        fileNameOverrides: ['${_receiptFileName(collection)}.png'],
        title: context.l10n.collectionShareSlip,
        subject: collection.slipNumber ?? collection.id,
        sharePositionOrigin: shareOrigin,
      ),
    );
  });

  Future<void> _printReceipt(CollectionModel collection) =>
      _runReceiptAction(_ReceiptAction.print, () async {
        final imageBytes = await _captureReceiptImage();
        await Printing.layoutPdf(
          name: '${_receiptFileName(collection)}.pdf',
          onLayout: (PdfPageFormat format) async {
            final document = pw.Document();
            final image = pw.MemoryImage(imageBytes);
            document.addPage(
              pw.Page(
                pageFormat: format,
                margin: const pw.EdgeInsets.all(12),
                build: (_) =>
                    pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
              ),
            );
            return document.save();
          },
        );
      });

  Future<void> _runReceiptAction(
    _ReceiptAction action,
    Future<void> Function() operation,
  ) async {
    if (_activeAction != null) return;
    setState(() => _activeAction = action);
    try {
      await operation();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.collectionSlipActionError)),
        );
      }
    } finally {
      if (mounted) setState(() => _activeAction = null);
    }
  }

  String _receiptFileName(CollectionModel collection) {
    final identifier = collection.slipNumber ?? collection.id;
    final safeIdentifier = identifier.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]+'),
      '-',
    );
    return 'collection-slip-$safeIdentifier';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && !_controller.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = _controller.data;
          final collection = data?.collection;
          if (_controller.error != null || collection == null) {
            return Center(
              child: TextButton(
                onPressed: _controller.load,
                child: const Text('Retry'),
              ),
            );
          }
          return _content(
            context,
            collection,
            data!.items,
            data.supervisorName,
          );
        },
      ),
    ),
  );

  Widget _content(
    BuildContext context,
    CollectionModel collection,
    List<CollectionItemModel> items,
    String? supervisorName,
  ) {
    final timestamp = collection.collectedAt ?? collection.updatedAt;
    final parsedTimestamp = DateTime.tryParse(timestamp)?.toLocal();
    final unitTotals = _unitTotals(items);
    final itemAmounts = items.map(_itemAmount).whereType<double>().toList();
    final totalAmount = itemAmounts.fold<double>(
      0,
      (total, amount) => total + amount,
    );
    final channel = collection.channel.trim().toUpperCase();
    final isMrf = channel == 'MRF';
    final givenBy = collection.handedOverBy ?? collection.givenByName;

    return SingleChildScrollView(
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
                    onTap: () => Navigator.of(context).maybePop(),
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
              RepaintBoundary(
                key: _receiptBoundaryKey,
                child: Container(
                  key: const Key('collection-receipt-content'),
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
                        collection.slipNumber ?? collection.id,
                      ),
                      _receiptRow(
                        context.l10n.collectionReceiptDate,
                        parsedTimestamp == null
                            ? timestamp
                            : DateFormat('dd MMM yyyy').format(parsedTimestamp),
                      ),
                      if (parsedTimestamp != null)
                        _receiptRow(
                          context.l10n.collectionReceiptTime,
                          DateFormat('hh:mm a').format(parsedTimestamp),
                        ),
                      _receiptRow(
                        context.l10n.collectionReceiptCenter,
                        collection.centerName ?? collection.centerId,
                      ),
                      _receiptRow(
                        context.l10n.collectionReceiptAgent,
                        collection.agentName,
                      ),
                      _receiptRow(
                        context.l10n.collectionDetailType,
                        collection.channel,
                      ),
                      if (isMrf && _hasText(supervisorName))
                        _receiptRow(
                          context.l10n.collectionReceiptSupervisor,
                          supervisorName!,
                        ),
                      if (isMrf && _hasText(collection.givenByName))
                        _receiptRow(
                          context.l10n.collectionReceiptLabor,
                          collection.givenByName!,
                        ),
                      if (!isMrf && _hasText(givenBy))
                        _receiptRow(context.l10n.collectionGivenBy, givenBy!),
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
                      if (items.isEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(context.l10n.dashboardEmptyMessage),
                        )
                      else
                        for (var index = 0; index < items.length; index++) ...[
                          _receiptItem(context, items[index]),
                          if (index != items.length - 1)
                            const _ReceiptDivider(),
                        ],
                      for (final entry in unitTotals.entries) ...[
                        const _ReceiptDivider(),
                        _quantityBlock(
                          context,
                          _unitBlockTitle(context, entry.key),
                          _quantityValue(entry.value.collected, entry.key),
                          _quantityValue(entry.value.verified, entry.key),
                          _quantityValue(
                            entry.value.verified - entry.value.collected,
                            entry.key,
                            signed: true,
                          ),
                        ),
                      ],
                      if (itemAmounts.isNotEmpty) ...[
                        const _ReceiptDivider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.collectionReceiptTotal,
                              style: AppTextStyles.mediumSH6_18,
                            ),
                            Text(
                              _money(totalAmount),
                              style: AppTextStyles.mediumSH6_18.copyWith(
                                color: AppColors.primary500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const _ReceiptDivider(),
                      Text(
                        context.l10n.collectionReceiptAgent,
                        style: AppTextStyles.mediumSH9_12.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        collection.agentName,
                        style: AppTextStyles.mediumSH8_14,
                      ),
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
                    child: Builder(
                      builder: (shareContext) => OutlinedButton(
                        key: const Key('collection-share-slip'),
                        onPressed: _activeAction == null
                            ? () => _shareReceipt(shareContext, collection)
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _receiptActionIcon(
                              action: _ReceiptAction.share,
                              asset: 'assets/icons/collection/share_slip.svg',
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(context.l10n.collectionShareSlip),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      key: const Key('collection-print-slip'),
                      onPressed: _activeAction == null
                          ? () => _printReceipt(collection)
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _receiptActionIcon(
                            action: _ReceiptAction.print,
                            asset: 'assets/icons/collection/print_slip.svg',
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('collection-receipt-back-home'),
                  onPressed: () => context.go(AppRoutes.home),
                  child: Text(context.l10n.collectionBackToHome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptActionIcon({
    required _ReceiptAction action,
    required String asset,
  }) {
    if (_activeAction == action) {
      return const SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return SvgPicture.asset(asset, width: 24, height: 24);
  }

  Map<String, _UnitTotals> _unitTotals(List<CollectionItemModel> items) {
    final totals = <String, _UnitTotals>{};
    for (final item in items) {
      final unit = _unitCode(item);
      final current = totals[unit] ?? const _UnitTotals();
      totals[unit] = _UnitTotals(
        collected: current.collected + item.qty,
        verified: current.verified + (item.verifiedQty ?? item.qty),
      );
    }
    return totals;
  }

  Widget _receiptRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
        const SizedBox(width: 24),
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
    String collected,
    String verified,
    String difference,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTextStyles.semiboldH9_14),
      const SizedBox(height: 8),
      _receiptRow(context.l10n.collectionReceiptCollectedTotal, collected),
      _receiptRow(context.l10n.collectionReceiptVerifiedTotal, verified),
      _receiptRow(context.l10n.collectionReceiptDifference, difference),
    ],
  );

  Widget _receiptItem(BuildContext context, CollectionItemModel item) {
    final unit = _unitCode(item);
    final verified = item.verifiedQty ?? item.qty;
    final amount = _itemAmount(item);
    final detail = item.rate == null
        ? '${_number(verified)} $unit'
        : '${_number(verified)} $unit × ${_money(item.rate!)}/$unit';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? item.itemId,
                    style: AppTextStyles.mediumSH8_14,
                  ),
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
            if (amount != null) ...[
              const SizedBox(width: 12),
              Text(_money(amount), style: AppTextStyles.regularB7_14),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _quantity(
                context.l10n.collectionCollected,
                unit,
                _number(item.qty),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _quantity(
                context.l10n.expenseVerified,
                unit,
                _number(verified),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quantity(String label, String unit, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.regularB8_12),
      const SizedBox(height: 4),
      Text('$unit   $value', style: AppTextStyles.regularB7_14),
    ],
  );

  String _unitCode(CollectionItemModel item) {
    final code = item.unitCode?.trim().toUpperCase();
    if (code != null && code.isNotEmpty) return code;
    final name = item.unitName?.trim();
    return name == null || name.isEmpty ? '-' : name;
  }

  String _unitBlockTitle(BuildContext context, String unit) => switch (unit) {
    'KG' => context.l10n.collectionReceiptKgBlock,
    'PCS' || 'PC' || 'PIECE' => context.l10n.collectionReceiptPcsBlock,
    _ => unit,
  };

  String _quantityValue(double value, String unit, {bool signed = false}) {
    final prefix = signed && value > 0 ? '+' : '';
    return '$prefix${_number(value)} $unit';
  }

  String _number(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);

  String _money(double value) => NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  ).format(value);

  double? _itemAmount(CollectionItemModel item) {
    if (item.amount != null) return item.amount;
    final rate = item.rate;
    return rate == null ? null : rate * (item.verifiedQty ?? item.qty);
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}

enum _ReceiptAction { share, print }

class _UnitTotals {
  const _UnitTotals({this.collected = 0, this.verified = 0});

  final double collected;
  final double verified;
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
