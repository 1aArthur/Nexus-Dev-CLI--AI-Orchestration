import 'package:flutter/material.dart';

import '../../../design/tokens.dart';
import '../application/usage_controller.dart';
import '../domain/usage.dart';

class CreditsScreen extends StatelessWidget {
  CreditsScreen({UsageController? controller, super.key})
    : controller = controller ?? UsageController();

  final UsageController controller;

  @override
  Widget build(BuildContext context) {
    final records = controller.records();
    final remaining = controller.hardBudgetRemainingMicros;
    return SingleChildScrollView(
      key: const Key('credits-center'),
      padding: const EdgeInsets.all(NexusSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Credits center', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: NexusSpacing.x2),
          const Text(
            'Filters · Provider · Model · Project · Mission · Agent · Target',
          ),
          const SizedBox(height: NexusSpacing.x4),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(NexusSpacing.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Tracked total · ${_money(controller.totalCostMicros, records.firstOrNull?.currency ?? controller.budget?.currency ?? 'USD')}',
                  ),
                  const SizedBox(height: NexusSpacing.x2),
                  if (remaining != null)
                    Text(
                      'Hard budget remaining · ${_money(remaining, controller.budget!.currency)}',
                    )
                  else
                    const Text('Hard budget · Not configured'),
                  if (controller.hardBudgetExceeded)
                    const Text('Hard stop active · New paid work is blocked.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: NexusSpacing.x4),
          if (records.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(NexusSpacing.x4),
                child: Text(
                  'No usage received. Estimates and provider reports will remain visibly distinct.',
                ),
              ),
            )
          else
            ...records.map(_usageCard),
          const SizedBox(height: NexusSpacing.x4),
          const Text(
            'Exports · CSV + JSON include source, catalog version, effective date, and attribution.',
          ),
        ],
      ),
    );
  }

  Widget _usageCard(UsageLineItem record) => Padding(
    padding: const EdgeInsets.only(bottom: NexusSpacing.x3),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(NexusSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_chargeLabel(record.source)),
            const SizedBox(height: NexusSpacing.x1),
            Text('${record.provider} · ${record.exactModelId}'),
            Text(_money(record.costMicros, record.currency)),
            const SizedBox(height: NexusSpacing.x2),
            Text('Tokens in/out · ${record.inputTokens}/${record.outputTokens}'),
            Text('Reasoning · ${record.reasoningTokens}'),
            Text('Cache read · ${record.cachedInputTokens}'),
            Text('Audio in/out · ${record.audioInputUnits}/${record.audioOutputUnits}'),
            Text('Media/tool units · ${record.mediaUnits}/${record.toolUnits}'),
            Text('Latency · ${record.latencyMs} ms · Failure · ${record.failed ? 'Yes' : 'No'}'),
            Text(
              'Catalog · ${record.pricingCatalogVersion} · Effective ${record.priceEffectiveAt.toUtc().toIso8601String()}',
            ),
            Text(
              'Project ${record.projectId} · Mission ${record.missionId} · Agent ${record.agentId} · Target ${record.targetId}',
            ),
          ],
        ),
      ),
    ),
  );
}

String _chargeLabel(UsageSource source) => switch (source) {
  UsageSource.estimated => 'Estimated cost',
  UsageSource.providerReported => 'Provider-reported charge',
  UsageSource.adjusted => 'Adjusted charge',
};

String _money(int micros, String currency) =>
    '$currency ${(micros / 1000000).toStringAsFixed(4)}';
