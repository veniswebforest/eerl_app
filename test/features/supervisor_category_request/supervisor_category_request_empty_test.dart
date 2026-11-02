import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/supervisor_category_request/view/supervisor_category_request_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
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
      'supervisor_category_request_empty_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.insert(DatabaseTables.myCenters, {
      'center_id': 'center-1',
      'is_primary': 1,
      'slip_last_count': 0,
    });
    await database.setSyncMeta('active_center_id', 'center-1');
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  testWidgets('matches the Figma empty category-request state', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SupervisorCategoryRequestScreen(
          onBack: () {},
          loadRequests: () async => const [],
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Add Category Request'), findsOneWidget);
    expect(find.text('Pending (0)'), findsOneWidget);
    expect(find.text('Closed (0)'), findsOneWidget);
    expect(find.text('No Category Request to Review'), findsOneWidget);
    expect(
      find.byKey(const Key('supervisor-category-request-empty-state')),
      findsOneWidget,
    );
    final illustration = find.descendant(
      of: find.byKey(const Key('supervisor-category-request-empty-state')),
      matching: find.byType(SvgPicture),
    );
    expect(illustration, findsOneWidget);
    final illustrationSize = tester.getSize(illustration);
    expect(illustrationSize.width, closeTo(200.135, 0.01));
    expect(illustrationSize.height, 200);
    expect(tester.takeException(), isNull);
  });
}
