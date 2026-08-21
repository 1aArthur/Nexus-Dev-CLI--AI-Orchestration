import '../../../core/api/generated/contracts.dart';

enum UsageSource { providerReported, estimated, adjusted }

final class UsageRecord {
  const UsageRecord({
    required this.id,
    required this.missionId,
    required this.provider,
    required this.exactModelId,
    required this.inputTokens,
    required this.outputTokens,
    required this.costMicros,
    required this.currency,
    required this.source,
    required this.recordedAt,
    this.cachedInputTokens,
  });

  factory UsageRecord.fromDto(UsageRecordDto dto) => UsageRecord(
    id: dto.id,
    missionId: dto.missionId,
    provider: dto.provider,
    exactModelId: dto.exactModelId,
    inputTokens: dto.inputTokens,
    outputTokens: dto.outputTokens,
    cachedInputTokens: dto.cachedInputTokens,
    costMicros: dto.costMicros,
    currency: dto.currency,
    source: switch (dto.provenance) {
      UsageProvenance.providerReported => UsageSource.providerReported,
      UsageProvenance.estimated => UsageSource.estimated,
      UsageProvenance.adjusted => UsageSource.adjusted,
    },
    recordedAt: dto.recordedAt,
  );

  final String id;
  final String missionId;
  final String provider;
  final String exactModelId;
  final int inputTokens;
  final int outputTokens;
  final int? cachedInputTokens;
  final int costMicros;
  final String currency;
  final UsageSource source;
  final DateTime recordedAt;

  bool get isEstimate => source == UsageSource.estimated;
}
