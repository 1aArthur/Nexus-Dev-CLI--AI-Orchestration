import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_debate_entity.freezed.dart';
part 'agent_debate_entity.g.dart';

@freezed
abstract class AgentDebateEntity with _$AgentDebateEntity {
  const factory AgentDebateEntity({
    required String id,
    required String topic,
    required String claudeArgument,
    required String codexArgument,
    required String evaluatorVerdict,
    required double convergenceScore,
    required int roundNumber,
    required int timestamp,
  }) = _AgentDebateEntity;

  factory AgentDebateEntity.fromJson(Map<String, dynamic> json) => _$AgentDebateEntityFromJson(json);
}
