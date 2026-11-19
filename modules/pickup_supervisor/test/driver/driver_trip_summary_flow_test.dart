import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/driver/view/driver_pickup_success_screen.dart';
import 'package:pickup_supervisor/driver/view/driver_trip_summary_screen.dart';

void main() {
  testWidgets('last pickup opens summary, handover form, and waiting state', (
    tester,
  ) async {
    _setDesignSize(tester, const Size(375, 1200));
    await tester.pumpWidget(
      const MaterialApp(home: DriverPickupSuccessScreen(isLastStop: true)),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.byKey(const Key('driver-view-trip-summary')),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.byKey(const Key('driver-view-trip-summary')),
    );
    await tester.tap(find.text('View trip summary'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Trip 1 summary'), findsOneWidget);
    expect(find.text('1,260 kg + 25 pcs'), findsOneWidget);
    expect(find.text('Magdalla Warehouse'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('driver-handover-at-warehouse')),
      500,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('driver-trip-summary')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const Key('driver-handover-at-warehouse')));
    await tester.pumpAndSettle();
    expect(find.text('Hand over · Trip 1'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('driver-confirm-handover')),
      400,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('driver-warehouse-handover-form')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(
      find.textContaining('Number of bags', findRichText: true),
      findsOneWidget,
    );
    final bagsField = find.descendant(
      of: find.byKey(const Key('driver-bags-field')),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(bagsField).controller?.text, '42');
    await tester.tap(find.byKey(const Key('driver-confirm-handover')));
    await tester.pumpAndSettle();
    expect(find.text('Trip 1 · at the warehouse'), findsOneWidget);
    expect(find.text('Waiting'), findsOneWidget);
    expect(find.text('1,260 kg + 25 pcs · 42 bags'), findsOneWidget);
  });

  testWidgets('received status shows warehouse weighbridge comparison', (
    tester,
  ) async {
    _setDesignSize(tester, const Size(375, 900));
    await tester.pumpWidget(
      const MaterialApp(
        home: DriverWarehouseHandoverScreen(
          initialStatus: DriverWarehouseHandoverStatus.received,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trip 1 · received'), findsOneWidget);
    expect(find.text('Received'), findsOneWidget);
    expect(find.text('1,240 kg net + 25 pcs'), findsOneWidget);
    expect(find.text('Your count vs the weighbridge'), findsOneWidget);
    expect(find.text('−20 kg (1.6% less)'), findsOneWidget);
    expect(find.byKey(const Key('driver-received-back-home')), findsOneWidget);
  });
}

void _setDesignSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
