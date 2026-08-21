import '../../../core/api/generated/contracts.dart';

enum ExecutionCapability { safeNative, readRepository, writeRepository, network, terminal, longRunning, secrets, gpu }

final class ExecutionTarget {
  const ExecutionTarget();

  factory ExecutionTarget.fromDto(ExecutionTargetDto dto) => throw UnimplementedError();

  List<ExecutionCapability> get capabilities => throw UnimplementedError();

  bool get requiresApproval => throw UnimplementedError();
}
