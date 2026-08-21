import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/design/components/status_badge.dart';
import 'package:nexus_mobile/design/nexus_theme.dart';
import 'package:nexus_mobile/design/tokens.dart';

void main() {
  test('OLED palette remains grayscale', () {
    for (final color in NexusColors.values) {
      final argb = color.toARGB32();
      final red = (argb >> 16) & 0xff;
      final green = (argb >> 8) & 0xff;
      final blue = argb & 0xff;
      expect(red, green);
      expect(green, blue);
    }
  });

  test('interactive button targets are at least 48 logical pixels', () {
    final size = NexusTheme.oled.filledButtonTheme.style?.minimumSize?.resolve(
      <WidgetState>{},
    );
    expect(size, isNotNull);
    expect(size!.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('status badge communicates state with semantics and text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(label: 'Ready', symbol: Icons.check_circle_outline),
        ),
      ),
    );

    expect(find.text('Ready'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.bySemanticsLabel('Status: Ready'), findsOneWidget);
  });
}
