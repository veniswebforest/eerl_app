import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';

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
    final calculatedAmount = itemAmounts.fold<double>(
      0,
      (total, amount) => total + amount,
    );
    final totalAmount = collection.totalAmount ?? calculatedAmount;
    final channel = collection.channel.trim().toUpperCase();
    final isMrf = channel == 'MRF';
    final givenBy =
        collection.givenByName ?? (!isMrf ? collection.handedOverBy : null);
    final labor = isMrf ? collection.handedOverBy : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    key: const Key('collection-receipt-back'),
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 14),
              _printerStatus(context),
              const SizedBox(height: 8),
              RepaintBoundary(
                key: _receiptBoundaryKey,
                child: _receiptCard(
                  context: context,
                  collection: collection,
                  items: items,
                  unitTotals: unitTotals,
                  totalAmount: totalAmount,
                  timestamp: timestamp,
                  parsedTimestamp: parsedTimestamp,
                  isMrf: isMrf,
                  supervisorName: supervisorName,
                  givenBy: givenBy,
                  labor: labor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.collectionPrinterHint,
                textAlign: TextAlign.center,
                style: AppTextStyles.mediumSH9_12.copyWith(
                  color: AppColors.cool600,
                ),
              ),
              const SizedBox(height: 28),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _printerStatus(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.cool300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.bluetooth,
            size: 14,
            color: AppColors.primary500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${context.l10n.collectionPrinterReady}: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: context.l10n.collectionPrinterConnected),
              ],
            ),
            style: _receiptText(size: 10, color: AppColors.neutral950),
          ),
        ),
      ],
    ),
  );

  Widget _receiptCard({
    required BuildContext context,
    required CollectionModel collection,
    required List<CollectionItemModel> items,
    required Map<String, _UnitTotals> unitTotals,
    required double totalAmount,
    required String timestamp,
    required DateTime? parsedTimestamp,
    required bool isMrf,
    required String? supervisorName,
    required String? givenBy,
    required String? labor,
  }) => Container(
    key: const Key('collection-receipt-content'),
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.cool300),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [HomeStyles.cardShadow],
    ),
    child: Column(
      children: [
        Container(height: 6, color: AppColors.neutral950),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Column(
            children: [
              Image.asset(
                'assets/images/collection_detail/eer_logo.png',
                width: 141,
                height: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.cool300),
              const SizedBox(height: 7),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _receiptLabelValue(
                      context.l10n.collectionReceiptId.replaceAll(':', ''),
                      collection.slipNumber ?? collection.id,
                    ),
                  ),
                  Expanded(
                    child: _receiptLabelValue(
                      context.l10n.collectionReceiptDateTime,
                      parsedTimestamp == null
                          ? timestamp
                          : DateFormat(
                              'dd MMM yyyy, hh:mm a',
                            ).format(parsedTimestamp),
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              const Divider(height: 1, color: AppColors.cool300),
              const SizedBox(height: 8),
              _receiptMetaGrid(
                context: context,
                collection: collection,
                isMrf: isMrf,
                supervisorName: supervisorName,
                givenBy: givenBy,
                labor: labor,
              ),
              const SizedBox(height: 8),
              _dashedLine(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.collectionReceiptBreakdown.toUpperCase(),
                      style: _receiptText(size: 10, weight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    context.l10n.collectionItemsCount(items.length),
                    style: _receiptText(size: 9, color: AppColors.neutral600),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    context.l10n.dashboardEmptyMessage,
                    style: _receiptText(size: 10),
                  ),
                )
              else
                for (final item in items) ...[
                  _receiptItem(context, item),
                  const SizedBox(height: 6),
                ],
              Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: context.l10n.collectionReceiptAggregateSummary,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text:
                            ' (${context.l10n.collectionReceiptAggregateHint})',
                      ),
                    ],
                  ),
                  style: _receiptText(size: 9, color: AppColors.neutral600),
                ),
              ),
              const SizedBox(height: 6),
              for (final entry in unitTotals.entries) ...[
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
                  entry.key,
                ),
                const SizedBox(height: 6),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.collectionReceiptPaymentBy,
                    style: _receiptText(size: 10),
                  ),
                  Text(
                    _paymentLabel(context, collection.paidBy),
                    style: _receiptText(size: 11, weight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.cool400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.collectionReceiptTotalSettlement,
                        style: _receiptText(size: 12, weight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      _money(totalAmount),
                      style: _receiptText(size: 18, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _dashedLine(),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
          child: Column(
            children: [
              Text(
                '${context.l10n.collectionReceiptCollectedAgent}: ${collection.agentName}',
                style: _receiptText(size: 9, color: AppColors.neutral600),
              ),
              const SizedBox(height: 5),
              Text(
                context.l10n.collectionThankYou,
                style: _receiptText(size: 10, weight: FontWeight.w700),
              ),
              Text(
                context.l10n.collectionSystemGeneratedSlip.toUpperCase(),
                style: _receiptText(size: 7, color: AppColors.neutral600),
              ),
              const SizedBox(height: 4),
              SvgPicture.asset(
                'assets/icons/collection/receipt_dots.svg',
                width: 38,
                height: 4,
              ),
            ],
          ),
        ),
      ],
    ),
  );

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

  TextStyle _receiptText({
    double size = 10,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.neutral950,
  }) => TextStyle(
    fontFamily: 'Manrope',
    fontSize: size,
    height: 1.25,
    fontWeight: weight,
    color: color,
  );

  Widget _receiptLabelValue(
    String label,
    String value, {
    bool alignEnd = false,
  }) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        style: _receiptText(size: 8, color: AppColors.neutral600),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        style: _receiptText(size: 11, weight: FontWeight.w700),
      ),
    ],
  );

  Widget _receiptMetaGrid({
    required BuildContext context,
    required CollectionModel collection,
    required bool isMrf,
    required String? supervisorName,
    required String? givenBy,
    required String? labor,
  }) {
    final cells = <({String label, String value, bool chip})>[
      (
        label: context.l10n.collectionReceiptCenter.replaceAll(':', ''),
        value: collection.centerName ?? collection.centerId,
        chip: false,
      ),
      (
        label: context.l10n.collectionReceiptAgent,
        value: collection.agentName,
        chip: false,
      ),
      (
        label: context.l10n.collectionDetailType,
        value: collection.channel,
        chip: true,
      ),
      if (isMrf && _hasText(supervisorName))
        (
          label: context.l10n.collectionReceiptSupervisor.replaceAll(':', ''),
          value: supervisorName!,
          chip: false,
        ),
      if (_hasText(givenBy))
        (label: context.l10n.collectionGivenBy, value: givenBy!, chip: false),
      if (_hasText(labor))
        (
          label: context.l10n.collectionReceiptLaborInvolved,
          value: labor!,
          chip: false,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 7,
          children: [
            for (final cell in cells)
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cell.label,
                      style: _receiptText(size: 9, color: AppColors.neutral600),
                    ),
                    const SizedBox(height: 1),
                    if (cell.chip)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cool100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          cell.value.toUpperCase(),
                          style: _receiptText(size: 9, weight: FontWeight.w600),
                        ),
                      )
                    else
                      Text(
                        cell.value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _receiptText(size: 11, weight: FontWeight.w700),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _dashedLine() => DottedBorder(
    options: const RectDottedBorderOptions(
      color: AppColors.cool400,
      dashPattern: [3, 3],
      padding: EdgeInsets.zero,
    ),
    child: const SizedBox(width: double.infinity, height: 0),
  );

  Widget _quantityBlock(
    BuildContext context,
    String title,
    String collected,
    String verified,
    String difference,
    String unit,
  ) => Container(
    padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: _receiptText(size: 11, weight: FontWeight.w600),
              ),
            ),
            Text(
              unit == 'KG'
                  ? context.l10n.collectionReceiptWeight
                  : context.l10n.collectionReceiptPieces,
              style: _receiptText(size: 7, color: AppColors.neutral600),
            ),
          ],
        ),
        const Divider(height: 8, color: AppColors.cool300),
        Row(
          children: [
            Expanded(
              child: _summaryValue(context.l10n.collectionCollected, collected),
            ),
            const SizedBox(height: 34, child: VerticalDivider(width: 1)),
            Expanded(
              child: _summaryValue(context.l10n.expenseVerified, verified),
            ),
            const SizedBox(height: 34, child: VerticalDivider(width: 1)),
            Expanded(
              child: _summaryValue(
                context.l10n.collectionReceiptDifference,
                difference,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _summaryValue(String label, String value) => Column(
    children: [
      Text(label, style: _receiptText(size: 8, color: AppColors.neutral500)),
      const SizedBox(height: 4),
      Text(
        value,
        textAlign: TextAlign.center,
        style: _receiptText(size: 10, weight: FontWeight.w700),
      ),
    ],
  );

  Widget _receiptItem(BuildContext context, CollectionItemModel item) {
    final unit = _unitCode(item);
    final verified = item.verifiedQty ?? item.qty;
    final amount = _itemAmount(item);
    final detail = item.rate == null
        ? '${_number(verified)} $unit'
        : '${_number(verified)} $unit × ${_money(item.rate!)}';
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
      decoration: BoxDecoration(
        color: AppColors.cool50,
        border: Border.all(color: AppColors.cool300),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 3, right: 7),
                decoration: const BoxDecoration(
                  color: AppColors.neutral950,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: item.name ?? item.itemId,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: '  $detail',
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  style: _receiptText(size: 10),
                ),
              ),
              if (amount != null) ...[
                const SizedBox(width: 8),
                Text(
                  _money(amount),
                  style: _receiptText(size: 12, weight: FontWeight.w700),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _quantity(
                  context.l10n.collectionCollected,
                  unit,
                  _number(item.qty),
                ),
              ),
              const SizedBox(width: 6),
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
      ),
    );
  }

  Widget _quantity(String label, String unit, String value) => Container(
    height: 19,
    padding: const EdgeInsets.symmetric(horizontal: 7),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            '$label:',
            overflow: TextOverflow.ellipsis,
            style: _receiptText(size: 8, color: AppColors.neutral500),
          ),
        ),
        Text(
          '$value $unit',
          style: _receiptText(size: 8, weight: FontWeight.w600),
        ),
      ],
    ),
  );

  String _paymentLabel(BuildContext context, String? paidBy) {
    final value = paidBy?.trim().toUpperCase();
    if (value == 'UPI') return context.l10n.collectionPaymentUpi;
    return context.l10n.collectionPaymentCash;
  }

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
