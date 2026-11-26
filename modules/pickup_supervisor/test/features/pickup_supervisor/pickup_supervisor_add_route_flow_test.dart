import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/driver/service/driver_photo_capture.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_add_route_flow.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_routes_screen.dart';

void main() {
  testWidgets('creates a route through both steps and shows saved feedback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: PickupSupervisorRoutesScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-route-button')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('supervisor-add-route-step-1')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('add-route-name')),
      'Adajan Morning',
    );
    await tester.tap(find.byKey(const Key('add-route-warehouse')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('warehouse-option-0')));
    await tester.tap(find.byKey(const Key('add-route-shift')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('shift-option-0')));
    await tester.tap(find.byKey(const Key('shift-option-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('add-route-step1-continue')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('supervisor-add-route-step-2')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('add-route-vehicle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vehicle-option-0')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-route-driver')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('driver-option-0')));
    await tester.tap(find.byKey(const Key('add-route-labour')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('labour-option-0')));
    await tester.tap(find.byKey(const Key('labour-option-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('add-route-step2-continue')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('supervisor-add-route-review')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('add-route-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('supervisor-routes-screen')), findsOneWidget);
    expect(find.byKey(const Key('add-route-saved-banner')), findsOneWidget);
    expect(find.text('Successfully Saved!'), findsOneWidget);
  });

  testWidgets(
    'validates new people and opens the camera-only capture adapter',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var cameraOpened = false;

      await tester.pumpWidget(
        DriverPhotoCaptureScope(
          adapter: DriverPhotoCaptureAdapter(
            capture: (context, {required recoveryId, required title}) async {
              cameraOpened = true;
              return null;
            },
          ),
          child: const MaterialApp(
            home: PickupSupervisorAddRouteAssignmentScreen(
              routeName: 'Adajan Morning',
              warehouse: 'Adajan Central Warehouse',
              shift: 'Morning · 7 am–3 pm',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add-route-driver')));
      await tester.enterText(
        find.byKey(const Key('add-route-driver')),
        'unknown',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('driver-option-add')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save-add-person')));
      await tester.pump();
      expect(find.text('Please enter the full name.'), findsOneWidget);
      expect(find.text('Please enter the mobile number.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('add-person-name')), 'A');
      await tester.enterText(find.byKey(const Key('add-person-mobile')), '123');
      await tester.tap(find.byKey(const Key('save-add-person')));
      await tester.pump();
      expect(
        find.text('Full name must be at least 2 characters.'),
        findsOneWidget,
      );
      expect(
        find.text('Enter a valid 10-digit mobile number starting with 6–9.'),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.byKey(const Key('add-driver-capture-photo')),
      );
      await tester.tap(find.byKey(const Key('add-driver-capture-photo')));
      await tester.pump();
      expect(cameraOpened, isTrue);

      await tester.enterText(
        find.byKey(const Key('add-person-name')),
        'Vikram Singh',
      );
      await tester.enterText(
        find.byKey(const Key('add-person-mobile')),
        '9876543210',
      );
      await tester.ensureVisible(find.byKey(const Key('save-add-person')));
      await tester.tap(find.byKey(const Key('save-add-person')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('add-driver-dialog')), findsNothing);

      await tester.tap(find.byKey(const Key('add-route-labour')));
      await tester.enterText(
        find.byKey(const Key('add-route-labour')),
        'unknown',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('labour-option-add')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('add-person-name')),
        'Ravi Bisht',
      );
      await tester.tap(find.byKey(const Key('save-add-person')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('add-labour-dialog')), findsNothing);
    },
  );

  testWidgets('driver and labour pencil actions confirm deactivation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: PickupSupervisorAddRouteAssignmentScreen(
          routeName: 'Adajan Morning',
          warehouse: 'Adajan Central Warehouse',
          shift: 'Morning · 7 am–3 pm',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-route-driver')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('driver-option-edit-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driver-option-deactivate-0')), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-option-deactivate-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('deactivate-person-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-deactivate')));
    await tester.pumpAndSettle();
    expect(find.text('Vikram Singh (12345 43210)'), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('add-route-labour')));
    await tester.tap(find.byKey(const Key('add-route-labour')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('labour-option-edit-0')));
    await tester.tap(find.byKey(const Key('labour-option-edit-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('labour-option-deactivate-0')), findsOneWidget);
    await tester.tap(find.byKey(const Key('labour-option-deactivate-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('deactivate-person-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-deactivate')));
    await tester.pumpAndSettle();
    expect(find.text('Ravi Bisht (23456 58492)'), findsNothing);
  });

  Future<void> pumpStep2(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: PickupSupervisorAddRouteAssignmentScreen(
          routeName: 'Adajan Morning',
          warehouse: 'Adajan Central Warehouse',
          shift: 'Morning · 7 am–3 pm',
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('company truck: labour is optional', (tester) async {
    await pumpStep2(tester);
    expect(find.text('Select Labour *'), findsNothing);
    await tester.tap(find.byKey(const Key('add-route-vehicle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vehicle-option-0')));
    await tester.pumpAndSettle();
    expect(find.text('Capacity 3000 KG'), findsOneWidget);
    await tester.tap(find.byKey(const Key('add-route-driver')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('driver-option-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('add-route-step2-continue')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('supervisor-add-route-review')),
      findsOneWidget,
    );
    expect(find.text('None'), findsOneWidget);
  });

  testWidgets('hired truck: typed details, no app driver', (tester) async {
    await pumpStep2(tester);
    await tester.tap(find.byKey(const Key('add-route-vehicle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vehicle-option-2')));
    await tester.pumpAndSettle();
    expect(find.text('Hired truck'), findsOneWidget);
    expect(find.text('Hired truck details'), findsOneWidget);
    expect(find.byKey(const Key('add-route-driver')), findsNothing);
    expect(
      find.textContaining('A hired truck’s driver has no app'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('add-route-step2-continue')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('supervisor-add-route-review')), findsNothing);

    for (final (key, text) in [
      ('add-route-truck-number', 'GJ-05-EE-1002'),
      ('add-route-transporter', 'Shree Ram Transport'),
      ('add-route-hired-driver', 'Kishan'),
      ('add-route-hired-phone', '99780 44120'),
      ('add-route-capacity', '3000'),
    ]) {
      await tester.enterText(find.byKey(Key(key)), text);
    }
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const Key('add-route-step2-continue')),
    );
    await tester.tap(find.byKey(const Key('add-route-step2-continue')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('supervisor-add-route-review')),
      findsOneWidget,
    );
    expect(find.text('GJ-05-EE-1002  (Shree Ram Transport)'), findsOneWidget);
    expect(find.text('Capacity 3000 KG'), findsOneWidget);
    expect(find.text('Kishan (99780 44120)'), findsOneWidget);
  });
}
