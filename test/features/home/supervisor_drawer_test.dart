import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:eerl_app/features/dashboard/provider/dashboard_navigation_provider.dart';
import 'package:eerl_app/features/home/widgets/home_drawer.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  late String databasePath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(await getDatabasesPath(), 'home_drawer_test.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.syncMeta, {
      'key': 'user_name',
      'value': 'Live User',
    });
    await database.insert(DatabaseTables.syncMeta, {
      'key': 'user_photo_url',
      'value': 'assets/images/profile_rahul_patel.png',
    });
    await database.insert(DatabaseTables.myRoles, {
      'role_key': 'AGENT',
      'role_name': 'Collection Agent',
      'modules': '[]',
    });
    await database.insert(DatabaseTables.myRoles, {
      'role_key': 'SUPERVISOR',
      'role_name': 'MRF Supervisor',
      'modules': '[]',
    });
    final profile = await EerlLocalRepository.instance.getProfile();
    expect(profile.userName, 'Live User');
    final roles = await EerlLocalRepository.instance.getRoles();
    expect(roles, hasLength(2));
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  testWidgets('shows Transfer Requests only in the supervisor drawer', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DashboardNavigationProvider(
          initialRole: DashboardUserRole.supervisor,
          initialPageKey: 'home',
        ),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeDrawer(
            profileOverride: ProfileModel(
              userName: 'Live User',
              userPhotoUrl: 'assets/images/profile_rahul_patel.png',
            ),
            rolesOverride: [
              MyRoleModel(
                roleKey: 'SUPERVISOR',
                roleName: 'MRF Supervisor',
                modules: [],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('drawer-supervisor-transfer-requests')),
      findsOneWidget,
    );
    expect(find.text('Transfer Requests'), findsOneWidget);
    expect(find.text('Live User'), findsOneWidget);
    expect(find.text('MRF Supervisor'), findsOneWidget);
  });

  testWidgets('agent drawer uses live profile and common ragpicker icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DashboardNavigationProvider(
          initialRole: DashboardUserRole.collectionAgent,
          initialPageKey: 'home',
        ),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeDrawer(
            profileOverride: ProfileModel(
              userName: 'Live User',
              userPhotoUrl: 'assets/images/profile_rahul_patel.png',
            ),
            rolesOverride: [
              MyRoleModel(
                roleKey: 'AGENT',
                roleName: 'Collection Agent',
                modules: [],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Live User'), findsOneWidget);
    expect(find.text('Collection Agent'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey(
          'drawer-item-icon-assets/icons/home/supervisor/drawer/ragpicker.svg',
        ),
      ),
      findsOneWidget,
    );
  });
}
