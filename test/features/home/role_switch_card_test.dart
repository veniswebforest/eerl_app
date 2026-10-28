import 'package:eerl_app/features/home/widgets/role_switch_card.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildCard({required bool canSwitchRole, VoidCallback? onTap}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RoleSwitchCard(
          canSwitchRole: canSwitchRole,
          onSwitchRoleTap: onTap,
          roleTitle: 'Collection Point Agent',
          zoneName: 'Center One',
        ),
      ),
    );
  }

  testWidgets('single role shows only role and center details', (tester) async {
    await tester.pumpWidget(buildCard(canSwitchRole: false));

    expect(find.text('Collection Point Agent'), findsOneWidget);
    expect(find.text('Center One'), findsOneWidget);
    expect(find.byKey(const Key('home-role-details')), findsOneWidget);
    expect(find.text('EERL Role Switch'), findsNothing);
    expect(find.text('Select to anchor provided role'), findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(find.byKey(const Key('home-switch-role-button')), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('home-role-switch-card'))).height,
      62,
    );
  });

  testWidgets('multiple roles show the role switch controls', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      buildCard(canSwitchRole: true, onTap: () => tapped = true),
    );

    expect(find.byKey(const Key('home-switch-role-button')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('home-role-switch-card'))).height,
      202,
    );

    await tester.tap(find.byKey(const Key('home-switch-role-button')));
    expect(tapped, isTrue);
  });
}
