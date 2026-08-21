import 'package:flutter/material.dart';

import '../../../core/api/generated/contracts.dart';
import '../../../design/tokens.dart';
import '../application/mission_controller.dart';

class MissionComposerScreen extends StatefulWidget {
  const MissionComposerScreen({this.controller, super.key});

  final MissionController? controller;

  @override
  State<MissionComposerScreen> createState() => _MissionComposerScreenState();
}

class _MissionComposerScreenState extends State<MissionComposerScreen> {
  late final MissionController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MissionController(
          gateway: InMemoryMissionGateway(),
          modelCapabilities: const <MissionModelCapability>[
            MissionModelCapability(
              providerId: 'openai-compatible',
              exactModelId: 'configured-model',
              supportedReasoning: <UniversalReasoningLevel>{
                UniversalReasoningLevel.fast,
                UniversalReasoningLevel.balanced,
                UniversalReasoningLevel.deep,
              },
            ),
            MissionModelCapability(
              providerId: 'anthropic-compatible',
              exactModelId: 'configured-model',
              supportedReasoning: <UniversalReasoningLevel>{
                UniversalReasoningLevel.fast,
                UniversalReasoningLevel.balanced,
              },
            ),
          ],
        );
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final state = _controller.state;
        final draft = state.draft;
        return ListView(
          padding: const EdgeInsets.all(NexusSpacing.x4),
          children: <Widget>[
            Text(
              'Mission composer',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: NexusSpacing.x2),
            const Text(
              'Set hard limits before the orchestrator reserves work.',
            ),
            const SizedBox(height: NexusSpacing.x4),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Mission objective',
                hintText: 'Audit, build, test, and report…',
              ),
              minLines: 2,
              maxLines: 4,
              onChanged: _controller.setTitle,
            ),
            const SizedBox(height: NexusSpacing.x4),
            DropdownButtonFormField<String>(
              initialValue: draft.executionTargetId.isEmpty
                  ? null
                  : draft.executionTargetId,
              decoration: const InputDecoration(labelText: 'Execution target'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem(
                  value: 'local-core',
                  child: Text('Device · safe native tools only'),
                ),
                DropdownMenuItem(
                  value: 'nexus-sandbox',
                  child: Text('Nexus isolated sandbox'),
                ),
                DropdownMenuItem(
                  value: 'github-actions',
                  child: Text('GitHub Actions · batch'),
                ),
              ],
              onChanged: (value) {
                if (value != null) _controller.setExecutionTarget(value);
              },
            ),
            const SizedBox(height: NexusSpacing.x4),
            DropdownButtonFormField<String>(
              initialValue: draft.providerId.isEmpty ? null : draft.providerId,
              decoration: const InputDecoration(labelText: 'Provider adapter'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem(
                  value: 'openai-compatible',
                  child: Text('OpenAI-compatible endpoint'),
                ),
                DropdownMenuItem(
                  value: 'anthropic-compatible',
                  child: Text('Anthropic-compatible endpoint'),
                ),
              ],
              onChanged: (provider) {
                if (provider != null) {
                  _controller.selectModel(provider, 'configured-model');
                }
              },
            ),
            const SizedBox(height: NexusSpacing.x4),
            SegmentedButton<UniversalReasoningLevel>(
              segments: _controller.availableReasoningLevels
                  .map(
                    (level) => ButtonSegment<UniversalReasoningLevel>(
                      value: level,
                      label: Text(level.name),
                    ),
                  )
                  .toList(growable: false),
              selected: _controller.availableReasoningLevels.contains(
                draft.reasoning,
              )
                  ? <UniversalReasoningLevel>{draft.reasoning}
                  : <UniversalReasoningLevel>{},
              emptySelectionAllowed: true,
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  _controller.setReasoning(selection.first);
                }
              },
            ),
            const SizedBox(height: NexusSpacing.x4),
            _BoundedSlider(
              label: 'Agents',
              value: draft.agentCount.toDouble(),
              min: 1,
              max: 32,
              divisions: 31,
              onChanged: (value) => _controller.setAgentCount(value.round()),
            ),
            _BoundedSlider(
              label: 'Concurrency',
              value: draft.concurrency.toDouble(),
              min: 1,
              max: draft.agentCount.toDouble(),
              divisions: draft.agentCount > 1 ? draft.agentCount - 1 : null,
              onChanged: (value) => _controller.setConcurrency(value.round()),
            ),
            const SizedBox(height: NexusSpacing.x2),
            DropdownButtonFormField<ApprovalMode>(
              initialValue: draft.approvalMode,
              decoration: const InputDecoration(labelText: 'Approval policy'),
              items: const <DropdownMenuItem<ApprovalMode>>[
                DropdownMenuItem(
                  value: ApprovalMode.alwaysAsk,
                  child: Text('Always ask'),
                ),
                DropdownMenuItem(
                  value: ApprovalMode.policy,
                  child: Text('Policy gates'),
                ),
                DropdownMenuItem(
                  value: ApprovalMode.neverForSafeNative,
                  child: Text('Skip only bounded native tools'),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) _controller.setApprovalMode(mode);
              },
            ),
            const SizedBox(height: NexusSpacing.x4),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(NexusSpacing.x4),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.account_balance_wallet_outlined),
                    const SizedBox(width: NexusSpacing.x3),
                    Expanded(
                      child: Text(
                        'Reserved estimate: '
                        '\$${(state.costPreview.reservedMicros / 1000000).toStringAsFixed(2)} '
                        '${state.costPreview.currency}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: NexusSpacing.x4),
            FilledButton.icon(
              onPressed: state.isSubmitting ? null : _submit,
              icon: state.isSubmitting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: const Text('Create bounded mission'),
            ),
            if (state.failure case final failure?) ...<Widget>[
              const SizedBox(height: NexusSpacing.x3),
              Text(failure, semanticsLabel: 'Mission submission failed'),
            ],
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    final validation = _controller.validate();
    if (!validation.isValid) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validation.issues.join('\n'))),
      );
      return;
    }
    final mission = await _controller.submit();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mission ${mission.id} queued')),
    );
  }
}

class _BoundedSlider extends StatelessWidget {
  const _BoundedSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text('$label: ${value.round()}'),
      Slider(
        value: value.clamp(min, max).toDouble(),
        min: min,
        max: max,
        divisions: divisions,
        label: value.round().toString(),
        onChanged: min == max ? null : onChanged,
      ),
    ],
  );
}
