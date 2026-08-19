import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_brain_entity.freezed.dart';
part 'project_brain_entity.g.dart';

@freezed
abstract class ProjectBrainEntity with _$ProjectBrainEntity {
  const factory ProjectBrainEntity({
    required String id,
    required String title,
    required String category,
    required String status,
    required String content,
    required String lastUpdated,
  }) = _ProjectBrainEntity;

  factory ProjectBrainEntity.fromJson(Map<String, dynamic> json) => _$ProjectBrainEntityFromJson(json);
}
