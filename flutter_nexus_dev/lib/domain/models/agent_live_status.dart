import 'package:freezed_annotation/freezed_annotation.dart';
import 'agent_type.dart';
import 'agent_state.dart';

part 'agent_live_status.freezed.dart';
part 'agent_live_status.g.dart';

@freezed
abstract class AgentLiveStatus with _$AgentLiveStatus {
  const factory AgentLiveStatus({
    required AgentType agentType,
    @Default(AgentState.idle()) AgentState state,
    @Default('Standby') String currentTask,
    @Default(0.0) double progress,
    @Default('') String thoughts,
    @Default(0) int activeTokens,
    @Default(42) int latencyMs,
  }) = _AgentLiveStatus;

  factory AgentLiveStatus.fromJson(Map<String, dynamic> json) => _$AgentLiveStatusFromJson(json);
}

extension AgentLiveStatusX on AgentLiveStatus {
  Color get statusColor => state.map(
    idle: (_) => const Color(0xFF666666),
    planning: (_) => const Color(0xFF00FFFF),
    researching: (_) => const Color(0xFFBB86FC),
    architecting: (_) => const Color(0xFF8B5CF6),
    writingCode: (_) => const Color(0xFF00FF88),
    auditing: (_) => const Color(0xFFFFB800),
    compiling: (_) => const Color(0xFFFF3366),
    testing: (_) => const Color(0xFF06B6D4),
    profiling: (_) => const Color(0xFF10B981),
    reviewing: (_) => const Color(0xFFA855F7),
    deploying: (_) => const Color(0xFF6366F1),
    completed: (_) => const Color(0xFF10B981),
    error: (_) => const Color(0xFFEF4444),
  );
}
