import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/app/router.dart';

void main() {
  // Catches the production defect where Credits and Settings remain generic
  // placeholders instead of exposing the Task 9 provider and budget surfaces.
  testWidgets('Task 9 destinations render real feature surfaces', (
    tester,
  ) async {
    final router = createNexusRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    router.go('/more/credits');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('credits-center')), findsOneWidget);
    expect(find.byType(FeaturePlaceholderScreen), findsNothing);

    router.go('/more/settings');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('provider-settings')), findsOneWidget);
    expect(find.byType(FeaturePlaceholderScreen), findsNothing);
  });
}
