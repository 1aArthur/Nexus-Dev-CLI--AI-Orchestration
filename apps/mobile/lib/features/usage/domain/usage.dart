import '../../../core/api/generated/contracts.dart';

enum UsageSource { providerReported, estimated, adjusted }

final class UsageRecord {
  const UsageRecord();

  factory UsageRecord.fromDto(UsageRecordDto dto) => throw UnimplementedError();

  UsageSource get source => throw UnimplementedError();

  bool get isEstimate => throw UnimplementedError();
}
