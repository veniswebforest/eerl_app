import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/utils/module_date_format.dart';
import 'package:pickup_supervisor/core/widgets/module_date_range_sheet.dart';
import 'package:pickup_supervisor/core/widgets/module_header.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_mock_data.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_models.dart';
import 'package:pickup_supervisor/features/collection_report/view/collection_report_pdf_screen.dart';
import 'package:pickup_supervisor/features/collection_report/view/stops_to_look_at_screen.dart';
import 'package:pickup_supervisor/features/collection_report/widgets/collection_report_text.dart';
import 'package:pickup_supervisor/features/collection_report/widgets/collection_report_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M01 Collection report. Opens from Home › View full report, the
/// Collected tile, or Pick dates › Apply. The period pills switch the figures.
class CollectionReportScreen extends StatelessWidget {
  const CollectionReportScreen({
    super.key,
    this.initialPeriod = ReportPeriod.week,
    this.initialRange,
  });

  final ReportPeriod initialPeriod;

  /// Used when [initialPeriod] is [ReportPeriod.custom].
  final DateTimeRange? initialRange;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: _CollectionReportView(
      initialPeriod: initialPeriod,
      initialRange: initialRange,
    ),
  );
}

class _CollectionReportView extends StatefulWidget {
  const _CollectionReportView({
    required this.initialPeriod,
    required this.initialRange,
  });

  final ReportPeriod initialPeriod;
  final DateTimeRange? initialRange;

  @override
  State<_CollectionReportView> createState() => _CollectionReportViewState();
}

class _CollectionReportViewState extends State<_CollectionReportView> {
  late ReportPeriod _period = widget.initialPeriod;
  late DateTimeRange? _customRange = widget.initialRange;

  CollectionReportData get _data =>
      CollectionReportMockData.forPeriod(_period, customRange: _customRange);

  Future<void> _pickDates() async {
    final range = await showModuleDateRangeSheet(
      context,
      initialRange: _data.range,
      lastDate: CollectionReportMockData.today,
    );
    if (range == null || !mounted) return;
    setState(() {
      _period = ReportPeriod.custom;
      _customRange = range;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final data = _data;
    return Scaffold(
      key: const Key('collection-report-screen'),
      backgroundColor: DriverColors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              key: const Key('collection-report-scroll'),
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                ModuleHeader(
                  title: l10n.rpTitle,
                  subtitle: l10n.rangeLabel(data.range),
                  trailing: ReportShareButton(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CollectionReportPdfScreen(
                          period: _period,
                          data: data,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ReportPeriodChips(
                  selected: _period,
                  onSelected: (p) => setState(() => _period = p),
                  onPickDates: _pickDates,
                ),
                const SizedBox(height: 20),
                ReportTotalsCard(data: data, period: _period),
                const SizedBox(height: 20),
                ReportSectionCard(
                  title: l10n.rpByRoute,
                  rows: [
                    for (final r in data.routes)
                      ReportRow(
                        title: r.name,
                        subtitle: l10n.rpOfStops(
                          l10n.number(r.done),
                          l10n.number(r.total),
                        ),
                        tag: ReportVehicleTag(vehicle: r.vehicle),
                        value: l10n.kgText(r.kg),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                ReportSectionCard(
                  title: l10n.rpByCategory,
                  rows: [
                    for (final c in data.categories)
                      ReportRow(
                        title: l10n.categoryLabel(c.category),
                        subtitle: l10n.rpStops(l10n.number(c.stops)),
                        value: l10n.kgText(c.kg),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                ReportSectionCard(
                  title: l10n.rpStopsToLook,
                  rows: [
                    for (final s in data.lookAt)
                      ReportRow(
                        title: l10n.outcomeLabel(s.outcome),
                        subtitle: l10n.namesMore(s),
                        value: l10n.number(s.count),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => StopsToLookAtScreen(
                              data: data,
                              initialOutcome: s.outcome,
                            ),
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
    );
  }
}
