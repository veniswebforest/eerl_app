import 'dart:async';

import 'package:eerl_app/features/end_my_day/model/day_close_response.dart';
import 'package:eerl_app/features/end_my_day/view/end_my_day_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('syncs and clears outbox before loading day-close data', (
    tester,
  ) async {
    final events = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EndMyDayScreen(
          hasInternetAccess: () async => true,
          syncOutbox: () async => events.add('outbox'),
          pendingOutboxCount: () async {
            events.add('verify-empty');
            return 0;
          },
          loadData: () async {
            events.add('day-close');
            return _screenData(canClose: true);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(events, ['outbox', 'verify-empty', 'day-close']);
  });

  testWidgets('does not load day-close while an outbox entry remains', (
    tester,
  ) async {
    var dayCloseCalls = 0;
    var pendingChecks = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EndMyDayScreen(
          hasInternetAccess: () async => true,
          syncOutbox: () async {},
          pendingOutboxCount: () async => pendingChecks++ == 0 ? 1 : 0,
          loadData: () async {
            dayCloseCalls++;
            return _screenData(canClose: true);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(dayCloseCalls, 0);
    expect(find.textContaining('must sync before End My Day'), findsOneWidget);

    await tester.tap(find.byKey(const Key('end-day-retry')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(dayCloseCalls, 1);
    expect(find.byKey(const Key('confirm-end-my-day-button')), findsOneWidget);
  });

  testWidgets('displays day-close API values and server close state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EndMyDayScreen(
          hasInternetAccess: () async => true,
          now: () => DateTime(2026, 10, 19, 19),
          loadData: () async => const DayCloseScreenData(
            pendingSyncCount: 3,
            dayClose: DayCloseData(
              centerId: 'selected-center',
              date: '2026-10-19',
              lockTime: '18:30:00',
              canClose: false,
              blockedReason: 'BEFORE_LOCK_TIME',
              openDrafts: 1,
              summary: DayCloseSummary(
                wallet: DayCloseWalletSummary(
                  opening: 395437,
                  topUps: 0,
                  collectionPayments: 120,
                  expenses: 50,
                  closing: 395267,
                ),
                collections: DayCloseCollectionsSummary(
                  total: 2,
                  pendingReview: 1,
                  rejected: 0,
                  byUnit: [DayCloseCollectionUnit(unit: 'KG', quantity: 24.5)],
                ),
                expenses: DayCloseExpensesSummary(count: 1, amount: 50),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('₹ 3,95,437.00'), findsOneWidget);
    expect(find.text('₹ 50.00'), findsOneWidget);
    expect(find.text('₹ 120.00'), findsOneWidget);
    expect(find.byKey(const Key('end-day-blocked-reason')), findsOneWidget);
    final button = tester.widget<ElevatedButton>(
      find.byKey(const Key('confirm-end-my-day-button')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('keeps close button disabled before center EOD lock time', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EndMyDayScreen(
          hasInternetAccess: () async => true,
          now: () => DateTime(2026, 10, 19, 16, 29),
          loadData: () async =>
              _screenData(canClose: true, eodLockTime: '16:30:00'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(
      find.byKey(const Key('confirm-end-my-day-button')),
    );
    expect(button.onPressed, isNull);
    expect(find.textContaining('4:30 PM'), findsOneWidget);
  });

  testWidgets('enables close after center EOD lock when server allows it', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EndMyDayScreen(
          hasInternetAccess: () async => true,
          now: () => DateTime(2026, 10, 19, 16, 30),
          loadData: () async =>
              _screenData(canClose: true, eodLockTime: '16:30:00'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(
      find.byKey(const Key('confirm-end-my-day-button')),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('shows internet popup on open and skips the API loader', (
    tester,
  ) async {
    var loadCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EndMyDayScreen(
          hasInternetAccess: () async => false,
          loadData: () async {
            loadCalls++;
            return _screenData(canClose: true);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 0);
    expect(find.byKey(const Key('end-day-internet-dialog')), findsOneWidget);
    expect(find.text('No Internet Connection'), findsOneWidget);
  });

  testWidgets('automatically loads view when internet reconnects', (
    tester,
  ) async {
    final connectivityChanges = StreamController<void>.broadcast();
    addTearDown(connectivityChanges.close);
    var online = false;
    var loadCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EndMyDayScreen(
          hasInternetAccess: () async => online,
          connectivityChanges: connectivityChanges.stream,
          loadData: () async {
            loadCalls++;
            return _screenData(canClose: true);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 0);
    expect(find.byKey(const Key('end-day-internet-dialog')), findsOneWidget);

    online = true;
    connectivityChanges.add(null);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(loadCalls, 1);
    expect(find.byKey(const Key('end-day-internet-dialog')), findsNothing);
    expect(find.byKey(const Key('confirm-end-my-day-button')), findsOneWidget);
  });
}

DayCloseScreenData _screenData({required bool canClose, String? eodLockTime}) =>
    DayCloseScreenData(
      pendingSyncCount: 0,
      eodLockTime: eodLockTime,
      dayClose: DayCloseData(
        centerId: 'selected-center',
        date: '2026-10-19',
        lockTime: '18:00:00',
        canClose: canClose,
        openDrafts: 0,
        summary: const DayCloseSummary(
          wallet: DayCloseWalletSummary(
            opening: 100,
            topUps: 0,
            collectionPayments: 0,
            expenses: 0,
            closing: 100,
          ),
          collections: DayCloseCollectionsSummary(
            total: 0,
            pendingReview: 0,
            rejected: 0,
            byUnit: [],
          ),
          expenses: DayCloseExpensesSummary(count: 0, amount: 0),
        ),
      ),
    );
