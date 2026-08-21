import 'dart:convert';

import '../domain/usage.dart';

final class HardBudget {
  const HardBudget({required this.limitMicros, required this.currency})
    : assert(limitMicros >= 0);

  final int limitMicros;
  final String currency;
}

final class UsageFilter {
  const UsageFilter({
    this.provider,
    this.exactModelId,
    this.projectId,
    this.missionId,
    this.agentId,
    this.targetId,
  });

  final String? provider;
  final String? exactModelId;
  final String? projectId;
  final String? missionId;
  final String? agentId;
  final String? targetId;

  bool matches(UsageLineItem record) =>
      (provider == null || record.provider == provider) &&
      (exactModelId == null || record.exactModelId == exactModelId) &&
      (projectId == null || record.projectId == projectId) &&
      (missionId == null || record.missionId == missionId) &&
      (agentId == null || record.agentId == agentId) &&
      (targetId == null || record.targetId == targetId);
}

final class UsageLineItem {
  const UsageLineItem({
    required this.id,
    required this.reconciliationKey,
    required this.provider,
    required this.exactModelId,
    required this.projectId,
    required this.missionId,
    required this.agentId,
    required this.targetId,
    required this.inputTokens,
    required this.outputTokens,
    required this.costMicros,
    required this.currency,
    required this.source,
    required this.pricingCatalogVersion,
    required this.priceEffectiveAt,
    required this.recordedAt,
    this.cachedInputTokens = 0,
    this.reasoningTokens = 0,
    this.audioInputUnits = 0,
    this.audioOutputUnits = 0,
    this.mediaUnits = 0,
    this.toolUnits = 0,
    this.latencyMs = 0,
    this.failed = false,
  });

  final String id;
  final String reconciliationKey;
  final String provider;
  final String exactModelId;
  final String projectId;
  final String missionId;
  final String agentId;
  final String targetId;
  final int inputTokens;
  final int outputTokens;
  final int cachedInputTokens;
  final int reasoningTokens;
  final int audioInputUnits;
  final int audioOutputUnits;
  final int mediaUnits;
  final int toolUnits;
  final int latencyMs;
  final bool failed;
  final int costMicros;
  final String currency;
  final UsageSource source;
  final String pricingCatalogVersion;
  final DateTime priceEffectiveAt;
  final DateTime recordedAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'reconciliationKey': reconciliationKey,
    'provider': provider,
    'exactModelId': exactModelId,
    'projectId': projectId,
    'missionId': missionId,
    'agentId': agentId,
    'targetId': targetId,
    'inputTokens': inputTokens,
    'outputTokens': outputTokens,
    'cachedInputTokens': cachedInputTokens,
    'reasoningTokens': reasoningTokens,
    'audioInputUnits': audioInputUnits,
    'audioOutputUnits': audioOutputUnits,
    'mediaUnits': mediaUnits,
    'toolUnits': toolUnits,
    'latencyMs': latencyMs,
    'failed': failed,
    'costMicros': costMicros,
    'currency': currency,
    'source': _sourceWireName(source),
    'pricingCatalogVersion': pricingCatalogVersion,
    'priceEffectiveAt': priceEffectiveAt.toUtc().toIso8601String(),
    'recordedAt': recordedAt.toUtc().toIso8601String(),
  };
}

final class UsageController {
  UsageController({this.budget});

  final HardBudget? budget;
  final Map<String, UsageLineItem> _recordsById = <String, UsageLineItem>{};
  String? nextCursor;

  void reconcilePage(
    Iterable<UsageLineItem> page, {
    String? nextCursor,
  }) {
    for (final incoming in page) {
      final related = _recordsById.values
          .where(
            (record) =>
                record.reconciliationKey == incoming.reconciliationKey &&
                record.id != incoming.id,
          )
          .toList(growable: false);
      if (related.any(
        (record) => _sourceRank(record.source) > _sourceRank(incoming.source),
      )) {
        continue;
      }
      for (final record in related) {
        if (_sourceRank(record.source) <= _sourceRank(incoming.source)) {
          _recordsById.remove(record.id);
        }
      }
      _recordsById[incoming.id] = incoming;
    }
    this.nextCursor = nextCursor;
  }

  List<UsageLineItem> records([
    UsageFilter filter = const UsageFilter(),
  ]) {
    final visible = _recordsById.values.where(filter.matches).toList();
    visible.sort((left, right) {
      final time = left.recordedAt.compareTo(right.recordedAt);
      return time != 0 ? time : left.id.compareTo(right.id);
    });
    return List<UsageLineItem>.unmodifiable(visible);
  }

  int get totalCostMicros => _recordsById.values.fold<int>(
    0,
    (total, record) => total + record.costMicros,
  );

  int? get hardBudgetRemainingMicros => budget == null
      ? null
      : budget!.limitMicros - totalCostMicros;

  bool get hardBudgetExceeded => (hardBudgetRemainingMicros ?? 0) < 0;

  String exportJson([UsageFilter filter = const UsageFilter()]) => jsonEncode(
    records(filter).map((record) => record.toJson()).toList(growable: false),
  );

  String exportCsv([UsageFilter filter = const UsageFilter()]) {
    const headers = <String>[
      'id',
      'provider',
      'model',
      'project',
      'mission',
      'agent',
      'target',
      'input_tokens',
      'output_tokens',
      'cached_input_tokens',
      'reasoning_tokens',
      'audio_input_units',
      'audio_output_units',
      'media_units',
      'tool_units',
      'latency_ms',
      'failed',
      'cost_micros',
      'currency',
      'source',
      'pricing_catalog_version',
      'price_effective_at',
      'recorded_at',
    ];
    final rows = <String>[headers.join(',')];
    for (final record in records(filter)) {
      rows.add(
        <Object?>[
          record.id,
          record.provider,
          record.exactModelId,
          record.projectId,
          record.missionId,
          record.agentId,
          record.targetId,
          record.inputTokens,
          record.outputTokens,
          record.cachedInputTokens,
          record.reasoningTokens,
          record.audioInputUnits,
          record.audioOutputUnits,
          record.mediaUnits,
          record.toolUnits,
          record.latencyMs,
          record.failed,
          record.costMicros,
          record.currency,
          _sourceWireName(record.source),
          record.pricingCatalogVersion,
          record.priceEffectiveAt.toUtc().toIso8601String(),
          record.recordedAt.toUtc().toIso8601String(),
        ].map(_csvCell).join(','),
      );
    }
    return '${rows.join('\n')}\n';
  }
}

int _sourceRank(UsageSource source) => switch (source) {
  UsageSource.estimated => 0,
  UsageSource.adjusted => 1,
  UsageSource.providerReported => 2,
};

String _sourceWireName(UsageSource source) => switch (source) {
  UsageSource.providerReported => 'provider_reported',
  UsageSource.estimated => 'estimated',
  UsageSource.adjusted => 'adjusted',
};

String _csvCell(Object? value) {
  final text = value.toString();
  if (!text.contains(RegExp('[,"\\n\\r]'))) return text;
  return '"${text.replaceAll('"', '""')}"';
}
