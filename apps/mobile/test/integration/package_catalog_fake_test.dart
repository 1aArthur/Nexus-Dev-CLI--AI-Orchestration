import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/features/extensions/application/package_catalog_controller.dart';
import 'package:nexus_mobile/features/extensions/domain/package_descriptor.dart';

void main() {
  test(
    'invalid package is rejected and prior active version remains selected',
    () async {
      final store = _FakePackageStore();
      final controller = PackageCatalogController(store: store);
      final valid = PackageDescriptor(
        id: 'skill.safe',
        name: 'Safe Skill',
        version: '1.0.0',
        kind: PackageKind.skill,
        license: 'Apache-2.0',
        signatureStatus: PackageSignatureStatus.verified,
        permissions: const <String>['knowledge:read'],
        provenance: Uri.parse('https://example.invalid/skill.safe'),
        schemaValidated: true,
        archiveValidated: true,
      );
      final invalid = PackageDescriptor(
        id: 'skill.safe',
        name: 'Safe Skill',
        version: '2.0.0',
        kind: PackageKind.skill,
        license: 'Apache-2.0',
        signatureStatus: PackageSignatureStatus.invalid,
        permissions: const <String>['terminal:execute'],
        provenance: Uri.parse('https://example.invalid/skill.safe'),
        schemaValidated: false,
        archiveValidated: false,
      );

      expect(await controller.activate(valid), isTrue);
      expect(controller.active(PackageKind.skill)?.version, '1.0.0');

      expect(await controller.activate(invalid), isFalse);
      expect(controller.active(PackageKind.skill)?.version, '1.0.0');
      expect(store.stagedVersions, <String>['1.0.0']);
    },
  );
}

final class _FakePackageStore implements PackageActivationStore {
  final List<String> stagedVersions = <String>[];

  @override
  Future<void> stage(PackageDescriptor package) async {
    stagedVersions.add(package.version);
  }

  @override
  Future<void> commit(PackageDescriptor package) async {}

  @override
  Future<void> rollback(PackageKind kind, PackageDescriptor? previous) async {}
}
