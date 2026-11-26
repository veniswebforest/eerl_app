import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/core/utils/module_money.dart';
import 'package:pickup_supervisor/features/cash_payments/model/cash_payments_mock_data.dart';
import 'package:pickup_supervisor/features/cash_payments/model/cash_payments_models.dart';
import 'package:pickup_supervisor/features/cash_payments/view/cash_payments_screen.dart';
import 'package:pickup_supervisor/features/cash_payments/view/pay_point_screen.dart';
import 'package:pickup_supervisor/features/cash_payments/view/points_to_pay_screen.dart';
import 'package:pickup_supervisor/features/cash_payments/view/request_cash_screen.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('packages/pickup_supervisor/Manrope');
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/font/Manrope-$w.ttf'));
    }
    await loader.load();
  });

  setUp(CashPaymentsStore.reset);

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    Locale? locale,
    Size size = const Size(375, 1300),
    double textScale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('en'), Locale('gu'), Locale('hi')],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: home,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  test('rupees use Indian grouping', () {
    expect(moduleRupees(4850), '₹4,850');
    expect(moduleRupees(125000), '₹1,25,000');
    expect(moduleRupees(300, sign: '−'), '−₹300');
  });

  testWidgets('Cash & Payments shows cash requests, then payments', (
    tester,
  ) async {
    await pump(tester, const CashPaymentsScreen());
    for (final t in [
      'Cash & Payments',
      '₹2,450',
      '₹3,100',
      'Request cash',
      '6 are owed ₹4,850 in all. Pay them from your cash in hand.',
      'Payments to 6 shops in Adajan',
      'Today • 10:30 AM',
      'Waiting for the office',
      'You asked for ₹2,500. The office sent ₹2,000.',
      'Added to your cash',
      'Office: “Use the cash you hold first.”',
      'Rejected by the office',
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    await tap(tester, find.byKey(const Key('cash-activity-0')));
    for (final t in [
      'City Bakery',
      '−₹1,250',
      'UPI · ref 4402 1187',
      'Bank transfer',
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
  });

  testWidgets('Request cash sends and returns', (tester) async {
    await pump(tester, const CashPaymentsScreen());
    await tap(tester, find.byKey(const Key('cash-request-cash')));
    expect(find.byType(RequestCashScreen), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('request-cash-amount')),
      '5000',
    );
    await tap(tester, find.byKey(const Key('request-cash-send')));
    expect(find.text('Request sent'), findsNothing);
    await tester.enterText(
      find.byKey(const Key('request-cash-reason')),
      'Payments to 6 shops in Adajan this week.',
    );
    await tester.pump();
    await tap(tester, find.byKey(const Key('request-cash-send')));
    expect(find.text('Request sent'), findsOneWidget);
    expect(find.textContaining('Your request for ₹5,000'), findsOneWidget);
    await tap(tester, find.text('Back to Cash & Payments'));
    expect(find.byType(RequestCashScreen), findsNothing);
    expect(find.byKey(const Key('cash-payments-screen')), findsOneWidget);
  });

  testWidgets('pay Shree Sai Dairy: it leaves the list and cash drops', (
    tester,
  ) async {
    await pump(tester, const CashPaymentsScreen());
    await tap(tester, find.byKey(const Key('cash-see-who-to-pay')));
    expect(find.byType(PointsToPayScreen), findsOneWidget);
    expect(find.text('₹4,850 owed · you hold ₹2,450'), findsOneWidget);
    expect(find.text('Shree Sai Dairy · Mixed'), findsOneWidget);
    expect(find.text('Per kg ₹10 · weekly on Monday · cash'), findsOneWidget);
    expect(find.text('Owed ₹1,250 · last paid 16 Nov'), findsOneWidget);
    await tap(tester, find.byKey(const Key('points-filter-due-today')));
    expect(find.text('Green Park Society · Mixed'), findsOneWidget);
    expect(find.text('Shree Sai Dairy · Mixed'), findsNothing);
    await tap(tester, find.byKey(const Key('points-filter-all')));

    await tap(tester, find.byKey(const Key('point-to-pay-0')));
    expect(find.byType(PayPointScreen), findsOneWidget);
    expect(find.text('Pay Shree Sai Dairy'), findsOneWidget);
    expect(find.text('Today, 24 Nov 2026'), findsOneWidget);
    expect(find.byKey(const Key('pay-point-reference')), findsNothing);
    await tap(tester, find.byKey(const Key('pay-method-upi')));
    expect(find.text('Reference (UPI or bank)'), findsOneWidget);
    await tap(tester, find.byKey(const Key('pay-point-record')));
    expect(find.text('Payment recorded'), findsOneWidget);
    expect(
      find.text('₹1,250 to Shree Sai Dairy. You now hold ₹1,200.'),
      findsOneWidget,
    );
    await tap(tester, find.text('Back to pickup points to pay'));
    expect(find.byType(PayPointScreen), findsNothing);
    expect(find.text('₹3,600 owed · you hold ₹1,200'), findsOneWidget);
    expect(find.text('Shree Sai Dairy · Mixed'), findsNothing);
    expect(find.text('5'), findsOneWidget);

    await tap(tester, find.byKey(const Key('module-back-button')));
    expect(find.text('₹1,200'), findsOneWidget);
  });

  testWidgets('cannot pay more than owed', (tester) async {
    await pump(
      tester,
      PayPointScreen(point: CashPaymentsMockData.pointsToPay.first),
    );
    await tester.enterText(find.byKey(const Key('pay-point-amount')), '2000');
    await tester.pump();
    await tap(tester, find.byKey(const Key('pay-point-record')));
    expect(find.text('Payment recorded'), findsNothing);
  });

  for (final locale in const [Locale('gu'), Locale('hi')]) {
    testWidgets('cash screens use ${locale.languageCode}', (tester) async {
      for (final screen in [
        const CashPaymentsScreen(),
        const RequestCashScreen(),
        const PointsToPayScreen(),
        PayPointScreen(point: CashPaymentsMockData.pointsToPay.first),
      ]) {
        await pump(tester, screen, locale: locale);
        for (final t in [
          'Cash & Payments',
          'Send request',
          'Pickup points to pay',
          'Record payment',
        ]) {
          expect(find.text(t), findsNothing, reason: t);
        }
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('cash screens fit a small phone with large text', (tester) async {
    for (final screen in [
      const CashPaymentsScreen(),
      const RequestCashScreen(),
      const PointsToPayScreen(),
      PayPointScreen(point: CashPaymentsMockData.pointsToPay.first),
    ]) {
      await pump(tester, screen, size: const Size(320, 568), textScale: 1.3);
      expect(tester.takeException(), isNull);
    }
  });
}
