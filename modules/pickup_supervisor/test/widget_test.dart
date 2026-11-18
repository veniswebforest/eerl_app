import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/main.dart';

void main() {
  testWidgets('module app opens the driver dashboard', (tester) async {
    await tester.pumpWidget(const PickupSupervisorApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Kiran Shah'), findsOneWidget);
    expect(find.text('You’re Online'), findsOneWidget);
  });
}
