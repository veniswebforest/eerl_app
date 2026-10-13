import 'package:eerl_app/features/transfer_requests/widgets/transfer_dispatch_date_time_picker.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('confirms the selected dispatch date and time', (tester) async {
    DateTime? confirmed;
    final initial = DateTime(2026, 8, 16, 9, 32);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: TransferDispatchDateTimePicker(
              initialDateTime: initial,
              onCancel: () {},
              onConfirm: (value) => confirmed = value,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('09:32'), findsOneWidget);

    await tester.tap(find.byKey(const Key('transfer-calendar-confirm')));
    await tester.pump();

    expect(confirmed, initial);
  });
}
