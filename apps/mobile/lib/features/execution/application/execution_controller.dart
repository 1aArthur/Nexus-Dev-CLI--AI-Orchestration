import 'package:flutter/foundation.dart';

import '../data/execution_socket.dart';
import '../domain/execution_target.dart';

enum TerminalShell { bash, zsh, fish, nushell }

enum SafeNativeOperation {
  hashFile,
  parseJson,
  redactDiagnostics,
  summarizeDiff,
}

final class ExecutionTargetPolicy {
  const ExecutionTargetPolicy({
    required this.acceptsArbitraryCommands,
    required this.supportsBatchDispatch,
    required this.nativeOperations,
    required this.shells,
    required this.requiresExplicitConfirmation,
    required this.estimatedCostMicros,
  });

  factory ExecutionTargetPolicy.forTarget(
    ExecutionTarget target, {
    Set<TerminalShell> advertisedShells = const <TerminalShell>{},
    int estimatedCostMicros = 0,
  }) {
    final isBatch = target.kind == ExecutionTargetKind.githubActions;
    final isInteractiveRemote =
        (target.kind == ExecutionTargetKind.codespaces ||
            target.kind == ExecutionTargetKind.sshWorker) &&
        target.capabilities.contains(ExecutionCapability.terminal);
    final nativeOperations =
        target.capabilities.contains(ExecutionCapability.safeNative)
        ? const <SafeNativeOperation>{
            SafeNativeOperation.hashFile,
            SafeNativeOperation.parseJson,
            SafeNativeOperation.redactDiagnostics,
            SafeNativeOperation.summarizeDiff,
          }
        : const <SafeNativeOperation>{};
    final sensitive = target.capabilities.any(
      <ExecutionCapability>{
        ExecutionCapability.writeRepository,
        ExecutionCapability.network,
        ExecutionCapability.secrets,
      }.contains,
    );
    return ExecutionTargetPolicy(
      acceptsArbitraryCommands: isInteractiveRemote,
      supportsBatchDispatch: isBatch,
      nativeOperations: nativeOperations,
      shells: isInteractiveRemote
          ? Set<TerminalShell>.unmodifiable(advertisedShells)
          : const <TerminalShell>{},
      requiresExplicitConfirmation:
          target.approvalMode == ApprovalMode.alwaysAsk ||
          (target.approvalMode == ApprovalMode.policy &&
              (sensitive || estimatedCostMicros > 0)),
      estimatedCostMicros: estimatedCostMicros,
    );
  }

  final bool acceptsArbitraryCommands;
  final bool supportsBatchDispatch;
  final Set<SafeNativeOperation> nativeOperations;
  final Set<TerminalShell> shells;
  final bool requiresExplicitConfirmation;
  final int estimatedCostMicros;
}

final class ExecutionState {
  const ExecutionState({
    this.executionId,
    this.lines = const <String>[],
    this.lastReceivedSequence = 0,
    this.lastAcknowledgedSequence = 0,
    this.isTerminal = false,
  });

  final String? executionId;
  final List<String> lines;
  final int lastReceivedSequence;
  final int lastAcknowledgedSequence;
  final bool isTerminal;
}

final class ExecutionController extends ChangeNotifier {
  ExecutionController({required this.socket, this.maximumLines = 500});

  final ExecutionSocket socket;
  final int maximumLines;
  ExecutionState _state = const ExecutionState();

  ExecutionState get state => _state;

  Future<void> connect(String executionId) async {
    _state = ExecutionState(executionId: executionId);
    await socket.connect(executionId: executionId, afterSequence: 0);
  }

  Future<void> reconnect() async {
    final executionId = _state.executionId;
    if (executionId == null) throw StateError('No execution to reconnect');
    await socket.connect(
      executionId: executionId,
      afterSequence: _state.lastAcknowledgedSequence,
    );
  }

  void ingest(ExecutionFrame frame) {
    if (frame.sequence <= _state.lastReceivedSequence) return;
    final lines = <String>[..._state.lines, frame.text];
    final firstRetained = lines.length > maximumLines
        ? lines.length - maximumLines
        : 0;
    _state = ExecutionState(
      executionId: _state.executionId,
      lines: List<String>.unmodifiable(lines.skip(firstRetained)),
      lastReceivedSequence: frame.sequence,
      lastAcknowledgedSequence: _state.lastAcknowledgedSequence,
      isTerminal:
          frame.kind == ExecutionFrameKind.completed ||
          frame.kind == ExecutionFrameKind.cancelled,
    );
    notifyListeners();
  }

  void acknowledge(int sequence) {
    _state = ExecutionState(
      executionId: _state.executionId,
      lines: _state.lines,
      lastReceivedSequence: _state.lastReceivedSequence,
      lastAcknowledgedSequence: sequence
          .clamp(_state.lastAcknowledgedSequence, _state.lastReceivedSequence)
          .toInt(),
      isTerminal: _state.isTerminal,
    );
    notifyListeners();
  }
}
