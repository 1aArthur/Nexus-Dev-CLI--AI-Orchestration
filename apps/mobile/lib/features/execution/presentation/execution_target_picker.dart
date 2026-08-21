import 'package:flutter/material.dart';

import '../../../core/api/generated/contracts.dart';
import '../../../design/components/status_badge.dart';
import '../../../design/tokens.dart';
import '../application/execution_controller.dart';
import '../domain/execution_target.dart';

final class ExecutionTargetChoice {
  const ExecutionTargetChoice({
    required this.target,
    required this.policy,
    required this.description,
  });

  final ExecutionTarget target;
  final ExecutionTargetPolicy policy;
  final String description;
}

class ExecutionTargetPicker extends StatelessWidget {
  const ExecutionTargetPicker({
    required this.choices,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final List<ExecutionTargetChoice> choices;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Execution target',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: NexusSpacing.x2),
        ...choices.map(
          (choice) => Padding(
            padding: const EdgeInsets.only(bottom: NexusSpacing.x2),
            child: Card(
              child: RadioGroup<String>(
                groupValue: selectedId,
                onChanged: (value) {
                  if (value != null) onSelected(value);
                },
                child: RadioListTile<String>(
                  value: choice.target.id,
                  title: Row(
                    children: <Widget>[
                      Expanded(child: Text(choice.target.displayName)),
                      StatusBadge(
                        label: _statusLabel(choice.target.status),
                        symbol: _statusIcon(choice.target.status),
                      ),
                    ],
                  ),
                  subtitle: Text(choice.description),
                  secondary: Icon(_kindIcon(choice.target.kind)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _statusLabel(ExecutionTargetStatus status) => switch (status) {
    ExecutionTargetStatus.available => 'Available',
    ExecutionTargetStatus.unavailable => 'Unavailable',
    ExecutionTargetStatus.requiresAuth => 'Authentication required',
    ExecutionTargetStatus.disabled => 'Disabled',
  };

  IconData _statusIcon(ExecutionTargetStatus status) => switch (status) {
    ExecutionTargetStatus.available => Icons.check_circle_outline,
    ExecutionTargetStatus.unavailable => Icons.cloud_off_outlined,
    ExecutionTargetStatus.requiresAuth => Icons.lock_outline,
    ExecutionTargetStatus.disabled => Icons.block_outlined,
  };

  IconData _kindIcon(ExecutionTargetKind kind) => switch (kind) {
    ExecutionTargetKind.device => Icons.smartphone_outlined,
    ExecutionTargetKind.githubActions => Icons.account_tree_outlined,
    ExecutionTargetKind.codespaces => Icons.cloud_outlined,
    ExecutionTargetKind.sshWorker => Icons.dns_outlined,
  };
}
