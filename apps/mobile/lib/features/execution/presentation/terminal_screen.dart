import 'package:flutter/material.dart';

import '../../../core/api/generated/contracts.dart';
import '../../../design/tokens.dart';
import '../application/execution_controller.dart';
import '../domain/execution_target.dart';
import 'execution_target_picker.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  late final List<ExecutionTargetChoice> _choices;
  String _selectedId = 'local-core';
  TerminalShell _shell = TerminalShell.bash;

  @override
  void initState() {
    super.initState();
    _choices = _defaultChoices();
  }

  ExecutionTargetChoice get _selected =>
      _choices.firstWhere((choice) => choice.target.id == _selectedId);

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return ListView(
      padding: const EdgeInsets.all(NexusSpacing.x4),
      children: <Widget>[
        Text('Execution console', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: NexusSpacing.x2),
        const Text(
          'Controls are rendered only from the selected target capabilities.',
        ),
        const SizedBox(height: NexusSpacing.x4),
        ExecutionTargetPicker(
          choices: _choices,
          selectedId: _selectedId,
          onSelected: (value) => setState(() => _selectedId = value),
        ),
        const SizedBox(height: NexusSpacing.x4),
        if (selected.policy.nativeOperations.isNotEmpty)
          _NativeOperations(policy: selected.policy)
        else if (selected.policy.supportsBatchDispatch)
          _GitHubBatchForm(policy: selected.policy)
        else if (selected.policy.acceptsArbitraryCommands)
          _InteractiveTerminal(
            policy: selected.policy,
            shell: _shell,
            onShellChanged: (value) => setState(() => _shell = value),
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(NexusSpacing.x4),
              child: Text(
                'Authenticate or enable this target before starting work.',
              ),
            ),
          ),
      ],
    );
  }
}

class _NativeOperations extends StatelessWidget {
  const _NativeOperations({required this.policy});

  final ExecutionTargetPolicy policy;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text('Bounded native tools', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: NexusSpacing.x2),
      const Text('Arbitrary shell input is disabled on this device.'),
      const SizedBox(height: NexusSpacing.x3),
      Wrap(
        spacing: NexusSpacing.x2,
        runSpacing: NexusSpacing.x2,
        children: policy.nativeOperations
            .map(
              (operation) => OutlinedButton.icon(
                onPressed: () => _notify(context, '${operation.name} queued'),
                icon: const Icon(Icons.memory_outlined),
                label: Text(operation.name),
              ),
            )
            .toList(growable: false),
      ),
    ],
  );
}

class _GitHubBatchForm extends StatelessWidget {
  const _GitHubBatchForm({required this.policy});

  final ExecutionTargetPolicy policy;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text('GitHub Actions batch run', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: NexusSpacing.x2),
      const Text('Interactive prompts are not supported for this target.'),
      const SizedBox(height: NexusSpacing.x3),
      const TextField(
        decoration: InputDecoration(labelText: 'Repository · owner/name'),
      ),
      const SizedBox(height: NexusSpacing.x3),
      const TextField(
        decoration: InputDecoration(labelText: 'Workflow file or ID'),
      ),
      const SizedBox(height: NexusSpacing.x3),
      const TextField(
        decoration: InputDecoration(labelText: 'Git ref'),
      ),
      const SizedBox(height: NexusSpacing.x3),
      Text(
        'Estimated reservation: '
        '\$${(policy.estimatedCostMicros / 1000000).toStringAsFixed(2)} USD',
      ),
      const SizedBox(height: NexusSpacing.x3),
      FilledButton.icon(
        onPressed: () => _notify(context, 'Approval requested for batch run'),
        icon: const Icon(Icons.approval_outlined),
        label: const Text('Review and dispatch'),
      ),
    ],
  );
}

class _InteractiveTerminal extends StatelessWidget {
  const _InteractiveTerminal({
    required this.policy,
    required this.shell,
    required this.onShellChanged,
  });

