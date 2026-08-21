import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/app/nexus_app.dart';

void main() {
  testWidgets('phone shell switches primary destinations from a bottom bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const NexusApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byKey(const Key('screen-title')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('screen-title'))).data,
      'Dashboard',
    );

    await tester.tap(find.text('Agents').last);
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const Key('screen-title'))).data,
      'Agents',
    );
  });

  testWidgets('tablet shell uses a labeled navigation rail', (tester) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const NexusApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Dashboard'), findsWidgets);
  });
}
