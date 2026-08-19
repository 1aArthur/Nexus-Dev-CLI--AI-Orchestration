import 'package:freezed_annotation/freezed_annotation.dart';
import 'vulnerability_severity.dart';
import 'security_finding.dart';

part 'masvs_category_metric.freezed.dart';
part 'masvs_category_metric.g.dart';

@freezed
abstract class MasvsCategoryMetric with _$MasvsCategoryMetric {
  const factory MasvsCategoryMetric({
    required String categoryCode,
    required String categoryName,
    required int findingsCount,
    required VulnerabilitySeverity maxSeverity,
    required bool isCompliant,
  }) = _MasvsCategoryMetric;

  factory MasvsCategoryMetric.fromJson(Map<String, dynamic> json) => _$MasvsCategoryMetricFromJson(json);
}
