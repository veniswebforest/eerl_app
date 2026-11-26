import 'package:flutter/foundation.dart';

/// How a pickup point was (or is) paid.
enum PayMethod { cash, upi, bank }

/// Where a cash request stands with the office.
enum CashRequestStatus { waiting, added, rejected }

/// A day shown as "Today" or as a date ("Mon 23 Nov").
class ActivityWhen {
  const ActivityWhen({required this.time, this.day});

  /// Null means today.
  final String? day;
  final String time;
}

/// A payment made to a pickup point (Payments tab).
class PaymentActivity {
  const PaymentActivity({
    required this.name,
    required this.when,
    required this.amount,
    required this.method,
    this.reference,
  });

  final String name;
  final ActivityWhen when;
  final int amount;
  final PayMethod method;
  final String? reference;
}

/// A request for cash from the office (Cash requests tab).
class CashRequest {
  const CashRequest({
    required this.title,
    required this.when,
    required this.amount,
    required this.status,
    this.asked,
    this.officeNote,
  });

  final String title;
  final ActivityWhen when;

  /// Amount added (or asked, while waiting / rejected).
  final int amount;
  final CashRequestStatus status;

  /// What was asked when the office sent a different amount.
  final int? asked;
  final String? officeNote;
}

/// How a pickup point's rate is worked out.
enum PayRate { perKg, fixed, perItem }

/// When a pickup point is paid.
enum PaySchedule { weekly, monthly30th, monthlyLastDay }

/// A pickup point that is owed money.
class PickupPointToPay {
  const PickupPointToPay({
    required this.name,
    required this.type,
    required this.rate,
    required this.schedule,
    required this.method,
    required this.owed,
    required this.due,
    this.rateAmount,
    this.weekday,
    this.lastPaid,
    this.dueToday = false,
  });

  final String name;

  /// "Sorted" / "Mixed".
  final String type;
  final PayRate rate;
  final int? rateAmount;
  final PaySchedule schedule;

  /// 1 = Monday … 7 = Sunday, for [PaySchedule.weekly].
  final int? weekday;
  final PayMethod method;
  final int owed;
  final String? lastPaid;

  /// "30 Nov" – the next payment day the server sends.
  final String due;
  final bool dueToday;
}

/// Static stand-in for the cash ledger until the backend lands: cash in
/// hand and the pickup points paid in this session.
abstract final class CashPaymentsStore {
  static const startingCash = 2450;

  static final cashInHand = ValueNotifier<int>(startingCash);

  /// Names of pickup points paid in this session (they leave the list).
  static final paid = ValueNotifier<Set<String>>({});

  static void recordPayment(String name, int amount) {
    cashInHand.value -= amount;
    paid.value = {...paid.value, name};
  }

  /// Back to the first-launch state (tests).
  static void reset() {
    cashInHand.value = startingCash;
    paid.value = {};
  }
}
