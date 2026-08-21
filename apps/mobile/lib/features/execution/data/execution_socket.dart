enum ExecutionFrameKind { output, error, completed, cancelled }

final class ExecutionFrame {
  const ExecutionFrame({
    required this.sequence,
    required this.text,
    this.kind = ExecutionFrameKind.output,
  });

  final int sequence;
  final String text;
  final ExecutionFrameKind kind;
}

abstract interface class ExecutionSocket {
  Future<void> connect({
    required String executionId,
    required int afterSequence,
  });

  Future<void> close();
}
