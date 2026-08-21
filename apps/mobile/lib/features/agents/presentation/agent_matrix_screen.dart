import 'package:flutter/material.dart';

import '../../../design/components/status_badge.dart';
import '../../../design/tokens.dart';
import '../domain/agent.dart';

final class AgentRunView {
  const AgentRunView({
    required this.id,
    required this.name,
    required this.type,
    required this.state,
    required this.provider,
    required this.exactModelId,
    required this.reasoningLabel,
    required this.taskLabel,
    required this.grants,
    required this.costMicros,
    required this.latencyMs,
    required this.requiresApproval,
    required this.artifactCount,
    required this.citationCount,
    this.dissent,
  });

  final String id;
  final String name;
  final AgentType type;
  final AgentState state;
  final String provider;
  final String exactModelId;
  final String reasoningLabel;
  final String taskLabel;
  final List<String> grants;
  final int costMicros;
  final int latencyMs;
  final bool requiresApproval;
  final int artifactCount;
  final int citationCount;
  final String? dissent;
}

class AgentMatrixScreen extends StatelessWidget {
  const AgentMatrixScreen({
    this.agents = const <AgentRunView>[],
    this.onCancel,
    this.onApprove,
    this.onCreateMission,
    super.key,
  });

  final List<AgentRunView> agents;
  final ValueChanged<String>? onCancel;
  final ValueChanged<String>? onApprove;
  final VoidCallback? onCreateMission;

  @override
  Widget build(BuildContext context) {
    if (agents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(NexusSpacing.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.hub_outlined, size: 48),
              const SizedBox(height: NexusSpacing.x4),
              const Text('No active agents'),
              const SizedBox(height: NexusSpacing.x2),
              const Text(
                'Create a mission to populate the dependency matrix.',
                textAlign: TextAlign.center,
              ),
              if (onCreateMission != null) ...<Widget>[
                const SizedBox(height: NexusSpacing.x4),
                FilledButton.icon(
                  onPressed: onCreateMission,
                  icon: const Icon(Icons.add),
                  label: const Text('Create mission'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(NexusSpacing.x4),
      itemCount: agents.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: NexusSpacing.x3),
      itemBuilder: (context, index) => _AgentCard(
        agent: agents[index],
        onCancel: onCancel,
        onApprove: onApprove,
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  const _AgentCard({
    required this.agent,
    required this.onCancel,
    required this.onApprove,
  });

  final AgentRunView agent;
  final ValueChanged<String>? onCancel;
  final ValueChanged<String>? onApprove;

  @override
  Widget build(BuildContext context) {
    final status = _statusFor(agent.state);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(NexusSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        agent.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${agent.provider} · ${agent.exactModelId} · ${agent.reasoningLabel}',
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: status.$1, symbol: status.$2),
              ],
            ),
            const SizedBox(height: NexusSpacing.x3),
            Text(agent.taskLabel, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: NexusSpacing.x3),
            Wrap(
              spacing: NexusSpacing.x2,
              runSpacing: NexusSpacing.x2,
              children: <Widget>[
                _Metric(
                  label:
                      '\$${(agent.costMicros / 1000000).toStringAsFixed(2)} reserved',
                ),
                _Metric(label: '${agent.latencyMs} ms'),
                _Metric(label: '${agent.artifactCount} artifacts'),
                _Metric(label: '${agent.citationCount} citations'),
              ],
            ),
            const SizedBox(height: NexusSpacing.x3),
            Text('Grants: ${agent.grants.join(', ')}'),
            if (agent.dissent case final dissent?) ...<Widget>[
              const SizedBox(height: NexusSpacing.x3),
              Semantics(
                label: 'Agent dissent',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(NexusSpacing.x3),
                  decoration: BoxDecoration(
                    border: Border.all(color: NexusColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Dissent: $dissent'),
                ),
              ),
            ],
            const SizedBox(height: NexusSpacing.x3),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (agent.requiresApproval) ...<Widget>[
                  const StatusBadge(
                    label: 'Approval required',
                    symbol: Icons.approval_outlined,
                  ),
                  const SizedBox(width: NexusSpacing.x2),
                  FilledButton(
                    onPressed: onApprove == null
                        ? null
                        : () => onApprove!(agent.id),
                    child: const Text('Review'),
                  ),
                ],
                const SizedBox(width: NexusSpacing.x2),
                Semantics(
                  label: 'Cancel ${agent.name}',
                  button: true,
                  child: IconButton.outlined(
                    tooltip: 'Cancel ${agent.name}',
                    onPressed: onCancel == null
                        ? null
                        : () => onCancel!(agent.id),
                    icon: const Icon(Icons.stop_circle_outlined),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (String, IconData) _statusFor(AgentState state) => switch (state) {
    AgentState.idle => ('Idle', Icons.pause_circle_outline),
    AgentState.queued => ('Queued', Icons.schedule),
    AgentState.running => ('Running', Icons.play_circle_outline),
    AgentState.waiting => ('Waiting', Icons.hourglass_empty),
    AgentState.paused => ('Paused', Icons.pause_circle_outline),
    AgentState.completed => ('Completed', Icons.check_circle_outline),
    AgentState.failed => ('Failed', Icons.error_outline),
    AgentState.cancelled => ('Cancelled', Icons.cancel_outlined),
  };
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: NexusSpacing.x2,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: NexusColors.border),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(label),
  );
}
