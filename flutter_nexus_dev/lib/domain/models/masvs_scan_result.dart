import 'package:freezed_annotation/freezed_annotation.dart';
import 'masvs_category_metric.dart';
import 'security_finding.dart';

part 'masvs_scan_result.freezed.dart';
part 'masvs_scan_result.g.dart';

@freezed
abstract class MasvsScanResult with _$MasvsScanResult {
  const factory MasvsScanResult({
    required String scanId,
    required String targetName,
    @Default(0) int timestamp,
    @Default(0) int linesScanned,
    @Default(0) int complianceScore,
    @Default('F') String complianceGrade,
    @Default(0) int totalVulnerabilities,
    @Default(0) int criticalCount,
    @Default(0) int highCount,
    @Default(0) int mediumCount,
    @Default(0) int lowCount,
    @Default([]) List<SecurityFinding> findings,
    @Default([]) List<MasvsCategoryMetric> categories,
    @Default(0) int scanDurationMs,
    @Default(0) int autoFixPatchesCount,
  }) = _MasvsScanResult;

  factory MasvsScanResult.fromJson(Map<String, dynamic> json) => _$MasvsScanResultFromJson(json);
}
