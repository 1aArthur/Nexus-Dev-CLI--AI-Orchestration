import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_type.freezed.dart';
part 'agent_type.g.dart';

@freezed
abstract class AgentType with _$AgentType {
  const factory AgentType.planner({
    @Default('Planner Agent') String displayName,
    @Default('Decomposes complex requests into task execution DAG') String roleDescription,
    @Default('gemini-3.1-pro-preview') String defaultModel,
    @Default(0xFF00FFFF) int badgeColorHex,
  }) = PlannerAgent;

  const factory AgentType.architect({
    @Default('Architect Agent') String displayName,
    @Default('System architecture design, module graph & ADR creation') String roleDescription,
    @Default('gemini-3.1-pro-preview') String defaultModel,
    @Default(0xFF818CF8) int badgeColorHex,
  }) = ArchitectAgent;

  const factory AgentType.claudeCode({
    @Default('Claude Code Agent') String displayName,
    @Default('Senior Code Architect & High-Level Refactoring Engine') String roleDescription,
    @Default('gemini-3.1-pro-preview') String defaultModel,
    @Default(0xFF8B5CF6) int badgeColorHex,
  }) = ClaudeCodeAgent;

  const factory AgentType.codex({
    @Default('Codex Native Agent') String displayName,
    @Default('High-Performance Logic Synthesizer, JNI & NDK Specialist') String roleDescription,
    @Default('gemini-3.1-pro-preview') String defaultModel,
    @Default(0xFF00F0FF) int badgeColorHex,
  }) = CodexAgent;

  const factory AgentType.exaResearcher({
    @Default('Exa Neural Researcher') String displayName,
    @Default('Deep Web Grounding, GitHub Issues & Tech Intelligence') String roleDescription,
    @Default('gemini-3.5-flash') String defaultModel,
    @Default(0xFFF59E0B) int badgeColorHex,
  }) = ExaResearcherAgent;

  const factory AgentType.debugAgent({
    @Default('Debug & Log Agent') String displayName,
    @Default('Log parser, stacktrace minimization & hypothesis testing') String roleDescription,
    @Default('gemini-3.1-pro-preview') String defaultModel,
    @Default(0xFFEC4899) int badgeColorHex,
  }) = DebugAgent;

  const factory AgentType.devSecOpsSentinel({
    @Default('DevSecOps Sentinel') String displayName,
    @Default('SAST/DAST Vulnerability Scanner, OWASP & CWE Auditor') String roleDescription,
    @Default('gemini-3.1-pro-preview') String defaultModel,
    @Default(0xFFEF4444) int badgeColorHex,
  }) = DevSecOpsSentinelAgent;

  const factory AgentType.performanceAgent({
    @Default('Performance Agent') String displayName,
    @Default('Memory allocation, GC pauses, DEX count & SIMD speedup') String roleDescription,
    @Default('gemini-3.5-flash') String defaultModel,
    @Default(0xFF10B981) int badgeColorHex,
  }) = PerformanceAgent;

  const factory AgentType.testAgent({
    @Default('Test Automator') String displayName,
    @Default('Unit, Robolectric JVM, regression & property-based tests') String roleDescription,
    @Default('gemini-3.5-flash') String defaultModel,
    @Default(0xFF06B6D4) int badgeColorHex,
  }) = TestAgent;

  const factory AgentType.reviewerAgent({
    @Default('Reviewer Agent') String displayName,
    @Default('Diff inspector, regression blocker & code standards') String roleDescription,
    @Default('gemini-3.1-pro-preview') String defaultModel,
    @Default(0xFFA855F7) int badgeColorHex,
  }) = ReviewerAgent;

  const factory AgentType.releaseAgent({
    @Default('Release Agent') String displayName,
    @Default('Changelog generator, versioning & CI/CD deployment') String roleDescription,
    @Default('gemini-3.5-flash') String defaultModel,
    @Default(0xFF6366F1) int badgeColorHex,
  }) = ReleaseAgent;

  const factory AgentType.nativeNdkEngineer({
    @Default('Native NDK Engineer') String displayName,
    @Default('C++20/Rust/JNI Bindings & CMake Build System Architect') String roleDescription,
    @Default('gemini-3.5-flash') String defaultModel,
    @Default(0xFF10B981) int badgeColorHex,
  }) = NativeNdkEngineerAgent;

  String get title => map(
    planner: (_) => _.displayName,
    architect: (_) => _.displayName,
    claudeCode: (_) => _.displayName,
    codex: (_) => _.displayName,
    exaResearcher: (_) => _.displayName,
    debugAgent: (_) => _.displayName,
    devSecOpsSentinel: (_) => _.displayName,
    performanceAgent: (_) => _.displayName,
    testAgent: (_) => _.displayName,
    reviewerAgent: (_) => _.displayName,
    releaseAgent: (_) => _.displayName,
    nativeNdkEngineer: (_) => _.displayName,
  );

  Color get badgeColor => map(
    planner: (_) => Color(_.badgeColorHex),
    architect: (_) => Color(_.badgeColorHex),
    claudeCode: (_) => Color(_.badgeColorHex),
    codex: (_) => Color(_.badgeColorHex),
    exaResearcher: (_) => Color(_.badgeColorHex),
    debugAgent: (_) => Color(_.badgeColorHex),
    devSecOpsSentinel: (_) => Color(_.badgeColorHex),
    performanceAgent: (_) => Color(_.badgeColorHex),
    testAgent: (_) => Color(_.badgeColorHex),
    reviewerAgent: (_) => Color(_.badgeColorHex),
    releaseAgent: (_) => Color(_.badgeColorHex),
    nativeNdkEngineer: (_) => Color(_.badgeColorHex),
  );
}

extension AgentTypeX on AgentType {
  static const List<AgentType> all = [
    AgentType.planner(),
    AgentType.architect(),
    AgentType.claudeCode(),
    AgentType.codex(),
    AgentType.exaResearcher(),
    AgentType.debugAgent(),
    AgentType.devSecOpsSentinel(),
    AgentType.performanceAgent(),
    AgentType.testAgent(),
    AgentType.reviewerAgent(),
    AgentType.releaseAgent(),
    AgentType.nativeNdkEngineer(),
  ];
}
