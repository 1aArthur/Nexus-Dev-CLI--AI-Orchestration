import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_state.freezed.dart';

@freezed
abstract class AgentState with _$AgentState {
  const factory AgentState.idle() = Idle;
  const factory AgentState.planning() = Planning;
  const factory AgentState.researching() = Researching;
  const factory AgentState.architecting() = Architecting;
  const factory AgentState.writingCode() = WritingCode;
  const factory AgentState.auditing() = Auditing;
  const factory AgentState.compiling() = Compiling;
  const factory AgentState.testing() = Testing;
  const factory AgentState.profiling() = Profiling;
  const factory AgentState.reviewing() = Reviewing;
  const factory AgentState.deploying() = Deploying;
  const factory AgentState.completed() = Completed;
  const factory AgentState.error(String message) = Error;
}

extension AgentStateX on AgentState {
  String get label => map(
    idle: (_) => 'IDLE',
    planning: (_) => 'PLANNING',
    researching: (_) => 'RESEARCHING',
    architecting: (_) => 'ARCHITECTING',
    writingCode: (_) => 'WRITING CODE',
    auditing: (_) => 'AUDITING',
    compiling: (_) => 'COMPILING',
    testing: (_) => 'TESTING',
    profiling: (_) => 'PROFILING',
    reviewing: (_) => 'REVIEWING',
    deploying: (_) => 'DEPLOYING',
    completed: (_) => 'COMPLETED',
    error: (_) => 'ERROR',
  );

  bool get isActive => map(
    idle: (_) => false,
    completed: (_) => false,
    error: (_) => false,
    _: (_) => true,
  );
}
