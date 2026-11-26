import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/utils/module_money.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/widgets/module_segmented_switch.dart';
import 'package:pickup_supervisor/features/cash_payments/model/cash_payments_mock_data.dart';
import 'package:pickup_supervisor/features/cash_payments/model/cash_payments_models.dart';
import 'package:pickup_supervisor/features/cash_payments/view/points_to_pay_screen.dart';
import 'package:pickup_supervisor/features/cash_payments/view/request_cash_screen.dart';
import 'package:pickup_supervisor/features/cash_payments/widgets/cash_payments_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Which list Recent activity shows.
enum CashActivityTab { payments, cashRequests }

/// PS-M08 Cash & Payments (drawer › Cash & payments): cash in hand, pickup
/// points to pay, and recent payments / cash requests.
class CashPaymentsScreen extends StatelessWidget {
  const CashPaymentsScreen({
    super.key,
    this.initialTab = CashActivityTab.cashRequests,
  });

  final CashActivityTab initialTab;

  @override
  Widget build(BuildContext context) =>
      DriverLocalizationScope(child: _CashView(initialTab: initialTab));
}

class _CashView extends StatefulWidget {
  const _CashView({required this.initialTab});

  final CashActivityTab initialTab;

  @override
  State<_CashView> createState() => _CashViewState();
}

class _CashViewState extends State<_CashView> {
  late CashActivityTab _tab = widget.initialTab;

  void _push(Widget screen) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));

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
        return ModulePage(
          key: const Key('cash-payments-screen'),
          child: ListView(
            clipBehavior: Clip.none,
            padding: EdgeInsets.zero,
            children: [
              Row(
                children: [
                  const ModuleBackButton(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.cpTitle,
                      style: DriverTextStyles.semibold20.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CashSummaryCard(
                cashInHand: CashPaymentsStore.cashInHand.value,
                paidThisWeek: CashPaymentsMockData.paidThisWeek,
                onRequestCash: () => _push(const RequestCashScreen()),
              ),
              const SizedBox(height: 24),
              PointsToPayCard(
                count: owedPoints.length,
                owed: owed,
                onTap: () => _push(const PointsToPayScreen()),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.cpRecentActivity,
                style: DriverTextStyles.semibold18.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
              const SizedBox(height: 16),
              ModuleSegmentedSwitch(
                keyPrefix: 'cash-activity',
                labels: [l10n.cpPaymentsTab, l10n.cpCashRequestsTab],
                selectedIndex: _tab.index,
                onChanged: (i) =>
                    setState(() => _tab = CashActivityTab.values[i]),
              ),
              const SizedBox(height: 16),
              ...(_tab == CashActivityTab.payments
                      ? _payments(l10n)
                      : _requests(l10n))
                  .expand((w) => [w, const SizedBox(height: 12)]),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _payments(DriverLocalizations l10n) => [
    for (final p in CashPaymentsMockData.payments)
      CashActivityCard(
        title: p.name,
        when: cashWhen(l10n, p.when),
        amount: moduleRupees(p.amount, sign: '−'),
        amountColor: DriverColors.neutral950,
        tag: CashMethodTag(
          label: switch (p.method) {
            PayMethod.cash => l10n.cpTagCash,
            PayMethod.upi => l10n.cpTagUpiRef(p.reference ?? ''),
            PayMethod.bank => l10n.cpTagBank,
          },
        ),
      ),
  ];

  List<Widget> _requests(DriverLocalizations l10n) => [
    for (final r in CashPaymentsMockData.cashRequests)
      CashActivityCard(
        title: r.title,
        when: cashWhen(l10n, r.when),
        note: r.asked != null
            ? l10n.cpAskedSent(moduleRupees(r.asked!), moduleRupees(r.amount))
            : r.officeNote == null
            ? null
            : l10n.cpOfficeSaid(r.officeNote!),
        amount: moduleRupees(r.amount, sign: '+'),
        amountColor: switch (r.status) {
          CashRequestStatus.waiting => DriverColors.yellow600,
          CashRequestStatus.added => DriverColors.primary500,
          CashRequestStatus.rejected => DriverColors.neutral400,
        },
        tag: CashStatusTag(status: r.status),
      ),
  ];
}
