import 'package:flutter/foundation.dart';

enum PackageKind { pet, skill, plugin, knowledge, instruction, openDesign }

enum PackageSignatureStatus { verified, unverified, invalid }

@immutable
final class PackageDescriptor {
  const PackageDescriptor({
    required this.id,
    required this.name,
    required this.version,
    required this.kind,
    required this.license,
    required this.signatureStatus,
    required this.permissions,
    required this.provenance,
    required this.schemaValidated,
    required this.archiveValidated,
    this.authorizedSource = true,
    this.hasWasmComponent = false,
    this.summary = '',
  });

  final String id;
  final String name;
  final String version;
  final PackageKind kind;
  final String license;
  final PackageSignatureStatus signatureStatus;
  final List<String> permissions;
  final Uri provenance;
  final bool schemaValidated;
  final bool archiveValidated;
  final bool authorizedSource;
  final bool hasWasmComponent;
  final String summary;

  bool get activationAllowed => PackagePolicy.rejectionReason(this) == null;
}

abstract final class PackagePolicy {
  static String? rejectionReason(PackageDescriptor package) {
    if (!package.schemaValidated) return 'Schema validation failed';
    if (!package.archiveValidated) return 'Archive validation failed';
    if (package.signatureStatus != PackageSignatureStatus.verified) {
      return 'Publisher signature is not verified';
    }
    if (package.license.trim().isEmpty) return 'License metadata is required';
    if (!package.authorizedSource) {
      return 'Authorized redistributable source required';
    }
    if (package.kind == PackageKind.openDesign &&
        !_isCanonicalOpenDesignSource(package.provenance)) {
      return 'Open Design source is not canonical';
    }
    return null;
  }

  static bool _isCanonicalOpenDesignSource(Uri source) {
    return source.scheme == 'https' &&
        source.host == 'github.com' &&
        source.pathSegments.length >= 2 &&
        source.pathSegments[0] == 'nexu-io' &&
        source.pathSegments[1] == 'open-design';
  }
}

extension PackageDescriptorLabels on PackageDescriptor {
  String get kindLabel => switch (kind) {
    PackageKind.pet => 'Pet Pack',
    PackageKind.skill => 'Skill',
    PackageKind.plugin => 'Plugin',
    PackageKind.knowledge => 'NKB',
    PackageKind.instruction => 'Instruction set',
    PackageKind.openDesign => 'Open Design',
  };

  String get signatureLabel => switch (signatureStatus) {
    PackageSignatureStatus.verified => 'Verified',
    PackageSignatureStatus.unverified => 'Unverified',
    PackageSignatureStatus.invalid => 'Invalid',
  };
}
