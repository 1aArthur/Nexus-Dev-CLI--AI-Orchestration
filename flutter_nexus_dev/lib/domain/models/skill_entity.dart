import 'package:freezed_annotation/freezed_annotation.dart';

part 'skill_entity.freezed.dart';
part 'skill_entity.g.dart';

@freezed
abstract class SkillEntity with _$SkillEntity {
  const factory SkillEntity({
    required String id,
    required String name,
    required String description,
    required String category,
    @Default(true) bool enabled,
    @Default('') String version,
    @Default('') String author,
    @Default([]) List<String> tags,
  }) = _SkillEntity;

  factory SkillEntity.fromJson(Map<String, dynamic> json) => _$SkillEntityFromJson(json);
}
