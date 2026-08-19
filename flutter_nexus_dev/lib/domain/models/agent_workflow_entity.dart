import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_workflow_entity.freezed.dart';
part 'agent_workflow_entity.g.dart';

@freezed
abstract class AgentWorkflowEntity with _$AgentWorkflowEntity {
  const factory AgentWorkflowEntity({
    required String id,
    required String name,
    required String goal,
    required String status,
    @Default('') String result,
    required int createdAt,
    @Default(0) int updatedAt,
    @Default([]) List<String> agentTypes,
  }) = _AgentWorkflowEntity;

  factory AgentWorkflowEntity.fromJson(Map<String, dynamic> json) => _$AgentWorkflowEntityFromJson(json);
}
