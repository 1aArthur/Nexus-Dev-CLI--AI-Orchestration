import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/core/api/generated/contracts.dart';
import 'package:nexus_mobile/features/execution/application/execution_controller.dart';
import 'package:nexus_mobile/features/execution/domain/execution_target.dart';

void main() {
  test('local target exposes bounded native operations and no shell prompt', () {
    const target = ExecutionTarget(
      id: 'local',
      displayName: 'This device',
      kind: ExecutionTargetKind.device,
      status: ExecutionTargetStatus.available,
      capabilities: <ExecutionCapability>[ExecutionCapability.safeNative],
      approvalMode: ApprovalMode.neverForSafeNative,
    );

    final policy = ExecutionTargetPolicy.forTarget(target);

    expect(policy.acceptsArbitraryCommands, isFalse);
    expect(policy.supportsBatchDispatch, isFalse);
    expect(policy.nativeOperations, contains(SafeNativeOperation.hashFile));
    expect(policy.shells, isEmpty);
  });

  test('GitHub Actions is batch-only even when a terminal label is supplied', () {
    const target = ExecutionTarget(
      id: 'actions',
      displayName: 'GitHub Actions',
      kind: ExecutionTargetKind.githubActions,
      status: ExecutionTargetStatus.available,
      capabilities: <ExecutionCapability>[
        ExecutionCapability.terminal,
        ExecutionCapability.longRunning,
        ExecutionCapability.writeRepository,
      ],
      approvalMode: ApprovalMode.alwaysAsk,
    );

    final policy = ExecutionTargetPolicy.forTarget(
      target,
      estimatedCostMicros: 340000,
    );

    expect(policy.acceptsArbitraryCommands, isFalse);
    expect(policy.supportsBatchDispatch, isTrue);
    expect(policy.shells, isEmpty);
    expect(policy.requiresExplicitConfirmation, isTrue);
    expect(policy.estimatedCostMicros, 340000);
  });

  test('interactive shells appear only for compatible remote targets', () {
    const target = ExecutionTarget(
      id: 'codespace',
      displayName: 'Codespace',
      kind: ExecutionTargetKind.codespaces,
      status: ExecutionTargetStatus.available,
      capabilities: <ExecutionCapability>[
        ExecutionCapability.terminal,
        ExecutionCapability.network,
      ],
      approvalMode: ApprovalMode.policy,
    );

    final policy = ExecutionTargetPolicy.forTarget(
      target,
      advertisedShells: const <TerminalShell>{
        TerminalShell.bash,
        TerminalShell.zsh,
        TerminalShell.fish,
        TerminalShell.nushell,
      },
    );

    expect(policy.acceptsArbitraryCommands, isTrue);
    expect(policy.shells, contains(TerminalShell.nushell));
    expect(policy.requiresExplicitConfirmation, isTrue);
  });
}
