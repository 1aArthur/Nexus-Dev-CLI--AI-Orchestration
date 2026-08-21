import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/features/usage/application/usage_controller.dart';
import 'package:nexus_mobile/features/usage/domain/usage.dart';
import 'package:nexus_mobile/features/usage/presentation/credits_screen.dart';

void main() {
  // Catches a credits UI that merges estimates into authoritative charges or
  // hides the hard-stop budget remaining from the user.
  testWidgets('credits distinguish estimates, reports, units, and hard budget', (
    tester,
  ) async {
    final controller = UsageController(
      budget: const HardBudget(limitMicros: 10_000_000, currency: 'USD'),
    )..reconcilePage(<UsageLineItem>[
      _usage(
        id: 'estimate-1',
        reconciliationKey: 'request-estimate',
        source: UsageSource.estimated,
        costMicros: 1_250_000,
      ),
      _usage(
        id: 'reported-1',
        reconciliationKey: 'request-reported',
        source: UsageSource.providerReported,
        costMicros: 2_000_000,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: CreditsScreen(controller: controller)),
    );

    expect(find.byKey(const Key('credits-center')), findsOneWidget);
    expect(find.text('Estimated cost'), findsOneWidget);
    expect(find.text('Provider-reported charge'), findsOneWidget);
    expect(find.textContaining('Hard budget remaining'), findsOneWidget);
    expect(find.text('Reasoning · 300'), findsWidgets);
    expect(find.text('Cache read · 120'), findsWidgets);
    expect(find.text('Audio in/out · 12/8'), findsWidgets);
    expect(find.text('Media/tool units · 2/3'), findsWidgets);
  });

  // Catches exports that lose the catalog version, effective date, or charge
  // provenance needed to reproduce historical cost calculations.
  test('CSV and JSON exports preserve pricing and charge provenance', () {
    final controller = UsageController()..reconcilePage(<UsageLineItem>[
      _usage(
        id: 'reported-export',
        reconciliationKey: 'export-key',
        source: UsageSource.providerReported,
        costMicros: 2_000_000,
      ),
    ]);

    final json = controller.exportJson();
    final csv = controller.exportCsv();

    expect(json, contains('"source":"provider_reported"'));
    expect(json, contains('"pricingCatalogVersion":"catalog-2026-08"'));
    expect(json, contains('"priceEffectiveAt":"2026-08-01T00:00:00.000Z"'));
    expect(csv, contains('source,pricing_catalog_version,price_effective_at'));
    expect(csv, contains('provider_reported,catalog-2026-08'));
  });

  // Catches filter regressions that ignore any one Task 9 dimension and show
  // costs from the wrong mission, agent, project, or execution target.
  test('usage filters apply every supported attribution dimension', () {
    final controller = UsageController()..reconcilePage(<UsageLineItem>[
      _usage(
        id: 'match',
        reconciliationKey: 'match-key',
        source: UsageSource.providerReported,
        costMicros: 1,
      ),
      _usage(
        id: 'other',
        reconciliationKey: 'other-key',
        source: UsageSource.providerReported,
        costMicros: 1,
        agentId: 'agent-other',
      ),
    ]);

    final visible = controller.records(
      const UsageFilter(
        provider: 'openai',
        exactModelId: 'provider/exact-snapshot',
        projectId: 'project-1',
        missionId: 'mission-1',
        agentId: 'agent-1',
        targetId: 'github-actions',
      ),
    );

    expect(visible.map((record) => record.id), <String>['match']);
  });
}

UsageLineItem _usage({
  required String id,
  required String reconciliationKey,
  required UsageSource source,
  required int costMicros,
  String agentId = 'agent-1',
}) => UsageLineItem(
  id: id,
  reconciliationKey: reconciliationKey,
  provider: 'openai',
  exactModelId: 'provider/exact-snapshot',
  projectId: 'project-1',
  missionId: 'mission-1',
  agentId: agentId,
  targetId: 'github-actions',
  inputTokens: 1000,
  outputTokens: 500,
  cachedInputTokens: 120,
  reasoningTokens: 300,
  audioInputUnits: 12,
  audioOutputUnits: 8,
  mediaUnits: 2,
  toolUnits: 3,
  latencyMs: 420,
  failed: false,
  costMicros: costMicros,
  currency: 'USD',
  source: source,
  pricingCatalogVersion: 'catalog-2026-08',
  priceEffectiveAt: DateTime.utc(2026, 8),
  recordedAt: DateTime.utc(2026, 8, 21),
);
