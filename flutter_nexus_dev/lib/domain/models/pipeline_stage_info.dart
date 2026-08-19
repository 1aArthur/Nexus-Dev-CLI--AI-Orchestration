import 'package:freezed_annotation/freezed_annotation.dart';

part 'pipeline_stage_info.freezed.dart';
part 'pipeline_stage_info.g.dart';

@freezed
abstract class PipelineStageInfo with _$PipelineStageInfo {
  const factory PipelineStageInfo({
    required String name,
    @Default('PENDING') String status,
    @Default(0) int durationSeconds,
    @Default('') String logSummary,
  }) = _PipelineStageInfo;

  factory PipelineStageInfo.fromJson(Map<String, dynamic> json) => _$PipelineStageInfoFromJson(json);
}

extension PipelineStageInfoX on PipelineStageInfo {
  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'RUNNING':
        return const Color(0xFF00FFFF);
      case 'SUCCESS':
        return const Color(0xFF00FF88);
      case 'FAILED':
        return const Color(0xFFFF3366);
      default:
        return const Color(0xFF666666);
    }
  }

  String get statusIcon {
    switch (status.toUpperCase()) {
      case 'RUNNING':
        return '⏳';
      case 'SUCCESS':
        return '✓';
      case 'FAILED':
        return '✗';
      default:
        return '○';
    }
  }
}
