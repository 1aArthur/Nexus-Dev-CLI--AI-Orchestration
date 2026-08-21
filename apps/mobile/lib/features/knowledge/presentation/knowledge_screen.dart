import 'package:flutter/material.dart';

import '../../../design/tokens.dart';

@immutable
final class KnowledgeBaseDescriptor {
  const KnowledgeBaseDescriptor({
    required this.name,
    required this.version,
    required this.documents,
    required this.chunks,
    required this.aclTags,
    required this.provenance,
    required this.contentHash,
    required this.validated,
  });

  final String name;
  final String version;
  final int documents;
  final int chunks;
  final List<String> aclTags;
  final Uri provenance;
  final String contentHash;
  final bool validated;
}

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({this.knowledgeBases, this.onImport, super.key});

  final List<KnowledgeBaseDescriptor>? knowledgeBases;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final bases = knowledgeBases ?? _defaultKnowledgeBases;
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
                    'Knowledge Vault',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text(
                    'Fast NKB packages with auditable sources and ACL-first '
                    'hybrid retrieval.',
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Import .nkb'),
            ),
          ],
        ),
        const SizedBox(height: NexusSpacing.x4),
        const _KnowledgeArchitectureCard(),
        const SizedBox(height: NexusSpacing.x4),
        ...bases.map(
          (base) => Padding(
            padding: const EdgeInsets.only(bottom: NexusSpacing.x3),
            child: _KnowledgeCard(base: base),
          ),
        ),
      ],
    );
  }
}

class _KnowledgeArchitectureCard extends StatelessWidget {
  const _KnowledgeArchitectureCard();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(NexusSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Optimized portable format',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: NexusSpacing.x2),
          const Wrap(
            spacing: NexusSpacing.x2,
            runSpacing: NexusSpacing.x2,
            children: <Widget>[
              _KnowledgePill(label: 'Authoring · UTF-8 Markdown'),
              _KnowledgePill(label: 'Index · Apache Arrow IPC'),
              _KnowledgePill(label: 'Compression · Zstandard'),
              _KnowledgePill(label: 'Search · FTS + pgvector + RRF'),
            ],
          ),
          const SizedBox(height: NexusSpacing.x3),
          const Text(
            'Archives are verified and extracted before use. Tenant and '
            'project ACLs are applied before ranking; results retain source '
            'hashes and citations.',
          ),
        ],
      ),
    ),
  );
}

class _KnowledgeCard extends StatelessWidget {
  const _KnowledgeCard({required this.base});

  final KnowledgeBaseDescriptor base;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(NexusSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.menu_book_outlined),
              const SizedBox(width: NexusSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      base.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('NKB · v${base.version}'),
                  ],
                ),
              ),
              Chip(
                avatar: Icon(
                  base.validated
                      ? Icons.verified_outlined
                      : Icons.block_outlined,
                  size: 18,
                ),
                label: Text(base.validated ? 'Validated' : 'Blocked'),
              ),
            ],
          ),
          const SizedBox(height: NexusSpacing.x3),
          Text('${base.documents} documents · ${base.chunks} typed chunks'),
          Text('ACL tags · ${base.aclTags.join(', ')}'),
          const SizedBox(height: NexusSpacing.x2),
          SelectableText('Provenance · ${base.provenance}'),
          SelectableText('Content hash · ${base.contentHash}'),
        ],
      ),
    ),
  );
}

class _KnowledgePill extends StatelessWidget {
  const _KnowledgePill({required this.label});

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
    child: Text(label),
  );
}

List<KnowledgeBaseDescriptor> get _defaultKnowledgeBases =>
    <KnowledgeBaseDescriptor>[
      KnowledgeBaseDescriptor(
        name: 'Software Engineering Core',
        version: '1.0.0',
        documents: 16,
        chunks: 384,
        aclTags: const <String>['owner', 'project:nexus'],
        provenance: Uri.parse(
          'https://github.com/1aArthur/Nexus-Dev-CLI--AI-Orchestration',
        ),
        contentHash: 'sha256:catalog-pinned-at-ingestion',
        validated: true,
      ),
    ];
