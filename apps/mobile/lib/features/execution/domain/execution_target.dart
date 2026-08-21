import '../../../core/api/generated/contracts.dart';

enum ExecutionCapability {
  safeNative,
  readRepository,
  writeRepository,
  network,
  terminal,
  longRunning,
  secrets,
  gpu,
}

final class ExecutionTarget {
  const ExecutionTarget({
    required this.id,
    required this.displayName,
    required this.kind,
    required this.status,
    required this.capabilities,
    required this.approvalMode,
  });

  factory ExecutionTarget.fromDto(ExecutionTargetDto dto) => ExecutionTarget(
    id: dto.id,
    displayName: dto.displayName,
    kind: dto.kind,
    status: dto.status,
    capabilities: List<ExecutionCapability>.unmodifiable(
      dto.capabilities.map(_executionCapability),
    ),
    approvalMode: dto.approvalMode,
  );

  final String id;
  final String displayName;
  final ExecutionTargetKind kind;
  final ExecutionTargetStatus status;
  final List<ExecutionCapability> capabilities;
  final ApprovalMode approvalMode;

  bool get requiresApproval => approvalMode != ApprovalMode.neverForSafeNative;
}

ExecutionCapability _executionCapability(String value) => switch (value) {
  'safe_native' => ExecutionCapability.safeNative,
  'read_repository' => ExecutionCapability.readRepository,
  'write_repository' => ExecutionCapability.writeRepository,
  'network' => ExecutionCapability.network,
  'terminal' => ExecutionCapability.terminal,
  'long_running' => ExecutionCapability.longRunning,
  'secrets' => ExecutionCapability.secrets,
  'gpu' => ExecutionCapability.gpu,
  _ => throw FormatException('Unknown execution capability: $value'),
};
