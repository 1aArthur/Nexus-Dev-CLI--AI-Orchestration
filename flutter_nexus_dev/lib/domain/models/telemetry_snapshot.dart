import 'package:freezed_annotation/freezed_annotation.dart';

part 'telemetry_snapshot.freezed.dart';
part 'telemetry_snapshot.g.dart';

@freezed
abstract class TelemetrySnapshot with _$TelemetrySnapshot {
  const factory TelemetrySnapshot({
    @Default(12.4) double cpuPercent,
    @Default(94.2) double memoryUsageMb,
    @Default(8) int activeThreads,
    @Default(48) int latencyMs,
    @Default(24) int totalRequests,
    @Default(15200) int totalTokens,
    @Default(0.0024) double sessionCostUsd,
  }) = _TelemetrySnapshot;

  factory TelemetrySnapshot.fromJson(Map<String, dynamic> json) => _$TelemetrySnapshotFromJson(json);
}
