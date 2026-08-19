import 'package:freezed_annotation/freezed_annotation.dart';
import 'vulnerability_severity.dart';

part 'security_finding.freezed.dart';
part 'security_finding.g.dart';

@freezed
abstract class SecurityFinding with _$SecurityFinding {
  const factory SecurityFinding({
    required String id,
    required String title,
    required VulnerabilitySeverity severity,
    required String cwe,
    @Default('') String masvsRef,
    @Default('') String masvsCategory,
    @Default('') String component,
    @Default(0) int line,
    @Default(0) int lineNumber,
    @Default('') String filePath,
    @Default('') String description,
    @Default('') String recommendation,
    @Default('') String originalSnippet,
    @Default('') String vulnerableCodeSnippet,
    @Default('') String patchSnippet,
    @Default('') String remediationPatch,
    @Default(0.95) double confidence,
    @Default(true) bool autoFixAvailable,
  }) = _SecurityFinding;

  factory SecurityFinding.fromJson(Map<String, dynamic> json) => _$SecurityFindingFromJson(json);
}
