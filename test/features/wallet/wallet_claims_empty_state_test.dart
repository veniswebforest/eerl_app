import 'package:eerl_app/features/wallet/widgets/wallet_claims_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the Figma wallet empty-state asset and message', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WalletClaimsEmptyState(message: 'No Request Logged Yet'),
        ),
      ),
    );

    final image = tester.widget<Image>(
      find.byKey(const Key('wallet-claims-empty-illustration')),
    );
    expect(image.width, 175);
    expect(image.height, 170);
    expect(find.text('No Request Logged Yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
