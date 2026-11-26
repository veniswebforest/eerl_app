import 'package:eerl_app/core/utils/input_formatters.dart';
import 'package:eerl_app/core/utils/input_validators.dart';
import 'package:eerl_app/features/collection/widgets/add_new_ragpicker_bottom_sheet.dart';
import 'package:eerl_app/features/d2d_vehicle_management/widgets/d2d_vehicle_form.dart';
import 'package:eerl_app/features/transfer_requests/view/supervisor_transfer_reject_screen.dart';
import 'package:eerl_app/features/wallet/widgets/log_expense_field.dart';
import 'package:eerl_app/features/wallet/widgets/request_new_expense_category_dialog.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

EditableText _editable(WidgetTester tester, Finder field) => tester.widget(
  find.descendant(of: field, matching: find.byType(EditableText)),
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Add new ragpicker form', () {
    Future<List<NewRagpickerInput>> pumpSheet(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final saved = <NewRagpickerInput>[];
      await tester.pumpWidget(
        _app(
          AddNewRagpickerBottomSheet(onSave: (input) async => saved.add(input)),
        ),
      );
      await tester.pumpAndSettle();
      return saved;
    }

    Finder fields() => find.byType(TextField);

    testWidgets('keyboards and actions follow the form order', (tester) async {
      await pumpSheet(tester);
      expect(fields(), findsNWidgets(3));
      final name = _editable(tester, fields().at(0));
      final mobile = _editable(tester, fields().at(1));
      final id = _editable(tester, fields().at(2));
      expect(name.textInputAction, TextInputAction.next);
      expect(name.textCapitalization, TextCapitalization.words);
      expect(mobile.keyboardType, AppKeyboards.phone);
      expect(mobile.textInputAction, TextInputAction.next);
      expect(id.textInputAction, TextInputAction.done);
    });

    testWidgets('Next moves focus and Done unfocuses', (tester) async {
      await pumpSheet(tester);
      await tester.tap(fields().at(0));
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(_editable(tester, fields().at(1)).focusNode.hasFocus, isTrue);

      await tester.tap(fields().at(2));
      await tester.pump();
      expect(_editable(tester, fields().at(2)).focusNode.hasFocus, isTrue);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(_editable(tester, fields().at(2)).focusNode.hasFocus, isFalse);
    });

    testWidgets('mobile field drops letters and caps at 10 digits', (
      tester,
    ) async {
      await pumpSheet(tester);
      await tester.enterText(fields().at(1), '98ab76543210999');
      expect(_editable(tester, fields().at(1)).controller.text, '9876543210');
    });

    testWidgets('required empty and invalid phone block save', (tester) async {
      final saved = await pumpSheet(tester);
      await tester.tap(find.text(l10n.saveAndSelect));
      await tester.pump();
      expect(find.text(l10n.ragpickerNameRequired), findsOneWidget);
      expect(saved, isEmpty);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.enterText(fields().at(0), '   ');
      await tester.tap(find.text(l10n.saveAndSelect));
      await tester.pump();
      expect(find.text(l10n.ragpickerNameRequired), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.enterText(fields().at(0), 'Ramesh Patel');
      await tester.enterText(fields().at(1), '12345');
      await tester.tap(find.text(l10n.saveAndSelect));
      await tester.pump();
      expect(find.text(l10n.invalidMobileNumber), findsOneWidget);
      expect(saved, isEmpty);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('optional ID left empty does not block save', (tester) async {
      final saved = await pumpSheet(tester);
      await tester.enterText(fields().at(0), 'Ramesh Patel');
      await tester.enterText(fields().at(1), '9876543210');
      await tester.tap(find.text(l10n.saveAndSelect));
      await tester.pumpAndSettle();
      expect(saved, hasLength(1));
      expect(saved.single.idNumber, isNull);
      expect(saved.single.phone, '9876543210');
    });
  });

  group('Shared money input', () {
    testWidgets('rejects letters and a third decimal place', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(
          LogExpenseInput(
            controller: controller,
            hint: 'Amount',
            keyboardType: AppKeyboards.decimal,
            inputFormatters: AppInputFormatters.money(
              maxValue: AppInputLimits.maxWalletAmount,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '12.5');
      expect(controller.text, '12.5');
      await tester.enterText(find.byType(TextField), '12.555');
      expect(controller.text, '12.5');
      await tester.enterText(find.byType(TextField), '12a');
      expect(controller.text, '12.5');
    });

    testWidgets('multi-line boxes default to the newline action', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(
          LogExpenseInput(controller: controller, hint: 'Note', maxLines: 4),
        ),
      );
      final editable = _editable(tester, find.byType(TextField));
      expect(editable.textInputAction, TextInputAction.newline);
      expect(editable.keyboardType, TextInputType.multiline);
    });
  });

  group('Request new expense category', () {
    testWidgets('name is required, trimmed and at least 2 characters', (
      tester,
    ) async {
      final submitted = <String>[];
      await tester.pumpWidget(
        _app(
          RequestNewExpenseCategoryDialog(
            onSubmit: (name, reason) async => submitted.add(name),
          ),
        ),
      );
      await tester.pumpAndSettle();
      ElevatedButton submit() => tester.widget<ElevatedButton>(
        find.byKey(const Key('submit-new-expense-category')),
      );
      final name = find.byType(TextField).first;

      expect(submit().onPressed, isNull);
      await tester.enterText(name, '   ');
      await tester.pump();
      expect(submit().onPressed, isNull);

      await tester.enterText(name, 'a');
      await tester.pump();
      expect(find.text(l10n.validationMinLength(2)), findsOneWidget);
      expect(submit().onPressed, isNull);

      await tester.enterText(name, 'Tea');
      await tester.pump();
      expect(find.text(l10n.validationMinLength(2)), findsNothing);
      expect(submit().onPressed, isNotNull);
    });
  });

  group('Reject transfer', () {
    testWidgets('Other needs remarks; other reasons leave remarks optional', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SupervisorTransferRejectScreen(
            onBack: () {},
            onConfirm: (_) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      ElevatedButton confirm() => tester.widget<ElevatedButton>(
        find.byKey(const Key('supervisor-transfer-confirm-rejection')),
      );

      await tester.tap(
        find.byKey(const ValueKey('supervisor-transfer-reject-reason-0')),
      );
      await tester.pump();
      expect(confirm().onPressed, isNotNull);

      await tester.tap(
        find.byKey(const ValueKey('supervisor-transfer-reject-reason-0')),
      );
      await tester.tap(
        find.byKey(const ValueKey('supervisor-transfer-reject-reason-3')),
      );
      await tester.pump();
      expect(confirm().onPressed, isNull);
      expect(find.text(l10n.validationRequired), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('supervisor-transfer-reject-remarks')),
        'Truck booked till Friday',
      );
      await tester.pump();
      expect(confirm().onPressed, isNotNull);
    });
  });

  group('D2D vehicle number', () {
    Future<TextEditingController> pumpForm(
      WidgetTester tester, {
      String? error,
    }) async {
      final number = TextEditingController();
      final driver = TextEditingController();
      addTearDown(number.dispose);
      addTearDown(driver.dispose);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: D2dVehicleForm(
            editing: true,
            numberController: number,
            centerOptions: const [],
            selectedCenter: -1,
            centerExpanded: false,
            driverNameController: driver,
            onCenterToggle: () {},
            onCenterSelected: (_) {},
            onBack: () {},
            onCancel: () {},
            onSave: () {},
            numberErrorText: error,
          ),
        ),
      );
      return number;
    }

    testWidgets('lowercase becomes capitals and Next goes to driver', (
      tester,
    ) async {
      final number = await pumpForm(tester);
      final field = find.byKey(const Key('d2d-vehicle-number-field'));
      await tester.enterText(field, 'gj-05 bx#1234');
      expect(number.text, 'GJ-05 BX1234');
      expect(InputValidators.vehiclePlate(number.text, l10n), isNull);
      expect(_editable(tester, field).textInputAction, TextInputAction.next);
    });

    testWidgets('shows the inline plate error', (tester) async {
      await pumpForm(tester, error: l10n.validationVehiclePlate);
      expect(find.byKey(const Key('d2d-vehicle-number-error')), findsOneWidget);
      expect(find.text(l10n.validationVehiclePlate), findsOneWidget);
    });
  });
}
