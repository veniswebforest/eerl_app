import 'package:eerl_app/features/home/widgets/online_status_banner.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows pending outbox entries in the subtitle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: OnlineStatusBanner(pendingCount: 3, onSyncNowTap: () {}),
        ),
      ),
    );

    expect(find.text('3 item(s) pending sync'), findsOneWidget);
    expect(find.byKey(const Key('home-sync-now-button')), findsOneWidget);
    expect(find.text('3 collection pending'), findsNothing);
  });
}
