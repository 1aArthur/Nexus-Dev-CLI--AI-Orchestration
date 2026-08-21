import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/features/usage/application/usage_controller.dart';
import 'package:nexus_mobile/features/usage/domain/usage.dart';

void main() {
  // Catches pagination that double-charges an estimate after the provider's
  // authoritative record arrives, or rewrites old catalog provenance.
  test('paginated provider report supersedes estimate without history drift', () {
    final controller = UsageController();

    controller.reconcilePage(
      <UsageLineItem>[
        _record(
          id: 'estimate',
          source: UsageSource.estimated,
          catalog: 'catalog-2026-07',
          costMicros: 900_000,
        ),
        _record(
          id: 'historical',
          reconciliationKey: 'historical-request',
          source: UsageSource.providerReported,
          catalog: 'catalog-2026-06',
          costMicros: 500_000,
        ),
      ],
      nextCursor: 'page-2',
    );
    expect(controller.nextCursor, 'page-2');

    controller.reconcilePage(
      <UsageLineItem>[
        _record(
          id: 'reported',
          source: UsageSource.providerReported,
          catalog: 'catalog-2026-08',
          costMicros: 1_100_000,
        ),
      ],
    );

    expect(controller.records().map((record) => record.id), <String>[
      'historical',
      'reported',
    ]);
    expect(
      controller.records().first.pricingCatalogVersion,
      'catalog-2026-06',
    );
    expect(controller.totalCostMicros, 1_600_000);
    expect(controller.nextCursor, isNull);
  });
}

UsageLineItem _record({
  required String id,
  String reconciliationKey = 'same-request',
  required UsageSource source,
  required String catalog,
  required int costMicros,
}) => UsageLineItem(
  id: id,
  reconciliationKey: reconciliationKey,
  provider: 'anthropic',
  exactModelId: 'provider/exact-snapshot',
  projectId: 'project-1',
  missionId: 'mission-1',
  agentId: 'agent-1',
  targetId: 'ssh-worker',
  inputTokens: 100,
  outputTokens: 50,
  costMicros: costMicros,
  currency: 'USD',
  source: source,
  pricingCatalogVersion: catalog,
  priceEffectiveAt: DateTime.utc(2026, 6),
  recordedAt: DateTime.utc(2026, 8, id == 'historical' ? 1 : 21),
);
