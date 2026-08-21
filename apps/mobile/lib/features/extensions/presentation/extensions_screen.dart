import 'package:flutter/material.dart';

import '../../../design/tokens.dart';
import '../domain/package_descriptor.dart';

class ExtensionsScreen extends StatelessWidget {
  const ExtensionsScreen({
    this.packages,
    this.kindFilter,
    this.onActivate,
    this.onImport,
    super.key,
  });

  final List<PackageDescriptor>? packages;
  final PackageKind? kindFilter;
  final ValueChanged<PackageDescriptor>? onActivate;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final visiblePackages = (packages ?? _defaultPackages)
        .where((package) => kindFilter == null || package.kind == kindFilter)
        .toList(growable: false);
    return ListView(
      padding: const EdgeInsets.all(NexusSpacing.x4),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    kindFilter == PackageKind.skill
                        ? 'Declarative Skills'
                        : 'Extension catalog',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: NexusSpacing.x1),
                  const Text(
                    'Validated manifests, explicit capabilities, pinned '
                    'provenance, and reversible activation.',
                  ),
                ],
              ),
            ),
            const SizedBox(width: NexusSpacing.x3),
            OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Inspect package'),
            ),
          ],
        ),
        const SizedBox(height: NexusSpacing.x4),
        const _TrustBoundaryCard(),
        const SizedBox(height: NexusSpacing.x4),
        ...visiblePackages.map(
          (package) => Padding(
            padding: const EdgeInsets.only(bottom: NexusSpacing.x3),
            child: PackageMetadataCard(
              package: package,
              onActivate: onActivate == null
                  ? null
                  : () => onActivate!(package),
            ),
          ),
        ),
      ],
    );
  }
}

class PackageMetadataCard extends StatelessWidget {
  const PackageMetadataCard({
    required this.package,
    this.onActivate,
    super.key,
  });

  final PackageDescriptor package;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context) {
    final rejection = PackagePolicy.rejectionReason(package);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NexusSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(_iconFor(package.kind), semanticLabel: package.kindLabel),
                const SizedBox(width: NexusSpacing.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        package.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('${package.kindLabel} · v${package.version}'),
                    ],
                  ),
                ),
                _ValidationBadge(valid: package.activationAllowed),
              ],
            ),
            if (package.summary.isNotEmpty) ...<Widget>[
              const SizedBox(height: NexusSpacing.x3),
              Text(package.summary),
            ],
            const SizedBox(height: NexusSpacing.x3),
            Wrap(
              spacing: NexusSpacing.x2,
              runSpacing: NexusSpacing.x2,
              children: <Widget>[
                _MetadataPill(
                  icon: Icons.verified_user_outlined,
                  label: 'Signature · ${package.signatureLabel}',
                ),
                _MetadataPill(
                  icon: Icons.balance_outlined,
                  label: 'License · ${package.license}',
                ),
                _MetadataPill(
                  icon: Icons.key_outlined,
                  label:
                      'Permissions · '
                      '${package.permissions.isEmpty ? 'None' : package.permissions.join(', ')}',
                ),
              ],
            ),
            const SizedBox(height: NexusSpacing.x3),
            SelectableText('Provenance · ${package.provenance}'),
            const SizedBox(height: NexusSpacing.x2),
            const Text('Validated metadata only'),
            if (package.kind == PackageKind.plugin) ...<Widget>[
              const Divider(height: NexusSpacing.x6),
              const Wrap(
                spacing: NexusSpacing.x3,
                runSpacing: NexusSpacing.x2,
                children: <Widget>[
                  _MetadataPill(
                    icon: Icons.phone_android_outlined,
                    label: 'Mobile · Declarative UI only',
                  ),
                  _MetadataPill(
                    icon: Icons.dns_outlined,
                    label: 'Server · Sandboxed Wasm',
                  ),
                ],
              ),
            ],
            if (rejection != null) ...<Widget>[
              const SizedBox(height: NexusSpacing.x3),
              Text('Blocked · $rejection'),
            ],
            if (onActivate != null) ...<Widget>[
              const SizedBox(height: NexusSpacing.x3),
              FilledButton.icon(
                onPressed: package.activationAllowed ? onActivate : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Activate'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrustBoundaryCard extends StatelessWidget {
  const _TrustBoundaryCard();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(NexusSpacing.x4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.security_outlined, semanticLabel: 'Trust boundary'),
          SizedBox(width: NexusSpacing.x3),
          Expanded(
            child: Text(
              'Skills are instructions, not code. Plugin Wasm runs only in a '
              'bounded server sandbox. The mobile app never loads extension '
              'executables or installer scripts.',
            ),
          ),
        ],
      ),
    ),
  );
}

class _ValidationBadge extends StatelessWidget {
  const _ValidationBadge({required this.valid});

  final bool valid;

  @override
  Widget build(BuildContext context) => Semantics(
    label: valid ? 'Package validated' : 'Package blocked',
    child: Chip(
      avatar: Icon(
        valid ? Icons.verified_outlined : Icons.block_outlined,
        size: 18,
      ),
      label: Text(valid ? 'Validated' : 'Blocked'),
    ),
  );
}

class _MetadataPill extends StatelessWidget {
  const _MetadataPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: NexusSpacing.x3,
      vertical: NexusSpacing.x2,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: NexusColors.border),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16),
        const SizedBox(width: NexusSpacing.x2),
        Text(label),
      ],
    ),
  );
}

IconData _iconFor(PackageKind kind) => switch (kind) {
  PackageKind.pet => Icons.pets_outlined,
  PackageKind.skill => Icons.auto_awesome_outlined,
  PackageKind.plugin => Icons.extension_outlined,
  PackageKind.knowledge => Icons.menu_book_outlined,
  PackageKind.instruction => Icons.rule_outlined,
  PackageKind.openDesign => Icons.design_services_outlined,
};

List<PackageDescriptor> get _defaultPackages => <PackageDescriptor>[
  PackageDescriptor(
    id: 'nexus.devsecops',
    name: 'DevSecOps Guardrails',
    version: '1.0.0',
    kind: PackageKind.skill,
    license: 'Apache-2.0',
    signatureStatus: PackageSignatureStatus.verified,
    permissions: const <String>['repository:read', 'security:scan'],
    provenance: Uri.parse(
      'https://github.com/1aArthur/Nexus-Dev-CLI--AI-Orchestration',
    ),
    schemaValidated: true,
    archiveValidated: true,
    summary: 'Deterministic checks with explicit tool permissions.',
  ),
  PackageDescriptor(
    id: 'nexus.artifact-inspector',
    name: 'Artifact Inspector',
    version: '1.0.0',
    kind: PackageKind.plugin,
    license: 'Apache-2.0',
    signatureStatus: PackageSignatureStatus.verified,
    permissions: const <String>['artifact:read'],
    provenance: Uri.parse(
      'https://github.com/1aArthur/Nexus-Dev-CLI--AI-Orchestration',
    ),
    schemaValidated: true,
    archiveValidated: true,
    hasWasmComponent: true,
    summary: 'Server-side Wasm inspection with deny-by-default capabilities.',
  ),
  PackageDescriptor(
    id: 'open-design.catalog',
    name: 'Open Design catalog',
    version: 'pinned',
    kind: PackageKind.openDesign,
    license: 'Apache-2.0',
    signatureStatus: PackageSignatureStatus.verified,
    permissions: const <String>['catalog:read', 'templates:import'],
    provenance: Uri.parse('https://github.com/nexu-io/open-design'),
    schemaValidated: true,
    archiveValidated: true,
    summary: 'Canonical source with release, hash, and license provenance.',
  ),
];
