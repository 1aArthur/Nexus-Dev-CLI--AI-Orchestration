import 'package:flutter/material.dart';

import '../../../design/tokens.dart';
import '../../extensions/domain/package_descriptor.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({this.pets, this.onActivate, this.onImport, super.key});

  final List<PackageDescriptor>? pets;
  final ValueChanged<PackageDescriptor>? onActivate;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final catalog = pets ?? _defaultPets;
    return ListView(
      padding: const EdgeInsets.all(NexusSpacing.x4),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Pet Packs',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text(
                    'Original built-ins and externally licensed NPET packs.',
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.add_outlined),
              label: const Text('Add external'),
            ),
          ],
        ),
        const SizedBox(height: NexusSpacing.x4),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(NexusSpacing.x4),
            child: Text(
              'Pet assets are isolated from agent instructions and tools. '
              'Imports require bounded frames, hashes, signatures, and a '
              'redistributable license.',
            ),
          ),
        ),
        const SizedBox(height: NexusSpacing.x4),
        ...catalog.map(
          (pet) => Padding(
            padding: const EdgeInsets.only(bottom: NexusSpacing.x3),
            child: _PetCard(
              pet: pet,
              onActivate: onActivate == null ? null : () => onActivate!(pet),
            ),
          ),
        ),
      ],
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, this.onActivate});

  final PackageDescriptor pet;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context) {
    final available = pet.activationAllowed;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NexusSpacing.x4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                border: Border.all(color: NexusColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.pets_outlined, size: 32),
            ),
            const SizedBox(width: NexusSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    pet.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: NexusSpacing.x1),
                  Text('${pet.license} · ${pet.signatureLabel}'),
                  const SizedBox(height: NexusSpacing.x1),
                  Text('Provenance · ${pet.provenance}'),
                  const SizedBox(height: NexusSpacing.x2),
                  Text(
                    available
                        ? 'Available · validated NPET metadata'
                        : 'Unavailable · authorized redistributable source required',
                  ),
                  const SizedBox(height: NexusSpacing.x3),
                  FilledButton(
                    onPressed: available && onActivate != null
                        ? onActivate
                        : null,
                    child: const Text('Activate'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<PackageDescriptor> get _defaultPets => <PackageDescriptor>[
  PackageDescriptor(
    id: 'nexus.nox',
    name: 'Nox · OLED fox',
    version: '1.0.0',
    kind: PackageKind.pet,
    license: 'Apache-2.0',
    signatureStatus: PackageSignatureStatus.verified,
    permissions: const <String>[],
    provenance: Uri.parse(
      'https://github.com/1aArthur/Nexus-Dev-CLI--AI-Orchestration',
    ),
    schemaValidated: true,
    archiveValidated: true,
    summary: 'Original Nexus pet.',
  ),
  PackageDescriptor(
    id: 'openai.pet.connector',
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
  PackageDescriptor(
    id: 'anthropic.pet.connector',
    name: 'Anthropic Pet connector',
    version: 'catalog',
    kind: PackageKind.pet,
    license: 'License/source required',
    signatureStatus: PackageSignatureStatus.unverified,
    permissions: const <String>[],
    provenance: Uri.parse('https://anthropic.com'),
    schemaValidated: true,
    archiveValidated: false,
    authorizedSource: false,
  ),
];
