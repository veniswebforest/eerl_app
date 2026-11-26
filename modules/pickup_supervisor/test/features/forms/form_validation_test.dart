import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/cash_payments/model/cash_payments_mock_data.dart';
import 'package:pickup_supervisor/features/cash_payments/model/cash_payments_models.dart';
import 'package:pickup_supervisor/features/cash_payments/view/pay_point_screen.dart';
import 'package:pickup_supervisor/features/driver_labour/model/driver_labour_person.dart';
import 'package:pickup_supervisor/features/driver_labour/view/driver_labour_form_screen.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_add_route_flow.dart';

void main() {
  setUp(CashPaymentsStore.reset);

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 1300);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('host')),
          ),
        ),
      ),
    );
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(MaterialPageRoute<void>(builder: (_) => home));
    await tester.pumpAndSettle();
  }

  TextField field(WidgetTester tester, String key) => tester.widget<TextField>(
    find
            .descendant(
              of: find.byKey(Key(key)),
              matching: find.byType(TextField),
            )
            .evaluate()
            .isEmpty
        ? find.byKey(Key(key))
        : find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(TextField),
          ),
  );

  bool hasFocus(WidgetTester tester, String key) => tester
      .widget<EditableText>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(EditableText),
        ),
      )
      .focusNode
      .hasFocus;

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('driver-labour-form-save')));
    await tester.pumpAndSettle();
  }

  testWidgets('driver form: required fields block Save with messages', (
    tester,
  ) async {
    await pump(
      tester,
      const DriverLabourFormScreen(kind: DriverLabourKind.driver),
    );
    final name = field(tester, 'driver-labour-name');
    expect(name.keyboardType, TextInputType.name);
    expect(name.textInputAction, TextInputAction.next);
    expect(
      field(tester, 'driver-labour-mobile').keyboardType,
      TextInputType.phone,
    );
    expect(
      field(tester, 'driver-labour-id').textInputAction,
      TextInputAction.done,
    );

    await save(tester);
    expect(find.text('Please enter the full name.'), findsOneWidget);
    expect(find.text('Please enter the mobile number.'), findsOneWidget);
    expect(find.byType(DriverLabourFormScreen), findsOneWidget);

    // Fixing a field clears its message without another Save.
    await tester.enterText(find.byKey(const Key('driver-labour-name')), 'Ra');
    await tester.enterText(
      find.byKey(const Key('driver-labour-mobile')),
      '123',
    );
    await tester.pump();
    expect(find.text('Please enter the full name.'), findsNothing);
    expect(
      find.text('Enter a valid 10-digit mobile number starting with 6–9.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('driver-labour-mobile')),
      '9825012458',
    );
    await tester.enterText(find.byKey(const Key('driver-labour-id')), '12');
    await save(tester);
    expect(
      find.text('Enter a 12-digit Aadhaar number or a valid Voter ID.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('driver-labour-id')),
      '8478 8456 6324',
    );
    await save(tester);
    expect(find.byType(DriverLabourFormScreen), findsNothing);
  });

  testWidgets('labour form: optional mobile and ID do not block Save', (
    tester,
  ) async {
    await pump(
      tester,
      const DriverLabourFormScreen(kind: DriverLabourKind.labour),
    );
    await tester.enterText(
      find.byKey(const Key('driver-labour-name')),
      'Ravi Bisht',
    );
    await save(tester);
    expect(find.byType(DriverLabourFormScreen), findsNothing);
  });

  testWidgets('Next moves to the next field; Done closes the keyboard', (
    tester,
  ) async {
    await pump(
      tester,
      const DriverLabourFormScreen(kind: DriverLabourKind.driver),
    );
    await tester.tap(find.byKey(const Key('driver-labour-name')));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(hasFocus(tester, 'driver-labour-mobile'), isTrue);

    await tester.tap(find.byKey(const Key('driver-labour-id')));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(hasFocus(tester, 'driver-labour-id'), isFalse);
  });

  testWidgets('pay: letters are dropped, over the limit shows a message', (
    tester,
  ) async {
    await pump(
      tester,
      PayPointScreen(point: CashPaymentsMockData.pointsToPay.first),
    );
    await tester.enterText(find.byKey(const Key('pay-point-amount')), '5ab0');
    await tester.pump();
    expect(find.text('50'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('pay-point-amount')), '2000');
    await tester.pump();
    expect(find.text('Can’t be more than ₹1,250.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('pay-point-amount')), '0');
    await tester.pump();
    expect(find.text('Enter an amount more than 0.'), findsOneWidget);
    expect(
      field(tester, 'pay-point-note').keyboardType,
      TextInputType.multiline,
    );
  });

  testWidgets('hired truck: invalid number, phone and capacity show errors', (
    tester,
  ) async {
    await pump(
      tester,
      const PickupSupervisorAddRouteAssignmentScreen(
        routeName: 'Adajan Morning',
        warehouse: 'Adajan Central Warehouse',
        shift: 'Morning',
      ),
    );
    await tester.tap(find.byKey(const Key('add-route-vehicle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vehicle-option-2')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('add-route-truck-number')),
      'x',
    );
    await tester.enterText(
      find.byKey(const Key('add-route-hired-phone')),
      '12',
    );
    await tester.enterText(find.byKey(const Key('add-route-capacity')), '0');
    await tester.pump();
    expect(
      find.text('Enter a valid vehicle number, e.g. GJ-05-EE-1002.'),
      findsOneWidget,
    );
    expect(
      find.text('Enter a valid 10-digit mobile number starting with 6–9.'),
      findsOneWidget,
    );
    expect(find.text('Enter a capacity more than 0.'), findsOneWidget);
    expect(
      field(tester, 'add-route-capacity').textInputAction,
      TextInputAction.done,
    );
  });
}
