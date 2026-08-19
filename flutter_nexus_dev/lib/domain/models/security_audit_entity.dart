import 'package:freezed_annotation/freezed_annotation.dart';

part 'security_audit_entity.freezed.dart';
part 'security_audit_entity.g.dart';

@freezed
abstract class SecurityAuditEntity with _$SecurityAuditEntity {
  const factory SecurityAuditEntity({
    required String id,
    required String projectName,
    required String codeSnippet,
    required String findingsJson,
    @Default(false) bool autoFixApproved,
    required int timestamp,
  }) = _SecurityAuditEntity;

  factory SecurityAuditEntity.fromJson(Map<String, dynamic> json) => _$SecurityAuditEntityFromJson(json);
}
