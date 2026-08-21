import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/core/api/generated/contracts.dart';
import 'package:nexus_mobile/features/missions/application/mission_controller.dart';

void main() {
  const capability = MissionModelCapability(
    providerId: 'openai',
    exactModelId: 'gpt-5.4',
    supportedReasoning: <UniversalReasoningLevel>{
      UniversalReasoningLevel.fast,
      UniversalReasoningLevel.balanced,
      UniversalReasoningLevel.deep,
    },
  );

  test('validates a bounded mission and previews its reserved cost', () {
    final controller = MissionController(
      gateway: InMemoryMissionGateway(),
      modelCapabilities: const <MissionModelCapability>[capability],
      now: () => DateTime.utc(2026, 8, 20),
    );

    expect(controller.validate().isValid, isFalse);
    controller
      ..setTitle('Audit the release pipeline')
      ..setExecutionTarget('github-actions')
      ..setAgentCount(6)
      ..setConcurrency(3)
      ..setBudgetMicros(900000)
      ..setDeadline(DateTime.utc(2026, 8, 21))
      ..selectModel('openai', 'gpt-5.4')
      ..setReasoning(UniversalReasoningLevel.deep);

    expect(controller.validate().isValid, isTrue);
    expect(controller.state.costPreview.reservedMicros, lessThanOrEqualTo(900000));
    expect(controller.state.draft.concurrency, lessThanOrEqualTo(6));
  });

  test('removes unsupported reasoning choices after a model change', () {
    final controller = MissionController(
      gateway: InMemoryMissionGateway(),
      modelCapabilities: const <MissionModelCapability>[
        capability,
        MissionModelCapability(
          providerId: 'anthropic',
          exactModelId: 'claude-compatible',
          supportedReasoning: <UniversalReasoningLevel>{
            UniversalReasoningLevel.fast,
            UniversalReasoningLevel.balanced,
          },
        ),
      ],
    );

    controller
      ..selectModel('openai', 'gpt-5.4')
      ..setReasoning(UniversalReasoningLevel.deep)
      ..selectModel('anthropic', 'claude-compatible');

    expect(controller.state.draft.reasoning, UniversalReasoningLevel.balanced);
    expect(
      controller.availableReasoningLevels,
      isNot(contains(UniversalReasoningLevel.deep)),
    );
  });

  test('submission is idempotent and terminal missions cannot resume', () async {
    final gateway = InMemoryMissionGateway();
    final controller = MissionController(
      gateway: gateway,
      modelCapabilities: const <MissionModelCapability>[capability],
      idempotencyKeyFactory: () => 'fixed-key',
    );
    controller
      ..setTitle('Ship release')
      ..setExecutionTarget('github-actions')
      ..selectModel('openai', 'gpt-5.4');

    final first = await controller.submit();
    final second = await controller.submit();

    expect(second.id, first.id);
    expect(gateway.submissionCount, 1);
    controller.applyEvent(
      MissionRuntimeEvent(
        missionId: first.id,
        sequence: 1,
        type: MissionRuntimeEventType.succeeded,
        occurredAt: DateTime.utc(2026, 8, 20),
      ),
    );
    expect(() => controller.resume(), throwsStateError);
  });

  test('detects event gaps and preserves explicit approval gates', () {
    final controller = MissionController(
      gateway: InMemoryMissionGateway(),
      modelCapabilities: const <MissionModelCapability>[capability],
    );

    controller.applyEvent(
      MissionRuntimeEvent(
        missionId: 'mission-1',
        sequence: 2,
        type: MissionRuntimeEventType.approvalRequired,
        occurredAt: DateTime.utc(2026, 8, 20),
        agentId: 'security-reviewer',
      ),
    );

    expect(controller.state.hasEventGap, isTrue);
    expect(controller.state.pendingApproval?.agentId, 'security-reviewer');
  });
}
