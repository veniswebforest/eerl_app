import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/utils/module_date_format.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/core/widgets/module_header.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_mock_data.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_models.dart';
import 'package:pickup_supervisor/features/collection_report/widgets/collection_report_pdf_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M01 Collection report · PDF preview, opened from Share on the report.
///
/// The server makes the real PDF for the chosen period; this static preview
/// shows its layout. [onSharePdf] is where the phone's share sheet (WhatsApp,
/// Save to Files) is opened once the PDF file is available.
class CollectionReportPdfScreen extends StatelessWidget {
  const CollectionReportPdfScreen({
    super.key,
    required this.period,
    required this.data,
    this.onSharePdf,
  });

  final ReportPeriod period;
  final CollectionReportData data;
  final VoidCallback? onSharePdf;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: Builder(
      builder: (context) {
        final l10n = DriverLocalizations.of(context);
        return Scaffold(
          key: const Key('collection-report-pdf-screen'),
          backgroundColor: DriverColors.background,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ModuleHeader(
                        title: l10n.rpPdfTitle,
                        subtitle: l10n.rpPdfSubtitle(
                          l10n.rangeLabel(data.range),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _PdfViewer(
                            hint: l10n.rpPdfPageHint,
                            page: ReportPdfPage(
                              data: data,
                              period: period,
                              supervisorName:
                                  CollectionReportMockData.supervisorName,
                              madeAt: CollectionReportMockData.madeAt,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ModuleButton(
                        key: const Key('report-share-pdf'),
                        label: l10n.rpSharePdf,
                        height: 52,
                        onPressed: onSharePdf ?? () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// Grey viewer holding the page, scaled to the available width, with
/// pinch-to-zoom and a page hint underneath.
class _PdfViewer extends StatelessWidget {
  const _PdfViewer({required this.page, required this.hint});

  final Widget page;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: DriverColors.pdfViewer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ClipRect(
              child: InteractiveViewer(
                key: const Key('report-pdf-viewer'),
                maxScale: 4,
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) => Center(
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                          child: page,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: DriverTextStyles.medium12.copyWith(
              fontSize: 11,
              color: DriverColors.pdfMuted,
            ),
          ),
        ],
      ),
    );
  }
}
