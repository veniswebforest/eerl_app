import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/requests/view/request_detail_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'closed request renders fresh local-table values without dummies',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const initial = RequestModel(
        id: 'request-1',
        createdBy: 'agent-1',
        createdByName: 'Old value',
        body: 'Old request body',
        priority: 'NORMAL',
        status: 'OPEN',
        photoUrls: [],
        createdAt: '2026-10-29T04:00:00.000Z',
        syncState: 'synced',
      );
      const stored = RequestModel(
        id: 'request-1',
        createdBy: 'agent-1',
        createdByName: 'Kiran Rathod',
        body: 'Please calibrate the weighing scale before the next collection.',
        priority: 'HIGH',
        status: 'CLOSED',
        answer: 'Scale calibrated with a 10 kg standard weight.',
        answeredAt: '2026-10-28T06:00:00.000Z',
        photoUrls: ['/tmp/agent-proof.jpg'],
        answerPhotoUrls: ['/tmp/resolution-proof.jpg'],
        createdAt: '2026-10-28T04:00:00.000Z',
        syncState: 'synced',
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RequestDetailScreen(
            request: initial,
            detailLoader: (_) async => stored,
            answerPhotoLoader: (_) async => stored.answerPhotoUrls,
            requestPhotoLoader: (_) async => stored.photoUrls,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Completed:'), findsOneWidget);
      expect(
        find.text('Scale calibrated with a 10 kg standard weight.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Please calibrate the weighing scale before the next collection.',
        ),
        findsOneWidget,
      );
      expect(find.text('•  Kiran Rathod'), findsNWidgets(2));
      expect(find.text('Rahul Patel'), findsNothing);
      expect(
        find.textContaining('Review and verify the latest collection entry'),
        findsNothing,
      );
      expect(find.byKey(const Key('request-detail-photo-0')), findsNWidgets(2));
    },
  );
}
