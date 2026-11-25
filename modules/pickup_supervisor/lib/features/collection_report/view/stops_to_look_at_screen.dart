import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/utils/module_date_format.dart';
import 'package:pickup_supervisor/core/widgets/module_count_chip.dart';
import 'package:pickup_supervisor/core/widgets/module_header.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_mock_data.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_models.dart';
import 'package:pickup_supervisor/features/collection_report/widgets/collection_report_text.dart';
import 'package:pickup_supervisor/features/collection_report/widgets/look_at_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M01 Stops to look at: Missed, Cancelled and 0 kg pickup points for a
/// period. Opens from the home tiles and from the report's last section; the
/// pills switch between the three outcomes.
class StopsToLookAtScreen extends StatelessWidget {
  const StopsToLookAtScreen({
    super.key,
    required this.data,
    this.initialOutcome = LookAtOutcome.missed,
  });

  final CollectionReportData data;
  final LookAtOutcome initialOutcome;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: _StopsToLookAtView(data: data, initialOutcome: initialOutcome),
  );
}

class _StopsToLookAtView extends StatefulWidget {
  const _StopsToLookAtView({required this.data, required this.initialOutcome});

  final CollectionReportData data;
  final LookAtOutcome initialOutcome;

  @override
  State<_StopsToLookAtView> createState() => _StopsToLookAtViewState();
}

class _StopsToLookAtViewState extends State<_StopsToLookAtView> {
  late LookAtOutcome _outcome = widget.initialOutcome;

  int _count(LookAtOutcome o) =>
      widget.data.lookAt.firstWhere((r) => r.outcome == o).count;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final all = CollectionReportMockData.lookAtStops[_outcome]!;
    final stops = all.take(min(_count(_outcome), all.length)).toList();
    return Scaffold(
      key: const Key('stops-to-look-at-screen'),
      backgroundColor: DriverColors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                ModuleHeader(
                  title: l10n.rpStopsToLook,
                  subtitle: l10n.rangeLabel(widget.data.range),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final o in LookAtOutcome.values)
                      ModuleCountChip(
                        key: Key('look-at-tab-${o.name}'),
                        horizontalPadding: 10,
                        label: l10n.outcomeTabLabel(o),
                        count: l10n.number(_count(o)),
                        selected: o == _outcome,
                        onTap: () => setState(() => _outcome = o),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (stops.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      l10n.lkEmpty,
                      textAlign: TextAlign.center,
                      style: DriverTextStyles.medium14.copyWith(
                        color: DriverColors.neutral600,
                      ),
                    ),
                  ),
                for (final (i, s) in stops.indexed) ...[
                  if (i > 0) const SizedBox(height: 16),
                  LookAtStopCard(stop: s, outcome: _outcome),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
