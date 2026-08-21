import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/app/router.dart';

void main() {
  // Catches the production defect where engine choices are hidden behind an
  // unimplemented route, so unsupported runtimes could not be explained or
  // kept visibly separate from the production Web engine.
  testWidgets('Engine Lab route exposes the engine capability catalog', (
    tester,
  ) async {
    final router = createNexusRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    router.go('/more/engine-lab');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('engine-lab')), findsOneWidget);
    expect(find.text('System WebView'), findsOneWidget);
    expect(find.text('Servo'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Ultralight'), 240);
    expect(find.text('Ultralight'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Lynx'), 240);

    expect(find.text('Lynx'), findsOneWidget);
    expect(find.byType(FeaturePlaceholderScreen), findsNothing);
  });
}
