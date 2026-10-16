import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/profile/model/logout_data_status.dart';
import 'package:eerl_app/features/profile/widgets/logout_confirmation_dialog.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('syncs every pending entry before allowing logout', (
    tester,
  ) async {
    var pendingCount = 2;
    var syncCalls = 0;
    var loggedOut = false;

    Future<SyncStatusModel> loadStatus() async => SyncStatusModel(
      queuedCount: pendingCount,
      sendingCount: 0,
      failedCount: 0,
      waitingPhotoCount: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LogoutConfirmationDialog(
            dataStatus: LogoutDataStatus.pending,
            pendingCount: pendingCount,
            loadSyncStatus: loadStatus,
            syncPendingEntries: () async {
              syncCalls++;
              pendingCount = syncCalls == 1 ? 1 : 0;
            },
            onYes: () => loggedOut = true,
          ),
        ),
      ),
    );

    expect(find.text('2 item(s) pending sync'), findsOneWidget);

    await tester.tap(find.byKey(const Key('logout-yes-button')));
    await tester.pumpAndSettle();

    expect(syncCalls, 1);
    expect(loggedOut, isFalse);
    expect(find.text('1 item(s) pending sync'), findsOneWidget);
    expect(find.byKey(const Key('logout-sync-error')), findsOneWidget);

    await tester.tap(find.byKey(const Key('logout-yes-button')));
    await tester.pumpAndSettle();

    expect(syncCalls, 2);
    expect(loggedOut, isTrue);
  });
}
