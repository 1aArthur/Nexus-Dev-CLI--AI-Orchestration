import 'package:flutter/material.dart';

import '../../../design/tokens.dart';
import '../application/voice_controller.dart';
import '../domain/voice_state.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({this.controller, this.onMissionDraft, super.key});

  final VoiceController? controller;
  final ValueChanged<VoiceMissionDraft>? onMissionDraft;

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant VoiceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller?.removeListener(_refresh);
    widget.controller?.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final state = controller?.state ?? const VoiceState();
    return ListView(
      padding: const EdgeInsets.all(NexusSpacing.x4),
      children: <Widget>[
        Text('Grok Voice', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: NexusSpacing.x2),
        const Text(
          'Realtime PCM with a short-lived token issued by the Nexus gateway.',
        ),
        const SizedBox(height: NexusSpacing.x4),
        _PrivacyCard(configured: controller != null),
        const SizedBox(height: NexusSpacing.x4),
        _VoiceStatus(state: state),
        const SizedBox(height: NexusSpacing.x4),
        _TranscriptCard(
          title: 'You · cumulative transcript',
          value: state.inputTranscript,
          emptyLabel: 'Your live transcript will appear here.',
        ),
        const SizedBox(height: NexusSpacing.x3),
        _TranscriptCard(
          title: 'Grok · streaming response',
          value: state.outputTranscript,
          emptyLabel: 'The assistant transcript will stream here.',
        ),
        const SizedBox(height: NexusSpacing.x4),
        Wrap(
          spacing: NexusSpacing.x2,
          runSpacing: NexusSpacing.x2,
          children: <Widget>[
            FilledButton.icon(
              onPressed: controller == null ? null : _start,
              icon: const Icon(Icons.mic_none_outlined),
              label: Text(
                controller == null ? 'Gateway required' : 'Start listening',
              ),
            ),
            OutlinedButton.icon(
              onPressed: controller == null ? null : controller.pause,
              icon: const Icon(Icons.pause_outlined),
              label: const Text('Pause'),
            ),
            OutlinedButton.icon(
              onPressed: controller == null ? null : controller.discard,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Discard memory'),
            ),
            OutlinedButton.icon(
              onPressed: controller == null ||
                      (state.inputTranscript.isEmpty &&
                          state.outputTranscript.isEmpty)
                  ? null
                  : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(state.saved ? 'Saved' : 'Save transcript'),
            ),
            OutlinedButton.icon(
              onPressed: controller == null || state.inputTranscript.isEmpty
                  ? null
                  : _createMission,
              icon: const Icon(Icons.rocket_launch_outlined),
              label: const Text('Create mission'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _start() async {
    try {
      await widget.controller?.start();
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The secure voice session could not be started.'),
        ),
      );
    }
  }

  Future<void> _save() async {
    await widget.controller?.save();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transcript saved.')));
  }

  void _createMission() {
    final controller = widget.controller;
    if (controller == null) return;
    widget.onMissionDraft?.call(controller.createMissionDraft());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mission draft created.')));
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({required this.configured});

  final bool configured;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(NexusSpacing.x4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.shield_outlined, semanticLabel: 'Privacy'),
          const SizedBox(width: NexusSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  configured ? 'Secure gateway ready' : 'Gateway not connected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: NexusSpacing.x1),
                const Text(
                  'No permanent xAI key is accepted by the mobile app. Audio '
                  'and transcripts stay in memory until you choose Save.',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _VoiceStatus extends StatelessWidget {
  const _VoiceStatus({required this.state});

  final VoiceState state;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Voice status: ${_phaseLabel(state.phase)}',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(NexusSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.graphic_eq_outlined),
                const SizedBox(width: NexusSpacing.x2),
                Text(
                  _phaseLabel(state.phase),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: NexusSpacing.x3),
            _Waveform(activity: state.audioChunks.length),
          ],
        ),
      ),
    ),
  );
}

class _Waveform extends StatelessWidget {
  const _Waveform({required this.activity});

  final int activity;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List<Widget>.generate(18, (index) {
        final active = activity > 0 && index <= activity % 18;
        return Expanded(
          child: Center(
            child: Container(
              width: 3,
              height: active ? 36 : 12 + (index % 3) * 4,
              color: active ? NexusColors.white : NexusColors.border,
            ),
          ),
        );
      }),
    ),
  );
}

class _TranscriptCard extends StatelessWidget {
  const _TranscriptCard({
    required this.title,
    required this.value,
    required this.emptyLabel,
  });

  final String title;
  final String value;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(NexusSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: NexusSpacing.x2),
          SelectableText(value.isEmpty ? emptyLabel : value),
        ],
      ),
    ),
  );
}

String _phaseLabel(VoicePhase phase) => switch (phase) {
  VoicePhase.idle => 'Idle · memory only',
  VoicePhase.requestingSecret => 'Requesting ephemeral token',
  VoicePhase.connecting => 'Connecting securely',
  VoicePhase.listening => 'Listening',
  VoicePhase.paused => 'Paused',
  VoicePhase.responding => 'Grok is responding',
  VoicePhase.error => 'Session error',
};
