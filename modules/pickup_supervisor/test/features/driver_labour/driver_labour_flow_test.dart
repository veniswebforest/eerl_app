import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/driver_labour/model/driver_labour_mock_data.dart';
import 'package:pickup_supervisor/features/driver_labour/model/driver_labour_person.dart';
import 'package:pickup_supervisor/features/driver_labour/view/driver_labour_detail_screen.dart';
import 'package:pickup_supervisor/features/driver_labour/view/driver_labour_form_screen.dart';
import 'package:pickup_supervisor/features/driver_labour/view/driver_labour_directory_screen.dart';

void main() {
  Future<void> pumpDirectory(
    WidgetTester tester, {
    DriverLabourKind kind = DriverLabourKind.driver,
    bool active = true,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: DriverLabourDirectoryScreen(
          initialKind: kind,
          initialShowActive: active,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('driver directory lists drivers with counts and add button', (
    tester,
  ) async {
    await pumpDirectory(tester);
    expect(find.text('Driver Directory'), findsOneWidget);
    expect(find.text('Driver (12)'), findsOneWidget);
    expect(find.text('Labour (5)'), findsOneWidget);
    expect(find.text('Ramesh Bhai Patel'), findsOneWidget);
    expect(find.text('Add Driver'), findsOneWidget);
  });

  testWidgets('tab and filter switch to labour list and the empty state', (
    tester,
  ) async {
    await pumpDirectory(tester);
    await tester.tap(find.byKey(const Key('driver-labour-tab-1')));
    await tester.pumpAndSettle();
    expect(find.text('Labour Directory'), findsOneWidget);
    expect(find.text('Neel Prakash'), findsOneWidget);
    expect(find.text('--'), findsWidgets);
    expect(find.text('Add Labour'), findsOneWidget);

    await tester.tap(find.byKey(const Key('driver-labour-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inactive').last);
    await tester.pumpAndSettle();
    expect(find.text('No Details Found'), findsOneWidget);
    expect(find.text('Add labourer'), findsOneWidget);
  });

  testWidgets('search filters the list', (tester) async {
    await pumpDirectory(tester);
    await tester.enterText(
      find.byKey(const Key('driver-labour-search')),
      'umesh',
    );
    await tester.pumpAndSettle();
    expect(find.text('Umesh Yadav'), findsOneWidget);
    expect(find.text('Ramesh Bhai Patel'), findsNothing);
  });

  testWidgets('add driver form opens and cancels', (tester) async {
    await pumpDirectory(tester);
    await tester.tap(find.byKey(const Key('driver-labour-add')));
    await tester.pumpAndSettle();
    expect(find.text('Add New Driver'), findsOneWidget);
    expect(find.text('Capture Photo'), findsOneWidget);
    expect(find.text('Save & Select'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-labour-form-cancel')));
    await tester.pumpAndSettle();
    expect(find.text('Driver Directory'), findsOneWidget);
  });

  testWidgets('detail → deactivate → reactive shows both toasts', (
    tester,
  ) async {
    await pumpDirectory(tester);
    await tester.tap(find.byKey(const Key('driver-labour-person-0')));
    await tester.pumpAndSettle();
    expect(find.text('SUR-DRV-0089'), findsOneWidget);
    expect(find.text('Adajan Central Warehouse'), findsOneWidget);

    await tester.tap(find.byKey(const Key('driver-labour-deactivate')));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-labour-dialog-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Deactivated Successfully!'), findsOneWidget);
    expect(find.byKey(const Key('driver-labour-reactive')), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Deactivated Successfully!'), findsNothing);

    await tester.tap(find.byKey(const Key('driver-labour-reactive')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-labour-dialog-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Reactive Successfully!'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-labour-toast-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driver-labour-edit')), findsOneWidget);
  });

  testWidgets('edit opens prefilled form and photos can be removed', (
    tester,
  ) async {
    await pumpDirectory(tester);
    await tester.tap(find.byKey(const Key('driver-labour-person-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-labour-edit')));
    await tester.pumpAndSettle();
    expect(find.text('Edit Driver'), findsOneWidget);
    expect(find.text('Ramesh Bhai Patel'), findsOneWidget);
    final remove = find.byWidgetPredicate(
      (w) => w.key.toString().contains('driver-labour-remove-'),
    );
    expect(remove, findsNWidgets(2));
    await tester.tap(remove.first);
    await tester.pumpAndSettle();
    expect(remove, findsOneWidget);
  });

  testWidgets('labour detail has no warehouse card', (tester) async {
    await pumpDirectory(tester, kind: DriverLabourKind.labour);
    await tester.tap(find.byKey(const Key('driver-labour-person-0')));
    await tester.pumpAndSettle();
    expect(find.text('SCH-LAB-0090'), findsOneWidget);
    expect(find.text('Adajan Central Warehouse'), findsNothing);
  });

  for (final entry in {
    'gu': ['ડ્રાઇવર ડિરેક્ટરી', 'ડ્રાઇવર (12)', 'ડ્રાઇવર ઉમેરો'],
    'hi': ['ड्राइवर डायरेक्टरी', 'ड्राइवर (12)', 'ड्राइवर जोड़ें'],
  }.entries) {
    testWidgets('directory uses ${entry.key} localization', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(entry.key),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('en'), Locale('gu'), Locale('hi')],
          home: const DriverLabourDirectoryScreen(),
        ),
      );
      await tester.pumpAndSettle();
      for (final text in entry.value) {
        expect(find.text(text), findsOneWidget);
      }
    });
  }

  testWidgets('screens fit a small phone with large text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
    final person = DriverLabourMockData.activeDrivers.first;
    for (final screen in <Widget>[
      const DriverLabourDirectoryScreen(),
      const DriverLabourDirectoryScreen(
        initialKind: DriverLabourKind.labour,
        initialShowActive: false,
      ),
      DriverLabourDetailScreen(person: person),
      DriverLabourFormScreen(kind: DriverLabourKind.driver, person: person),
      const DriverLabourFormScreen(kind: DriverLabourKind.labour),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: screen,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('text fields show a single border even with a host theme', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.reset);
    const hostBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            border: hostBorder,
            enabledBorder: hostBorder,
            focusedBorder: hostBorder,
          ),
        ),
        home: const DriverLabourFormScreen(kind: DriverLabourKind.driver),
      ),
    );
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(3));
    for (final field in tester.widgetList<TextField>(fields)) {
      final d = field.decoration!;
      expect(d.border, InputBorder.none);
      expect(d.enabledBorder, InputBorder.none);
      expect(d.focusedBorder, InputBorder.none);
      expect(d.filled, isFalse);
    }
  });
}
