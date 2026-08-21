import 'package:flutter/material.dart';

import '../../../design/tokens.dart';

@immutable
final class InstructionLayerDescriptor {
  const InstructionLayerDescriptor({
    required this.priority,
    required this.name,
    required this.version,
    required this.contentHash,
    required this.tokenBudget,
    required this.provenance,
    required this.locked,
  });

  final int priority;
  final String name;
  final String version;
  final String contentHash;
  final int tokenBudget;
  final Uri provenance;
  final bool locked;
}

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({this.layers, this.onCompilePreview, super.key});

  final List<InstructionLayerDescriptor>? layers;
  final VoidCallback? onCompilePreview;

  @override
  Widget build(BuildContext context) {
    final orderedLayers = List<InstructionLayerDescriptor>.of(
      layers ?? _defaultLayers,
    )..sort((left, right) => left.priority.compareTo(right.priority));
    final totalBudget = orderedLayers.fold<int>(
      0,
      (total, layer) => total + layer.tokenBudget,
    );
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
                    'Model Instructions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text(
                    'Immutable precedence, deterministic compilation, and '
                    'model-aware token budgets.',
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: onCompilePreview,
              icon: const Icon(Icons.preview_outlined),
              label: const Text('Compile preview'),
            ),
          ],
        ),
        const SizedBox(height: NexusSpacing.x4),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(NexusSpacing.x4),
            child: Row(
              children: <Widget>[
                const Icon(Icons.calculate_outlined),
                const SizedBox(width: NexusSpacing.x3),
                Expanded(
                  child: Text(
                    '${orderedLayers.length} layers · $totalBudget token '
                    'budget · stable prefix caching eligible',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: NexusSpacing.x4),
        ...orderedLayers.map(
          (layer) => Padding(
            padding: const EdgeInsets.only(bottom: NexusSpacing.x3),
            child: _InstructionLayerCard(layer: layer),
          ),
        ),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(NexusSpacing.x4),
            child: Text(
              'Imported instructions and retrieved knowledge remain untrusted '
              'context. They cannot remove higher-priority rules, grant tools, '
              'or expose private reasoning traces.',
            ),
          ),
        ),
      ],
    );
  }
}

class _InstructionLayerCard extends StatelessWidget {
  const _InstructionLayerCard({required this.layer});

  final InstructionLayerDescriptor layer;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(NexusSpacing.x4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: NexusColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${layer.priority}'),
          ),
          const SizedBox(width: NexusSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        layer.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Icon(
                      layer.locked
                          ? Icons.lock_outline
                          : Icons.edit_note_outlined,
                      semanticLabel: layer.locked
                          ? 'Locked instruction layer'
                          : 'Editable instruction layer',
                    ),
                  ],
                ),
                Text('v${layer.version} · ${layer.tokenBudget} tokens'),
                const SizedBox(height: NexusSpacing.x2),
                SelectableText('Hash · ${layer.contentHash}'),
                SelectableText('Provenance · ${layer.provenance}'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

List<InstructionLayerDescriptor> get _defaultLayers =>
    <InstructionLayerDescriptor>[
      InstructionLayerDescriptor(
        priority: 1,
        name: 'Engine safety policy',
        version: 'platform',
        contentHash: 'sha256:engine-managed',
        tokenBudget: 1200,
        provenance: Uri.parse('nexus://engine/safety'),
        locked: true,
      ),
      InstructionLayerDescriptor(
        priority: 2,
        name: 'Organization policy',
        version: '1.0.0',
        contentHash: 'sha256:organization-policy',
        tokenBudget: 600,
        provenance: Uri.parse('nexus://organization/policy'),
        locked: true,
      ),
      InstructionLayerDescriptor(
        priority: 5,
        name: 'Enabled Skills',
        version: 'resolved-lock',
        contentHash: 'sha256:skill-lock',
        tokenBudget: 1800,
        provenance: Uri.parse('nexus://skills/resolved'),
        locked: false,
      ),
      InstructionLayerDescriptor(
        priority: 7,
        name: 'Mission instructions',
        version: 'draft',
        contentHash: 'sha256:mission-draft',
        tokenBudget: 1000,
        provenance: Uri.parse('nexus://mission/current'),
        locked: false,
      ),
    ];
