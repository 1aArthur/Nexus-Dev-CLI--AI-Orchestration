import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/design/components/nexus_brand_mark.dart';

void main() {
  testWidgets('brand mark uses the OLED logo asset with accessible semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NexusBrandMark(key: Key('brand-under-test'))),
      ),
    );

    expect(find.byKey(const Key('brand-under-test')), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == NexusBrandMark.assetName,
      ),
      findsOneWidget,
    );

    final semantics = tester.getSemantics(find.byType(Image));
    expect(semantics.label, 'Nexus: hexagono, equalizador e raio');
  });
}
