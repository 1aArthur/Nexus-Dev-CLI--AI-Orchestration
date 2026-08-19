import 'package:freezed_annotation/freezed_annotation.dart';

part 'pipeline_run_entity.freezed.dart';
part 'pipeline_run_entity.g.dart';

@freezed
abstract class PipelineRunEntity with _$PipelineRunEntity {
  const factory PipelineRunEntity({
    required String id,
    required String pipelineName,
    required String targetEnvironment,
    required String status,
    @Default('') String stagesJson,
    required int startedAt,
    @Default(0) int finishedAt,
  }) = _PipelineRunEntity;

  factory PipelineRunEntity.fromJson(Map<String, dynamic> json) => _$PipelineRunEntityFromJson(json);
}
