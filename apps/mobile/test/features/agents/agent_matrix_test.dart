import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/features/agents/domain/agent.dart';
import 'package:nexus_mobile/features/agents/presentation/agent_matrix_screen.dart';

void main() {
  testWidgets('renders agent provenance, grants, cost, and approval state', (
    tester,
  ) async {
    String? cancelledAgentId;
    await tester.pumpWidget(
      MaterialApp(
        home: AgentMatrixScreen(
          onCancel: (agentId) => cancelledAgentId = agentId,
          agents: const <AgentRunView>[
            AgentRunView(
              id: 'agent-1',
              name: 'Security reviewer',
              type: AgentType.security,
              state: AgentState.waiting,
              provider: 'OpenAI compatible',
              exactModelId: 'review-model-v2',
              reasoningLabel: 'Deep',
              taskLabel: 'Approve deployment',
              grants: <String>['repository:read', 'actions:dispatch'],
              costMicros: 420000,
              latencyMs: 1870,
              requiresApproval: true,
              artifactCount: 2,
              citationCount: 4,
              dissent: 'Production signing credentials are missing.',
            ),
          ],
        ),
      ),
    );

    expect(find.text('Security reviewer'), findsOneWidget);
    expect(find.textContaining('review-model-v2'), findsOneWidget);
    expect(find.textContaining('repository:read'), findsOneWidget);
    expect(find.textContaining('Approval required'), findsOneWidget);
    expect(find.textContaining('Production signing'), findsOneWidget);
    final cancel = find.byTooltip('Cancel Security reviewer');
    expect(cancel, findsOneWidget);
    await tester.tap(cancel);
    expect(cancelledAgentId, 'agent-1');
  });

  testWidgets('empty matrix explains how to start a mission', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AgentMatrixScreen(agents: <AgentRunView>[])),
    );

    expect(find.text('No active agents'), findsOneWidget);
    expect(find.textContaining('Create a mission'), findsOneWidget);
  });
}
