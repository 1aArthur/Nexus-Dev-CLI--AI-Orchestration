import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

part 'local_storage.g.dart';

@riverpod
Future<void> hiveInit(HiveInitRef ref) async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(SkillEntityAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(McpToolEntityAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TerminalCommandEntityAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(AgentWorkflowEntityAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ProjectBrainEntityAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(AgentDebateEntityAdapter());
  if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(SecurityAuditEntityAdapter());
  if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(PipelineRunEntityAdapter());
  await Hive.openBox<SkillEntity>('skills');
  await Hive.openBox<McpToolEntity>('mcp_tools');
  await Hive.openBox<TerminalCommandEntity>('terminal_history');
  await Hive.openBox<AgentWorkflowEntity>('workflows');
  await Hive.openBox<ProjectBrainEntity>('project_brain');
  await Hive.openBox<AgentDebateEntity>('debates');
  await Hive.openBox<SecurityAuditEntity>('security_audits');
  await Hive.openBox<PipelineRunEntity>('pipeline_runs');
}

@riverpod
Box<SkillEntity> skillsBox(SkillsBoxRef ref) => Hive.box<SkillEntity>('skills');

@riverpod
Box<McpToolEntity> mcpToolsBox(McpToolsBoxRef ref) => Hive.box<McpToolEntity>('mcp_tools');

@riverpod
Box<TerminalCommandEntity> terminalHistoryBox(TerminalHistoryBoxRef ref) => Hive.box<TerminalCommandEntity>('terminal_history');

@riverpod
Box<AgentWorkflowEntity> workflowsBox(WorkflowsBoxRef ref) => Hive.box<AgentWorkflowEntity>('workflows');

@riverpod
Box<ProjectBrainEntity> projectBrainBox(ProjectBrainBoxRef ref) => Hive.box<ProjectBrainEntity>('project_brain');

@riverpod
Box<AgentDebateEntity> debatesBox(DebatesBoxRef ref) => Hive.box<AgentDebateEntity>('debates');

@riverpod
Box<SecurityAuditEntity> securityAuditsBox(SecurityAuditsBoxRef ref) => Hive.box<SecurityAuditEntity>('security_audits');

@riverpod
Box<PipelineRunEntity> pipelineRunsBox(PipelineRunsBoxRef ref) => Hive.box<PipelineRunEntity>('pipeline_runs');
