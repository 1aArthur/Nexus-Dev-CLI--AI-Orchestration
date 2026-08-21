import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/features/extensions/domain/package_descriptor.dart';
import 'package:nexus_mobile/features/extensions/presentation/extensions_screen.dart';
import 'package:nexus_mobile/features/pets/presentation/pets_screen.dart';

void main() {
  testWidgets('package cards expose provenance signature license and permissions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ExtensionsScreen(
          packages: <PackageDescriptor>[
            PackageDescriptor(
              id: 'open-design-core',
              name: 'Open Design Core',
              version: '1.2.0',
              kind: PackageKind.openDesign,
              license: 'Apache-2.0',
              signatureStatus: PackageSignatureStatus.verified,
              permissions: const <String>['catalog:read', 'templates:import'],
              provenance: Uri.parse('https://github.com/nexu-io/open-design'),
              schemaValidated: true,
              archiveValidated: true,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Signature · Verified'), findsOneWidget);
    expect(find.text('License · Apache-2.0'), findsOneWidget);
    expect(find.text('Permissions · catalog:read, templates:import'), findsOneWidget);
    expect(find.textContaining('github.com/nexu-io/open-design'), findsOneWidget);
    expect(find.text('Validated metadata only'), findsOneWidget);
  });

  testWidgets('plugins never expose an executable mobile path', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ExtensionsScreen(
          packages: <PackageDescriptor>[
            PackageDescriptor(
              id: 'secure-exporter',
              name: 'Secure Exporter',
              version: '2.0.0',
              kind: PackageKind.plugin,
              license: 'MIT',
              signatureStatus: PackageSignatureStatus.verified,
              permissions: const <String>['artifact:write'],
              provenance: Uri.parse('https://example.invalid/secure-exporter'),
              schemaValidated: true,
              archiveValidated: true,
              hasWasmComponent: true,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Mobile · Declarative UI only'), findsOneWidget);
    expect(find.text('Server · Sandboxed Wasm'), findsOneWidget);
    expect(find.byKey(const Key('execute-mobile-plugin')), findsNothing);
    expect(find.text('Run on device'), findsNothing);
  });

  testWidgets('unlicensed provider pets remain visible but disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PetsScreen(
          pets: <PackageDescriptor>[
            PackageDescriptor(
              id: 'openai-pet-connector',
              name: 'OpenAI Pet connector',
              version: 'catalog',
              kind: PackageKind.pet,
              license: 'License/source required',
              signatureStatus: PackageSignatureStatus.unverified,
              permissions: const <String>[],
              provenance: Uri.parse('https://openai.com'),
              schemaValidated: true,
              archiveValidated: false,
              authorizedSource: false,
            ),
          ],
        ),
      ),
    );

    expect(find.text('OpenAI Pet connector'), findsOneWidget);
    expect(find.text('Unavailable · authorized redistributable source required'), findsOneWidget);
    final activate = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Activate'),
    );
    expect(activate.onPressed, isNull);
  });
}
