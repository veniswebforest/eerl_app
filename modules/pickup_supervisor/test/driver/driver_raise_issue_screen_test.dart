import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/driver/view/driver_home_screen.dart';

void main() {
  testWidgets('Report Issue opens the Figma issue form from driver home', (
    tester,
  ) async {
    _setDesignSize(tester, const Size(375, 812));
    await tester.pumpWidget(const MaterialApp(home: DriverHomeScreen()));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('driver-home-scroll')),
      const Offset(0, -3000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report Issue'));
    await tester.pumpAndSettle();

    expect(find.text('Raise an Issue'), findsOneWidget);
    expect(
      find.byKey(const Key('driver-issue-required-label')),
      findsOneWidget,
    );
    expect(find.text('Vehicle breakdown'), findsOneWidget);
    expect(find.text('Accident'), findsOneWidget);
    expect(find.text('Source problem'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Remarks'), findsOneWidget);
    expect(find.text('Max 150 Characters'), findsOneWidget);
    expect(find.text('Submit Issue'), findsOneWidget);
  });

  testWidgets('issue selection and remarks limit are interactive', (
    tester,
  ) async {
    _setDesignSize(tester, const Size(375, 812));
    await tester.pumpWidget(const MaterialApp(home: DriverHomeScreen()));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('driver-home-scroll')),
      const Offset(0, -3000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report Issue'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('driver-issue-accident')));
    await tester.enterText(
      find.byKey(const Key('driver-issue-remarks')),
      List.filled(151, 'a').join(),
    );
    await tester.pump();

    final remarks = tester.widget<TextField>(
      find.byKey(const Key('driver-issue-remarks')),
    );
    expect(remarks.controller!.text.length, 150);
    final submit = tester.widget<FilledButton>(
      find.byKey(const Key('driver-submit-issue')),
    );
    expect(submit.onPressed, isNotNull);
  });
}

void _setDesignSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
