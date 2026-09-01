import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eerl_app/features/collection/model/collection_entry_state.dart';
import 'package:eerl_app/features/collection/view/add_collection_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('MRF Station shows a fixed agent field without dropdown', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AddCollectionScreen(
          onBack: _noop,
          initialType: CollectionType.mrfStation,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('collection-mrf-agent-fixed-field')),
      findsOneWidget,
    );
    expect(find.text('Hardik Pandya'), findsOneWidget);
    expect(
      find.byKey(const Key('collection-conditional-selector')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