  final ExecutionTargetPolicy policy;
  final TerminalShell shell;
  final ValueChanged<TerminalShell> onShellChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text('Remote interactive session', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: NexusSpacing.x3),
      DropdownButtonFormField<TerminalShell>(
        initialValue: shell,
        decoration: const InputDecoration(labelText: 'Shell'),
        items: policy.shells
            .map(
              (value) => DropdownMenuItem<TerminalShell>(
                value: value,
                child: Text(value.name),
              ),
            )
            .toList(growable: false),
        onChanged: (value) {
          if (value != null) onShellChanged(value);
        },
      ),
      const SizedBox(height: NexusSpacing.x3),
      TextField(
        decoration: InputDecoration(
          labelText: '${shell.name} command',
          helperText: 'Runs only after the remote target approval gate.',
        ),
        onSubmitted: (value) => _notify(context, 'Remote approval requested'),
      ),
    ],
  );
}

void _notify(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

List<ExecutionTargetChoice> _defaultChoices() {
  const local = ExecutionTarget(
    id: 'local-core',
    displayName: 'This device',
    kind: ExecutionTargetKind.device,
    status: ExecutionTargetStatus.available,
    capabilities: <ExecutionCapability>[ExecutionCapability.safeNative],
    approvalMode: ApprovalMode.neverForSafeNative,
  );
  const actions = ExecutionTarget(
    id: 'github-actions',
    displayName: 'GitHub Actions',
    kind: ExecutionTargetKind.githubActions,
    status: ExecutionTargetStatus.requiresAuth,
    capabilities: <ExecutionCapability>[
      ExecutionCapability.readRepository,
      ExecutionCapability.writeRepository,
      ExecutionCapability.longRunning,
    ],
    approvalMode: ApprovalMode.alwaysAsk,
  );
  const codespaces = ExecutionTarget(
    id: 'github-codespaces',
    displayName: 'GitHub Codespaces',
    kind: ExecutionTargetKind.codespaces,
    status: ExecutionTargetStatus.requiresAuth,
    capabilities: <ExecutionCapability>[
      ExecutionCapability.terminal,
      ExecutionCapability.network,
      ExecutionCapability.longRunning,
    ],
    approvalMode: ApprovalMode.policy,
  );
  const ssh = ExecutionTarget(
    id: 'remote-ssh',
    displayName: 'Remote SSH worker',
    kind: ExecutionTargetKind.sshWorker,
    status: ExecutionTargetStatus.disabled,
    capabilities: <ExecutionCapability>[
      ExecutionCapability.terminal,
      ExecutionCapability.network,
      ExecutionCapability.secrets,
    ],
    approvalMode: ApprovalMode.alwaysAsk,
  );
  return <ExecutionTargetChoice>[
    ExecutionTargetChoice(
      target: local,
      policy: ExecutionTargetPolicy.forTarget(local),
      description: 'Hash, parse, redact, and summarize without a shell.',
    ),
    ExecutionTargetChoice(
      target: actions,
      policy: ExecutionTargetPolicy.forTarget(
        actions,
        estimatedCostMicros: 340000,
      ),
      description: 'Dispatch a workflow and follow logs and artifacts.',
    ),
    ExecutionTargetChoice(
      target: codespaces,
      policy: ExecutionTargetPolicy.forTarget(
        codespaces,
        advertisedShells: const <TerminalShell>{
          TerminalShell.bash,
          TerminalShell.zsh,
          TerminalShell.fish,
          TerminalShell.nushell,
        },
      ),
      description: 'Interactive repository-scoped cloud session.',
    ),
    ExecutionTargetChoice(
      target: ssh,
      policy: ExecutionTargetPolicy.forTarget(
        ssh,
        advertisedShells: const <TerminalShell>{
          TerminalShell.bash,
          TerminalShell.zsh,
        },
      ),
      description: 'Pinned host key and explicit credential scope required.',
    ),
  ];
}
