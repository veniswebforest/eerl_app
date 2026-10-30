import 'package:eerl_app/features/collection/widgets/ramp_details_form.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pencil menu deactivates the selected ragpicker record', (
    tester,
  ) async {
    const ragpicker = RagpickerModel(
      id: 'ragpicker-1',
      centerId: 'center-1',
      name: 'Vikram Singh',
      isActive: true,
      syncState: 'synced',
    );
    RagpickerModel? deactivated;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: RampDetailsForm(
              people: const [ragpicker],
              selectedPersonId: null,
              onPersonSelected: (_) {},
              onAddNewPerson: (_) async {},
              onDeactivatePerson: (person) => deactivated = person,
              handoverPhoto: null,
              onCaptureHandoverPhoto: () {},
              onRemoveHandoverPhoto: () {},
              onPreviewHandoverPhoto: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('ramp-person-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ramp-edit-person-ragpicker-1')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('ramp-deactivate-person-ragpicker-1')),
    );
    await tester.pumpAndSettle();

    expect(deactivated?.id, 'ragpicker-1');
    expect(deactivated?.name, 'Vikram Singh');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ramp form exposes handover, not vehicle, photo capture', (
    tester,
  ) async {
    var handoverCaptureTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: RampDetailsForm(
              people: const [],
              selectedPersonId: null,
              onPersonSelected: (_) {},
              onAddNewPerson: (_) async {},
              onDeactivatePerson: (_) {},
              handoverPhoto: null,
              onCaptureHandoverPhoto: () => handoverCaptureTapped = true,
              onRemoveHandoverPhoto: () {},
              onPreviewHandoverPhoto: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('ramp-capture-vehicle-photo')), findsNothing);
    expect(find.text('Capture Vehicle Photo *'), findsNothing);
    expect(
      find.byKey(const Key('ramp-capture-handover-photo')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('ramp-preview-handover-photo')), findsNothing);
    await tester.tap(find.byKey(const Key('ramp-capture-handover-photo')));
    expect(handoverCaptureTapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
