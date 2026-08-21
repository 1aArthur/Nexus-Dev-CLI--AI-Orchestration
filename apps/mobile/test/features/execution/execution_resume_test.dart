import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/features/execution/application/execution_controller.dart';
import 'package:nexus_mobile/features/execution/data/execution_socket.dart';

void main() {
  test('reconnect resumes after the last acknowledged sequence', () async {
    final socket = FakeExecutionSocket();
    final controller = ExecutionController(socket: socket, maximumLines: 3);

    await controller.connect('run-1');
    controller.ingest(const ExecutionFrame(sequence: 1, text: 'one'));
    controller.ingest(const ExecutionFrame(sequence: 2, text: 'two'));
    controller.acknowledge(2);
    await controller.reconnect();

    expect(socket.resumeRequests, <int>[0, 2]);
    expect(controller.state.lastAcknowledgedSequence, 2);
  });

  test('duplicate frames are ignored and scrollback remains bounded', () {
    final controller = ExecutionController(
      socket: FakeExecutionSocket(),
      maximumLines: 2,
    );

    controller.ingest(const ExecutionFrame(sequence: 1, text: 'one'));
    controller.ingest(const ExecutionFrame(sequence: 2, text: 'two'));
    controller.ingest(const ExecutionFrame(sequence: 2, text: 'duplicate'));
    controller.ingest(
      const ExecutionFrame(
        sequence: 3,
        text: 'three',
        kind: ExecutionFrameKind.completed,
      ),
    );

    expect(controller.state.lines, <String>['two', 'three']);
    expect(controller.state.lastReceivedSequence, 3);
    expect(controller.state.isTerminal, isTrue);
  });
}

final class FakeExecutionSocket implements ExecutionSocket {
  final List<int> resumeRequests = <int>[];

  @override
  Future<void> connect({
    required String executionId,
    required int afterSequence,
  }) async {
    resumeRequests.add(afterSequence);
  }

  @override
  Future<void> close() async {}
}
