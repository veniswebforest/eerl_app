import 'package:eerl_app/features/collection/widgets/d2d_vehicle_details_form.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  testWidgets('contact supervisor shows the synced supervisor details', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: D2dVehicleDetailsForm(
              vehicleNumbers: const ['GJ-05-AB-1234'],
              selectedVehicle: null,
              givenBy: '',
              vehiclePhoto: null,
              supervisorName: 'Kiran Rathod',
              supervisorPhone: '9876543210',
              onVehicleSelected: (_) {},
              onGivenByChanged: (_) {},
              onCapturePhoto: () {},
              onRemovePhoto: () {},
              onPreviewPhoto: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('d2d-vehicle-search')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('d2d-contact-supervisor')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('d2d-supervisor-details')), findsOneWidget);
    expect(find.text('Kiran Rathod'), findsOneWidget);
    expect(find.text('9876543210'), findsOneWidget);
    expect(find.text('KR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contact supervisor shows "No supervisor set: ask your admin to set one." when supervisorName is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: D2dVehicleDetailsForm(
              vehicleNumbers: const ['GJ-05-AB-1234'],
              selectedVehicle: null,
              givenBy: '',
              vehiclePhoto: null,
              supervisorName: null,
              supervisorPhone: null,
              onVehicleSelected: (_) {},
              onGivenByChanged: (_) {},
              onCapturePhoto: () {},
              onRemovePhoto: () {},
              onPreviewPhoto: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('d2d-vehicle-search')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('d2d-contact-supervisor')));
    await tester.pumpAndSettle();

    expect(
      find.text('No supervisor set: ask your admin to set one.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('d2d-supervisor-details')), findsNothing);
  });

  testWidgets('displays the vehicle photo when captured', (tester) async {
    bool removed = false;
    bool previewed = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: D2dVehicleDetailsForm(
              vehicleNumbers: const ['GJ-05-AB-1234'],
              selectedVehicle: 'GJ-05-AB-1234',
              givenBy: 'Driver',
              vehiclePhoto: XFile('test/assets/test_photo.jpg'),
              supervisorName: null,
              supervisorPhone: null,
              onVehicleSelected: (_) {},
              onGivenByChanged: (_) {},
              onCapturePhoto: () {},
              onRemovePhoto: () => removed = true,
              onPreviewPhoto: () => previewed = true,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('d2d-remove-vehicle-photo')), findsOneWidget);

    await tester.tap(find.byKey(const Key('d2d-remove-vehicle-photo')));
    expect(removed, isTrue);

    await tester.tap(find.byType(Image));
    expect(previewed, isTrue);
  });
}

