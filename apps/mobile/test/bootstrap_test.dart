import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/app/nexus_app.dart';

void main() {
  testWidgets('NexusApp owns a router-based Material application', (
    tester,
  ) async {
    await tester.pumpWidget(const NexusApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.routerConfig, isNotNull);
  });
}
