import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/features/dashboard/view/main_dashboard_screen.dart';
import 'package:eerl_app/features/profile/widgets/sync_data_dialog.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('Home Sync Now opens the shared profile sync flow', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home-sync-now-button')));
    await tester.pumpAndSettle();
    expect(find.byType(SyncDataDialog), findsOneWidget);
    expect(find.text('Sync Offline Data'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('sync-now-button')));
    await tester.pumpAndSettle();
    expect(find.text('Data Already Synced'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
