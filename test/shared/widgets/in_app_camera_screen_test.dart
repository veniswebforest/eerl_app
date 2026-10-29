import 'package:eerl_app/shared/widgets/in_app_camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows no camera message when cameras list is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InAppCameraScreen(cameras: []),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No camera found on this device.'), findsOneWidget);
    expect(find.text('Use System Camera'), findsOneWidget);
  });

  testWidgets('close button pops the InAppCameraScreen', (tester) async {
    bool popped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const InAppCameraScreen(cameras: []),
                ),
              );
              popped = true;
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(InAppCameraScreen), findsOneWidget);

    final closeButton = find.byIcon(Icons.close_rounded);
    expect(closeButton, findsOneWidget);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    expect(find.byType(InAppCameraScreen), findsNothing);
    expect(popped, isTrue);
  });
}
