import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/utils/module_date_format.dart';
import 'package:pickup_supervisor/core/utils/module_money.dart';
import 'package:pickup_supervisor/core/widgets/module_count_chip.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/features/cash_payments/model/cash_payments_mock_data.dart';
import 'package:pickup_supervisor/features/cash_payments/model/cash_payments_models.dart';
import 'package:pickup_supervisor/features/cash_payments/view/pay_point_screen.dart';
import 'package:pickup_supervisor/features/cash_payments/widgets/cash_form_widgets.dart';
import 'package:pickup_supervisor/features/cash_payments/widgets/cash_payments_widgets.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_directory_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Pickup points to pay ("See who to pay"). "Due" is the next payment day
/// the server sends; what is owed carries over. Paid points leave the list.
class PointsToPayScreen extends StatelessWidget {
  const PointsToPayScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const DriverLocalizationScope(child: _PointsView());
}

class _PointsView extends StatefulWidget {
  const _PointsView();

  @override
  State<_PointsView> createState() => _PointsViewState();
}

class _PointsViewState extends State<_PointsView> {
  final _search = TextEditingController();
  bool _dueToday = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([
        CashPaymentsStore.cashInHand,
        CashPaymentsStore.paid,
      ]),
      builder: (context, _) {
        final owedPoints = CashPaymentsMockData.pointsToPay
            .where((p) => !CashPaymentsStore.paid.value.contains(p.name))
            .toList();
        final owed = owedPoints.fold(0, (sum, p) => sum + p.owed);
        final query = _search.text.trim().toLowerCase();
        final shown = owedPoints
            .where((p) => !_dueToday || p.dueToday)
            .where((p) => query.isEmpty || p.name.toLowerCase().contains(query))
            .toList();
        return ModulePage(
          key: const Key('points-to-pay-screen'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CashFormHeader(
                title: l10n.cpPointsToPay,
                subtitle: l10n.cpOwedHold(
                  moduleRupees(owed),
                  moduleRupees(CashPaymentsStore.cashInHand.value),
                ),
              ),
              const SizedBox(height: 16),
              DriverLabourSearchField(
                hint: l10n.cpSearchHint,
                controller: _search,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ModuleCountChip(
                    key: const Key('points-filter-all'),
                    horizontalPadding: 10,
                    label: l10n.cpFilterAll,
                    count: l10n.number(owedPoints.length),
                    selected: !_dueToday,
                    onTap: () => setState(() => _dueToday = false),
                  ),
                  ModuleCountChip(
                    key: const Key('points-filter-due-today'),
                    horizontalPadding: 10,
                    label: l10n.cpFilterDueToday,
                    count: l10n.number(
                      owedPoints.where((p) => p.dueToday).length,
                    ),
                    selected: _dueToday,
                    onTap: () => setState(() => _dueToday = true),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: shown.isEmpty
                    ? Center(
                        child: Text(
                          l10n.cpNothingToPay,
                          style: DriverTextStyles.medium14.copyWith(
                            color: DriverColors.neutral600,
                          ),
                        ),
                      )
                    : ModuleSideBleed(
                        child: ListView.separated(
                          key: const Key('points-to-pay-list'),
                          clipBehavior: Clip.none,
                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                          itemCount: shown.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (_, i) => PointToPayCard(
                            key: Key('point-to-pay-$i'),
                            point: shown[i],
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => PayPointScreen(point: shown[i]),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
