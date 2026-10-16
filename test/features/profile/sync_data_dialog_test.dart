import 'dart:async';

import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/profile/model/sync_data_status.dart';
import 'package:eerl_app/features/profile/widgets/sync_data_dialog.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows success as soon as the outgoing queue is drained', (
    tester,
  ) async {
    final backgroundRefresh = Completer<void>();
    var syncCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SyncDataDialog(
            initialStatus: SyncDataStatus.pending,
            pendingCount: 1,
            hasInternetAccess: () async => true,
            syncPendingEntries: () async => syncCalls++,
            loadSyncStatus: () async => const SyncStatusModel(
              queuedCount: 0,
              sendingCount: 0,
              failedCount: 0,
              waitingPhotoCount: 0,
            ),
            refreshAfterSync: () => backgroundRefresh.future,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('sync-now-button')));
    await tester.pump();
    await tester.pump();

    expect(syncCalls, 1);
    expect(backgroundRefresh.isCompleted, isFalse);
    expect(find.byKey(const Key('sync-dialog-success')), findsOneWidget);
    expect(find.text('Data Synced Successfully'), findsOneWidget);
    expect(find.byKey(const ValueKey('sync-back-button')), findsOneWidget);

    backgroundRefresh.complete();
  });
}
