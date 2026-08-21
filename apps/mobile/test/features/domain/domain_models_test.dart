import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/core/api/generated/contracts.dart';
import 'package:nexus_mobile/features/agents/domain/agent.dart';
import 'package:nexus_mobile/features/execution/domain/execution_target.dart';
import 'package:nexus_mobile/features/missions/domain/mission.dart';
import 'package:nexus_mobile/features/security/domain/security_finding.dart';
import 'package:nexus_mobile/features/usage/domain/usage.dart';

void main() {
  test('domain enum contracts retain every supported wire state', () {
    expect(AgentType.values, hasLength(8));
    expect(AgentState.values, hasLength(8));
    expect(SecuritySeverity.values, hasLength(5));
    expect(ExecutionCapability.values, hasLength(8));
    expect(UsageSource.values, hasLength(3));
  });

  test('terminal missions reject further state transitions', () {
    final mission = Mission.fromDto(
      MissionDto(
        id: '3de4ae3b-b0de-4e1c-a70a-30c6823d6f13',
        ownerId: '782458e7-6fe5-4b08-a47e-a3823738b581',
        title: 'Release Nexus',
        status: MissionStatus.succeeded,
        createdAt: DateTime.utc(2026, 8, 20),
        updatedAt: DateTime.utc(2026, 8, 20, 1),
        lastEventSequence: 9,
      ),
    );

    expect(() => mission.transitionTo(MissionStatus.running), throwsStateError);
  });

  test('mission DTO conversion preserves lifecycle and budget fields', () {
    final dto = MissionDto(
      id: '3de4ae3b-b0de-4e1c-a70a-30c6823d6f13',
      ownerId: '782458e7-6fe5-4b08-a47e-a3823738b581',
      title: 'Release Nexus',
      status: MissionStatus.awaitingApproval,
      createdAt: DateTime.utc(2026, 8, 20),
      updatedAt: DateTime.utc(2026, 8, 20, 1),
      lastEventSequence: 7,
      budgetLimitMicros: 5000000,
      concurrencyLimit: 12,
    );

    expect(Mission.fromDto(dto).toDto().toJson(), dto.toJson());
  });

  test('execution target and usage mappings preserve security metadata', () {
    final target = ExecutionTarget.fromDto(
      const ExecutionTargetDto(
        id: '726c761d-7b4d-42a8-a18d-f7bf46e4210d',
        displayName: 'GitHub Actions',
        kind: ExecutionTargetKind.githubActions,
        status: ExecutionTargetStatus.available,
        capabilities: <String>['read_repository', 'terminal'],
        approvalMode: ApprovalMode.alwaysAsk,
      ),
    );
    final usage = UsageRecord.fromDto(
      UsageRecordDto(
        id: '8e6f7888-1e9f-4ca6-9512-ea61e3d264cd',
        missionId: '3de4ae3b-b0de-4e1c-a70a-30c6823d6f13',
        provider: 'openai',
        exactModelId: 'provider/model-version',
        inputTokens: 200,
        outputTokens: 80,
        costMicros: 1200,
        currency: 'USD',
        provenance: UsageProvenance.providerReported,
        recordedAt: DateTime.utc(2026, 8, 20),
      ),
    );

    expect(target.capabilities, contains(ExecutionCapability.terminal));
    expect(target.requiresApproval, isTrue);
    expect(usage.source, UsageSource.providerReported);
    expect(usage.isEstimate, isFalse);
  });
}
