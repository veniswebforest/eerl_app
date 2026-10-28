import 'dart:async';

import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:eerl_app/features/home/view/home_screen.dart';
import 'package:eerl_app/features/dashboard/provider/dashboard_navigation_provider.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows the home loader while the first-login sync is pending', (
    tester,
  ) async {
    final sync = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => DashboardNavigationProvider(
                initialRole: DashboardUserRole.collectionAgent,
                initialPageKey: 'home',
              ),
            ),
            ChangeNotifierProvider.value(value: BootstrapSyncService.instance),
          ],
          child: HomeScreen(
            showInitialLoginLoader: true,
            initialLoginSync: () => sync.future,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('home-initial-login-loader')), findsOneWidget);
    expect(find.text('Syncing data...'), findsOneWidget);
    expect(find.byKey(const Key('loading-widget-message')), findsOneWidget);
    expect(find.byKey(const Key('loading-widget-subtitle')), findsOneWidget);
    expect(
      find.textContaining('your changes will sync automatically'),
      findsOneWidget,
    );
    final overlay = tester.widget<ColoredBox>(
      find.byKey(const Key('home-initial-login-loader-overlay')),
    );
    expect(overlay.color.a, closeTo(0.86, 0.01));
    expect(find.byKey(const Key('home-dashboard-scroll')), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    sync.complete();
    await tester.pump(const Duration(milliseconds: 500));
  });
}
