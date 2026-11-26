import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/utils/module_money.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/features/cash_payments/model/cash_payments_models.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Asset paths for Cash & Payments (PS-M08).
abstract final class CashPaymentsAssets {
  static const package = 'pickup_supervisor';
  static const _i = 'assets/icons/cash_payments';

  static const waiting = '$_i/status_waiting.svg';
  static const added = '$_i/status_added.svg';
  static const rejected = '$_i/status_rejected.svg';
  static const calendar = '$_i/calendar.svg';
  static const camera = 'assets/icons/driver_labour/camera_add.svg';
}

Widget cashIcon(String asset, double size) => SvgPicture.asset(
  asset,
  package: CashPaymentsAssets.package,
  width: size,
  height: size,
);

const _cardShadow = [
  BoxShadow(color: DriverColors.shadow, blurRadius: 5, offset: Offset(0, 2)),
];

BoxDecoration _card({Color? border, double radius = 12}) => BoxDecoration(
  color: DriverColors.neutral50,
  borderRadius: BorderRadius.circular(radius),
  border: border == null ? null : Border.all(color: border),
  boxShadow: border == null ? _cardShadow : null,
);

/// "Today • 10:30 AM" or "Mon 23 Nov • 04:30 PM".
String cashWhen(DriverLocalizations l10n, ActivityWhen w) =>
    l10n.cpWhen(w.day ?? l10n.cpToday, w.time);

/// "Per kg ₹10 · weekly on Monday · cash".
String payTerms(DriverLocalizations l10n, PickupPointToPay p) {
  final rate = switch (p.rate) {
    PayRate.perKg => l10n.cpPerKg(moduleRupees(p.rateAmount ?? 0)),
    PayRate.fixed => l10n.cpFixed(moduleRupees(p.rateAmount ?? 0)),
    PayRate.perItem => l10n.cpPerItem,
  };
  final schedule = switch (p.schedule) {
    PaySchedule.weekly => l10n.cpWeeklyOn(l10n.cpDayName('${p.weekday}')),
    PaySchedule.monthly30th => l10n.cpMonthly30th,
    PaySchedule.monthlyLastDay => l10n.cpMonthlyLastDay,
  };
  final method = switch (p.method) {
    PayMethod.cash => l10n.cpMethodCash,
    PayMethod.upi => l10n.cpMethodUpi,
    PayMethod.bank => l10n.cpMethodBank,
  };
  return l10n.cpTermsLine(rate, schedule, method);
}

/// Cash in hand | Paid this week, and Request cash.
class CashSummaryCard extends StatelessWidget {
  const CashSummaryCard({
    super.key,
    required this.cashInHand,
    required this.paidThisWeek,
    required this.onRequestCash,
  });

