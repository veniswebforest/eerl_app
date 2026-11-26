import 'package:pickup_supervisor/features/cash_payments/model/cash_payments_models.dart';

/// Mock data until Cash & Payments is backed by SQLite.
abstract final class CashPaymentsMockData {
  static const paidThisWeek = 3100;

  /// "Today" for the Paid on field.
  static final today = DateTime(2026, 11, 24);

  static const payments = <PaymentActivity>[
    PaymentActivity(
      name: 'City Bakery',
      when: ActivityWhen(time: '11:40 AM'),
      amount: 1250,
      method: PayMethod.cash,
    ),
    PaymentActivity(
      name: 'Om Sweets',
      when: ActivityWhen(day: 'Sun 22 Nov', time: '05:10 PM'),
      amount: 300,
      method: PayMethod.upi,
      reference: '4402 1187',
    ),
    PaymentActivity(
      name: 'Krishna Traders',
      when: ActivityWhen(day: 'Sat 21 Nov', time: '12:15 PM'),
      amount: 1550,
      method: PayMethod.bank,
    ),
  ];

  static const cashRequests = <CashRequest>[
    CashRequest(
      title: 'Payments to 6 shops in Adajan',
      when: ActivityWhen(time: '10:30 AM'),
      amount: 5000,
      status: CashRequestStatus.waiting,
    ),
    CashRequest(
      title: 'Weekly payments, Vesu',
      when: ActivityWhen(day: 'Mon 23 Nov', time: '04:30 PM'),
      amount: 2000,
      asked: 2500,
      status: CashRequestStatus.added,
    ),
    CashRequest(
      title: 'Navratri event payments',
      when: ActivityWhen(day: 'Fri 20 Nov', time: '11:30 AM'),
      amount: 3000,
      officeNote: 'Use the cash you hold first.',
      status: CashRequestStatus.rejected,
    ),
  ];

  static const pointsToPay = <PickupPointToPay>[
    PickupPointToPay(
      name: 'Shree Sai Dairy',
      type: 'Mixed',
      rate: PayRate.perKg,
      rateAmount: 10,
      schedule: PaySchedule.weekly,
      weekday: 1,
      method: PayMethod.cash,
      owed: 1250,
      lastPaid: '16 Nov',
      due: '30 Nov',
    ),
    PickupPointToPay(
      name: 'Green Park Society',
      type: 'Mixed',
      rate: PayRate.fixed,
      rateAmount: 500,
      schedule: PaySchedule.weekly,
      weekday: 2,
      method: PayMethod.upi,
      owed: 500,
      due: '24 Nov',
      dueToday: true,
    ),
    PickupPointToPay(
      name: 'Om Sweets',
      type: 'Mixed',
      rate: PayRate.perKg,
      rateAmount: 8,
      schedule: PaySchedule.monthly30th,
      method: PayMethod.cash,
      owed: 960,
      due: '30 Nov',
    ),
    PickupPointToPay(
      name: 'Krishna Traders',
      type: 'Sorted',
      rate: PayRate.perItem,
      schedule: PaySchedule.monthlyLastDay,
      method: PayMethod.bank,
      owed: 1240,
      due: '30 Nov',
    ),
    PickupPointToPay(
      name: 'Laxmi Provision Store',
      type: 'Sorted',
      rate: PayRate.perKg,
      rateAmount: 12,
      schedule: PaySchedule.weekly,
      weekday: 6,
      method: PayMethod.cash,
      owed: 600,
      due: '28 Nov',
    ),
    PickupPointToPay(
      name: 'Mehta Medicals',
      type: 'Sorted',
      rate: PayRate.fixed,
      rateAmount: 300,
      schedule: PaySchedule.weekly,
      weekday: 1,
      method: PayMethod.upi,
      owed: 300,
      due: '30 Nov',
    ),
  ];

  /// Note and reference prefilled as in Figma, by payment method.
  static const cashNote = 'Paid at the shop to Ramesh Desai.';
  static const upiNote = 'Sent to the owner’s UPI number.';
  static const upiReference = '4402 1187 9930';
}
