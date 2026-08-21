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
  }) => const ExecutionTargetPolicy(
    acceptsArbitraryCommands: false,
    supportsBatchDispatch: false,
    nativeOperations: <SafeNativeOperation>{},
    shells: <TerminalShell>{},
    requiresExplicitConfirmation: false,
    estimatedCostMicros: 0,
  );

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
    await socket.connect(executionId: _state.executionId!, afterSequence: 0);
  }

  void ingest(ExecutionFrame frame) {
    _state = ExecutionState(
      executionId: _state.executionId,
      lines: <String>[..._state.lines, frame.text],
      lastReceivedSequence: frame.sequence,
      lastAcknowledgedSequence: _state.lastAcknowledgedSequence,
    );
    notifyListeners();
  }

  void acknowledge(int sequence) {
    _state = ExecutionState(
      executionId: _state.executionId,
      lines: _state.lines,
      lastReceivedSequence: _state.lastReceivedSequence,
      lastAcknowledgedSequence: sequence,
    );
    notifyListeners();
  }
}
