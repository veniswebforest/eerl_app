import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/notifications/widgets/notification_list_card.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('labels notifications that belong to another role', (
    tester,
  ) async {
    const item = NotificationModel(
      id: 'notification-1',
      type: 'TASK',
      title: 'New task',
      role: 'SUPERVISOR',
      forRoleName: 'Supervisor',
      otherRole: true,
      createdAt: '2026-10-20T08:00:00.000Z',
      syncState: 'synced',
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: NotificationListCard(
            items: const [item],
            timeFor: (_) => '10:00 AM',
          ),
        ),
      ),
    );

    expect(find.text('For your Supervisor role'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('notification-role-notification-1')),
      findsOneWidget,
    );
  });
}
