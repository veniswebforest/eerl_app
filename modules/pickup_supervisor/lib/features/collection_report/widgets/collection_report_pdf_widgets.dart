import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/utils/module_date_format.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_models.dart';
import 'package:pickup_supervisor/features/collection_report/widgets/collection_report_text.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Design width of the PDF page; the page is scaled to fit the screen.
const reportPdfPageWidth = 311.0;

TextStyle _pdf(TextStyle base, double size, Color color) =>
    base.copyWith(fontSize: size, height: 1.37, color: color);

/// A4-like preview of the collection report PDF (static mock of what the
/// server generates).
class ReportPdfPage extends StatelessWidget {
  const ReportPdfPage({
    super.key,
    required this.data,
    required this.period,
    required this.supervisorName,
    required this.madeAt,
  });

  final CollectionReportData data;
  final ReportPeriod period;
  final String supervisorName;
  final DateTime madeAt;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(madeAt));
    return Container(
      width: reportPdfPageWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: const BoxDecoration(
        color: DriverColors.neutral50,
        boxShadow: [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.rpCompany,
            style: _pdf(DriverTextStyles.bold12, 7.5, DriverColors.primary500),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.rpTitle,
            style: _pdf(DriverTextStyles.bold12, 13, DriverColors.neutral950),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.rpPdfSupervisor(
              supervisorName,
              l10n.periodName(period),
              l10n.rangeLabel(data.range),
            ),
            style: _pdf(DriverTextStyles.medium12, 6.5, DriverColors.pdfMuted),
          ),
          const SizedBox(height: 8),
          const _Rule(),
          const SizedBox(height: 8),
          Text(
            l10n.supervisorCollected,
            style: _pdf(DriverTextStyles.medium12, 6.5, DriverColors.pdfMuted),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.totalText(data),
            style: _pdf(DriverTextStyles.bold12, 12, DriverColors.neutral950),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.rpPdfSummary(
              l10n.number(data.due),
              l10n.number(data.collected),
              l10n.number(data.zeroKg),
              l10n.number(data.missed),
              l10n.number(data.cancelled),
            ),
            style: _pdf(DriverTextStyles.medium12, 6.5, DriverColors.pdfMuted),
          ),
          const SizedBox(height: 8),
          _PdfTable(
            title: l10n.rpByRoute,
            header: [
              l10n.rpColRoute,
              l10n.rpColVehicle,
              l10n.rpColStops,
              l10n.rpColCollected,
            ],
            rows: [
              for (final r in data.routes)
                [
                  r.name,
                  l10n.vehicleLabel(r.vehicle),
                  l10n.rpOf(l10n.number(r.done), l10n.number(r.total)),
                  l10n.kgText(r.kg),
                ],
            ],
          ),
          const SizedBox(height: 8),
          _PdfTable(
            title: l10n.rpByCategory,
            header: [l10n.rpColCategory, l10n.rpColStops, l10n.rpColCollected],
            rows: [
              for (final c in data.categories)
                [
                  l10n.categoryLabel(c.category),
                  l10n.number(c.stops),
                  l10n.kgText(c.kg),
                ],
            ],
          ),
          const SizedBox(height: 8),
          _PdfTable(
            title: l10n.rpStopsToLook,
            header: [
              l10n.rpColOutcome,
              l10n.rpColPickupPoints,
              l10n.rpColStops,
            ],
            rows: [
              for (final s in data.lookAt)
                [
                  l10n.outcomeLabel(s.outcome),
                  l10n.namesPlus(s),
                  l10n.number(s.count),
                ],
            ],
          ),
          const SizedBox(height: 8),
          const _Rule(),
          const SizedBox(height: 8),
          Text(
            l10n.rpPdfMade(l10n.dayMonthYear(madeAt), time),
            style: _pdf(DriverTextStyles.regular12, 6, DriverColors.pdfMuted),
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) =>
      Container(height: .75, color: DriverColors.pdfLine);
}

/// Section title and a table whose first column flexes and whose last column
/// is right-aligned and semibold.
class _PdfTable extends StatelessWidget {
  const _PdfTable({
    required this.title,
    required this.header,
    required this.rows,
  });

  final String title;
  final List<String> header;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final headStyle = _pdf(DriverTextStyles.medium12, 6, DriverColors.pdfMuted);
    final cellStyle = _pdf(
      DriverTextStyles.regular12,
      7,
      DriverColors.neutral950,
    );
    final lastStyle = _pdf(
      DriverTextStyles.semibold12,
      7,
      DriverColors.neutral950,
    );
    Widget row(List<String> cells, {required bool head}) => Container(
      padding: const EdgeInsets.symmetric(vertical: 3),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DriverColors.pdfLine, width: .5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, cell) in cells.indexed) ...[
            if (i > 0) const SizedBox(width: 6),
            if (i == 0)
              Expanded(child: Text(cell, style: head ? headStyle : cellStyle))
            else
              Text(
                cell,
                textAlign: i == cells.length - 1
                    ? TextAlign.right
                    : TextAlign.start,
                style: head
                    ? headStyle
                    : i == cells.length - 1
                    ? lastStyle
                    : cellStyle,
              ),
          ],
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: _pdf(DriverTextStyles.bold12, 8, DriverColors.neutral950),
        ),
        const SizedBox(height: 3),
        row(header, head: true),
        for (final r in rows) row(r, head: false),
      ],
    );
  }
}
