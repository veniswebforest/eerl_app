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
              photo: null,
              onPersonSelected: (_) {},
              onAddNewPerson: (_) async {},
              onDeactivatePerson: (person) => deactivated = person,
              onCapturePhoto: () {},
              onRemovePhoto: () {},
              onPreviewPhoto: () {},
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
}
