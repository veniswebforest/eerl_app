import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eerl_app/features/collection/model/collection_entry_state.dart';
import 'package:eerl_app/features/collection/view/add_collection_screen.dart';
import 'package:eerl_app/features/records/model/records_view_flag.dart';
import 'package:eerl_app/features/records/view/records_tab_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('Save Draft opens Collection Records drafts view', (
    tester,
  ) async {
    await tester.pumpWidget(const _DraftNavigationHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('collection-save-draft')));
    await tester.pumpAndSettle();

    expect(find.byType(RecordsTabScreen), findsOneWidget);
    expect(find.text('Collection Drafts'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _DraftNavigationHarness extends StatefulWidget {
  const _DraftNavigationHarness();

  @override
  State<_DraftNavigationHarness> createState() =>
      _DraftNavigationHarnessState();
}

class _DraftNavigationHarnessState extends State<_DraftNavigationHarness> {
  bool _showRecords = false;

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: _showRecords
        ? const RecordsTabScreen(initialView: RecordsViewFlag.drafts)
        : AddCollectionScreen(
            onBack: _noop,
            initialStep: CollectionEntryStep.review,
            onSaveDraft: () => setState(() => _showRecords = true),
          ),
  );
}

void _noop() {}