  final int cashInHand;
  final int paidThisWeek;
  final VoidCallback onRequestCash;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    Widget figure(String label, int value, String key) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DriverTextStyles.medium14.copyWith(
            color: DriverColors.neutral600,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            moduleRupees(value),
            key: Key(key),
            style: DriverTextStyles.bold16.copyWith(
              fontSize: 28,
              height: 32 / 28,
              color: DriverColors.backgroundColorDark,
            ),
          ),
        ),
      ],
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: figure(l10n.cpCashInHand, cashInHand, 'cash-in-hand'),
                ),
                const VerticalDivider(
                  width: 24,
                  thickness: 1,
                  color: DriverColors.cool300,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: figure(
                      l10n.cpPaidThisWeek,
                      paidThisWeek,
                      'paid-this-week',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: TextButton(
              key: const Key('cash-request-cash'),
              onPressed: onRequestCash,
              style: TextButton.styleFrom(
                backgroundColor: DriverColors.primary50,
                foregroundColor: DriverColors.primary500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n.cpRequestCash,
                style: DriverTextStyles.bold16.copyWith(
                  color: DriverColors.primary500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Green-outlined "Pickup points to pay" card with See who to pay.
class PointsToPayCard extends StatelessWidget {
  const PointsToPayCard({
    super.key,
    required this.count,
    required this.owed,
    required this.onTap,
  });

  final int count;
  final int owed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _card(border: DriverColors.primary500, radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cpPointsToPay,
            style: DriverTextStyles.semibold18.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.cpPointsOwed(count, moduleRupees(owed)),
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
          const SizedBox(height: 16),
          ModuleButton(
            key: const Key('cash-see-who-to-pay'),
            label: l10n.cpSeeWhoToPay,
            height: 52,
            radius: 14,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

/// Status pill on a cash request.
class CashStatusTag extends StatelessWidget {
  const CashStatusTag({super.key, required this.status});

  final CashRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final (label, icon, bg, fg, radius) = switch (status) {
      CashRequestStatus.waiting => (
        l10n.cpWaiting,
        CashPaymentsAssets.waiting,
        DriverColors.yellow50,
        DriverColors.yellow600,
        12.0,
      ),
      CashRequestStatus.added => (
        l10n.cpAdded,
        CashPaymentsAssets.added,
        DriverColors.primary100,
        DriverColors.primary500,
        8.0,
      ),
      CashRequestStatus.rejected => (
        l10n.cpRejected,
        CashPaymentsAssets.rejected,
        DriverColors.red50,
        DriverColors.red600,
        12.0,
      ),
    };
    return Container(
      height: 32,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Padding(
              // The warning triangle sits inside a 20px frame.
              padding: status == CashRequestStatus.rejected
                  ? const EdgeInsets.symmetric(horizontal: 1, vertical: 2)
                  : EdgeInsets.zero,
              child: SvgPicture.asset(
                icon,
                package: CashPaymentsAssets.package,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DriverTextStyles.semibold12.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grey method pill on a payment ("Cash", "UPI · ref 4402 1187").
class CashMethodTag extends StatelessWidget {
  const CashMethodTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: DriverColors.tagGrey,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: DriverTextStyles.medium12.copyWith(color: DriverColors.pdfMuted),
    ),
  );
}

/// A recent-activity card: title, when, an optional note, amount and tag.
class CashActivityCard extends StatelessWidget {
  const CashActivityCard({
    super.key,
    required this.title,
    required this.when,
    required this.amount,
    required this.amountColor,
    required this.tag,
    this.note,
  });

  final String title;
  final String when;
  final String? note;
  final String amount;
  final Color amountColor;
  final Widget tag;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: _card(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: DriverTextStyles.semibold16.copyWith(
            color: DriverColors.neutral950,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          when,
          style: DriverTextStyles.medium14.copyWith(
            color: DriverColors.neutral800,
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 8),
          Text(
            note!,
            style: DriverTextStyles.medium12.copyWith(
              fontSize: 13,
              color: DriverColors.neutral600,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              amount,
              style: DriverTextStyles.semibold18.copyWith(color: amountColor),
            ),
            tag,
          ],
        ),
      ],
    ),
  );
}

/// A pickup point owed money, with its next due day.
class PointToPayCard extends StatelessWidget {
  const PointToPayCard({super.key, required this.point, required this.onTap});

  final PickupPointToPay point;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final owed = moduleRupees(point.owed);
    return DecoratedBox(
      decoration: _card(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.cpPointTitle(point.name, point.type),
                        style: DriverTextStyles.semibold16.copyWith(
                          color: DriverColors.neutral950,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DueTag(
                      label: point.dueToday
                          ? l10n.cpFilterDueToday
                          : l10n.cpDueOn(point.due),
                      today: point.dueToday,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  payTerms(l10n, point),
                  style: DriverTextStyles.medium12.copyWith(
                    fontSize: 13,
                    color: DriverColors.neutral700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  point.lastPaid == null
                      ? l10n.cpOwed(owed)
                      : l10n.cpOwedLastPaid(owed, point.lastPaid!),
                  style: DriverTextStyles.medium12.copyWith(
                    fontSize: 13,
                    color: DriverColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DueTag extends StatelessWidget {
  const _DueTag({required this.label, required this.today});

  final String label;
  final bool today;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: today ? DriverColors.flagAmberTile : DriverColors.tagGrey,
      borderRadius: BorderRadius.circular(48),
    ),
    child: Text(
      label,
      style: DriverTextStyles.semibold12.copyWith(
        color: today ? DriverColors.amber800 : DriverColors.pdfMuted,
      ),
    ),
  );
}
