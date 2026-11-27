import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
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
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: OutboundLiveBuilder<_LiveCash>(
      load: _LiveCash.load,
      fallback: _CashView(initialTab: initialTab),
      builder: (context, cash, _) =>
          _CashView(initialTab: initialTab, live: cash),
    ),
  );
}

/// Cash in hand, what pickup points are owed, payments and cash requests
/// from SQLite (outbound doc, Pickup Supervisor screens · Cash & Payments).
class _LiveCash {
  const _LiveCash({
    required this.cashInHand,
    required this.paidThisWeek,
    required this.owedCount,
    required this.owed,
    required this.payments,
    required this.requests,
  });

  final int cashInHand;
  final int paidThisWeek;
  final int owedCount;
  final int owed;
  final List<PaymentActivity> payments;
  final List<CashRequest> requests;

  static ActivityWhen _when(String? iso, String today) {
    final at = DateTime.tryParse(iso ?? '');
    if (at == null) return const ActivityWhen(time: '');
    final ist = at.toUtc().add(const Duration(hours: 5, minutes: 30));
    final day =
        '${ist.year}-${ist.month.toString().padLeft(2, '0')}-'
        '${ist.day.toString().padLeft(2, '0')}';
    final hour = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
    final time =
        '$hour:${ist.minute.toString().padLeft(2, '0')} '
        '${ist.hour < 12 ? 'AM' : 'PM'}';
    return ActivityWhen(time: time, day: day == today ? null : day);
  }

  static Future<_LiveCash> load(OutboundLiveSession session) async {
    final q = session.queries;
    final today = session.clock.today;
    final weekStart = session.clock.weekStart;
    final dues = await q.sourceDues();
    final owing = dues.where((d) => ((d['balance'] as num?) ?? 0) > 0);
    final payments = await q.sourcePayments();
    return _LiveCash(
      cashInHand: (await q.cashInHand()).round(),
      paidThisWeek: payments
          .where(
            (p) => (p['paid_on'] as String? ?? '').compareTo(weekStart) >= 0,
          )
          .fold<num>(0, (sum, p) => sum + ((p['amount'] as num?) ?? 0))
          .round(),
      owedCount: owing.length,
      owed: owing
          .fold<num>(0, (sum, d) => sum + ((d['balance'] as num?) ?? 0))
          .round(),
      payments: [
        for (final p in payments)
          PaymentActivity(
            name: p['source_name'] as String? ?? '',
            when: ActivityWhen(
              time: '',
              day: p['paid_on'] == today ? null : p['paid_on'] as String?,
            ),
            amount: ((p['amount'] as num?) ?? 0).round(),
            method: switch (p['method']) {
              'UPI' => PayMethod.upi,
              'BANK' => PayMethod.bank,
              _ => PayMethod.cash,
            },
            reference: p['reference'] as String?,
          ),
      ],
      requests: [
        for (final r in await q.cashRequests())
          CashRequest(
            title: r['reason'] as String? ?? '',
            when: _when(r['created_at'] as String?, today),
            amount: (((r['approved_amount'] ?? r['amount']) as num?) ?? 0)
                .round(),
            status: switch (r['status']) {
              'APPROVED' => CashRequestStatus.added,
              'REJECTED' => CashRequestStatus.rejected,
              _ => CashRequestStatus.waiting,
            },
            asked:
                r['approved_amount'] != null &&
                    r['approved_amount'] != r['amount']
                ? ((r['amount'] as num?) ?? 0).round()
                : null,
            officeNote: r['rejection_reason'] as String?,
          ),
      ],
    );
  }
}

class _CashView extends StatefulWidget {
  const _CashView({required this.initialTab, this.live});

  final CashActivityTab initialTab;

  /// Live figures; null shows the design samples.
  final _LiveCash? live;

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
        final live = widget.live;
        final owedPoints = CashPaymentsMockData.pointsToPay
            .where((p) => !CashPaymentsStore.paid.value.contains(p.name))
            .toList();
        final int owed =
            live?.owed ?? owedPoints.fold<int>(0, (sum, p) => sum + p.owed);
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
                cashInHand:
                    live?.cashInHand ?? CashPaymentsStore.cashInHand.value,
                paidThisWeek:
                    live?.paidThisWeek ?? CashPaymentsMockData.paidThisWeek,
                onRequestCash: () => _push(const RequestCashScreen()),
              ),
              const SizedBox(height: 24),
              PointsToPayCard(
                count: live?.owedCount ?? owedPoints.length,
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
    for (final p in widget.live?.payments ?? CashPaymentsMockData.payments)
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
    for (final r in widget.live?.requests ?? CashPaymentsMockData.cashRequests)
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
