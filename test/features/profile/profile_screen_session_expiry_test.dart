import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/providers/app_lock_provider.dart';
import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/features/profile/view/profile_screen.dart';
import 'package:eerl_app/features/profile/widgets/profile_assets.dart';
import 'package:eerl_app/features/profile/widgets/profile_info_card.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  late String databasePath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(
      await getDatabasesPath(),
      'profile_screen_session_expiry_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  testWidgets('displays formatted session expire time from stored auth session fallback', (
    tester,
  ) async {
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({
        AppConstants.sessionExpiresAtKey: '2026-10-26T14:30:00.000Z',
      });
      await database.clearDatabaseOnLogout();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => AppLockProvider()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // 14:30 UTC = 20:00 IST -> 26 Oct 2026, 08:00 PM
    expect(find.text('26 Oct 2026, 08:00 PM'), findsOneWidget);
  });

  testWidgets('displays formatted session expire time from sync_meta profile data', (
    tester,
  ) async {
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      await database.clearDatabaseOnLogout();
      await database.setSyncMeta(
        'session_expires_at',
        '2026-11-05T03:45:00.000Z',
      );
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => AppLockProvider()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // 03:45 UTC = 09:15 IST -> 05 Nov 2026, 09:15 AM
    expect(find.text('05 Nov 2026, 09:15 AM'), findsOneWidget);
  });

  testWidgets('profile screen renders role item with primary icon color', (
    tester,
  ) async {
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      await database.clearDatabaseOnLogout();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => AppLockProvider()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    final card = tester.widget<ProfileInfoCard>(find.byType(ProfileInfoCard));
    final roleItem = card.items.firstWhere((i) => i.icon == ProfileAssets.role);
    expect(roleItem.iconColor, AppColors.primary500);
  });
}
