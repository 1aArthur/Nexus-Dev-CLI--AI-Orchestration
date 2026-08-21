import 'package:flutter/material.dart';

import '../../../design/components/status_badge.dart';
import '../../../design/tokens.dart';
import '../domain/engine_contract.dart';

class EngineLabScreen extends StatelessWidget {
  const EngineLabScreen({
    this.engines = EngineCatalog.current,
    super.key,
  });

  final List<EngineDescriptor> engines;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('engine-lab'),
      padding: const EdgeInsets.all(NexusSpacing.x4),
      children: <Widget>[
        Text('Nexus Engine Lab', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: NexusSpacing.x2),
        const Text(
          'One engine owns each browsing context. No alternative runtime is bundled in the production package.',
        ),
        const SizedBox(height: NexusSpacing.x4),
        ...engines.map(_engineCard),
      ],
    );
  }

  Widget _engineCard(EngineDescriptor engine) => Padding(
    padding: const EdgeInsets.only(bottom: NexusSpacing.x3),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(NexusSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    engine.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                StatusBadge(
                  label: engine.availability.label,
                  symbol: engine.availability == EngineAvailability.available
                      ? Icons.check_circle_outline
                      : Icons.lock_outline,
                ),
              ],
            ),
            const SizedBox(height: NexusSpacing.x2),
            Text(engine.role.label),
            const SizedBox(height: NexusSpacing.x1),
            Text(engine.summary),
            const SizedBox(height: NexusSpacing.x2),
            Text(engine.bundled ? 'Bundled in app' : 'Not bundled in app'),
          ],
        ),
      ),
    ),
  );
}
