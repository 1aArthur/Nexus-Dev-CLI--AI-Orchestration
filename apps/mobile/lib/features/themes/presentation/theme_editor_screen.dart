import 'package:flutter/material.dart';

import '../../../design/tokens.dart';
import '../application/theme_controller.dart';

typedef ThemeAssetPicker =
    Future<ThemeAssetCandidate?> Function(ThemeAssetKind kind);

class ThemeEditorScreen extends StatefulWidget {
  const ThemeEditorScreen({
    this.controller,
    this.pickAsset,
    this.batterySaver = false,
    super.key,
  });

  final ThemeController? controller;
  final ThemeAssetPicker? pickAsset;
  final bool batterySaver;

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends State<ThemeEditorScreen>
    with WidgetsBindingObserver {
  late ThemeController _controller;
  late bool _ownsController;
  bool? _lastReducedMotion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bindController(widget.controller);
    _controller.updateEnvironment(batterySaver: widget.batterySaver);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_lastReducedMotion == reducedMotion) return;
    _lastReducedMotion = reducedMotion;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.updateEnvironment(reducedMotion: reducedMotion);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ThemeEditorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _unbindController();
      _bindController(widget.controller);
    }
    if (oldWidget.batterySaver != widget.batterySaver) {
      _controller.updateEnvironment(batterySaver: widget.batterySaver);
    }
  }

  void _bindController(ThemeController? controller) {
    _ownsController = controller == null;
    _controller = controller ?? ThemeController(store: _MemoryThemeStore());
    _controller.addListener(_refresh);
  }

  void _unbindController() {
    _controller.removeListener(_refresh);
    if (_ownsController) _controller.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.updateEnvironment(
      appForeground: state == AppLifecycleState.resumed,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _unbindController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = _controller.settings;
    final selected = _controller.selectedAsset;
    return ListView(
      padding: const EdgeInsets.all(NexusSpacing.x4),
      children: <Widget>[
        Text('Theme Studio', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: NexusSpacing.x1),
        const Text(
          'OLED-first custom backgrounds with local media, accessibility '
          'fallbacks, and atomic activation.',
        ),
        const SizedBox(height: NexusSpacing.x4),
        _ThemePreview(controller: _controller),
        const SizedBox(height: NexusSpacing.x4),
        Wrap(
          spacing: NexusSpacing.x2,
          runSpacing: NexusSpacing.x2,
          children: <Widget>[
            FilledButton.icon(
              onPressed: widget.pickAsset == null
                  ? null
                  : () => _pick(ThemeAssetKind.image),
              icon: const Icon(Icons.image_outlined),
              label: const Text('Choose image'),
            ),
            OutlinedButton.icon(
              onPressed: widget.pickAsset == null
                  ? null
                  : () => _pick(ThemeAssetKind.video),
              icon: const Icon(Icons.video_file_outlined),
              label: const Text('Choose MP4 · max 30s'),
            ),
          ],
        ),
        if (_controller.validationMessage != null) ...<Widget>[
          const SizedBox(height: NexusSpacing.x3),
          Text(
            _controller.validationMessage!,
            key: const Key('theme-validation-message'),
          ),
        ],
        const SizedBox(height: NexusSpacing.x4),
        _ControlCard(
          title: 'Composition',
          icon: Icons.crop_outlined,
          children: <Widget>[
            _LabeledSlider(
              label: 'Crop zoom',
              valueLabel: '${settings.cropZoom.toStringAsFixed(1)}×',
              value: settings.cropZoom,
              min: 1,
              max: 3,
              onChanged: (value) => _controller.updateSettings(
                settings.copyWith(cropZoom: value),
              ),
            ),
            _LabeledSlider(
              label: 'Focal point X',
              valueLabel: '${(settings.focalX * 100).round()}%',
              value: settings.focalX,
              onChanged: (value) =>
                  _controller.updateSettings(settings.copyWith(focalX: value)),
            ),
            _LabeledSlider(
              label: 'Focal point Y',
              valueLabel: '${(settings.focalY * 100).round()}%',
              value: settings.focalY,
              onChanged: (value) =>
                  _controller.updateSettings(settings.copyWith(focalY: value)),
            ),
          ],
        ),
        const SizedBox(height: NexusSpacing.x3),
        _ControlCard(
          title: 'Readability and motion',
          icon: Icons.contrast_outlined,
          children: <Widget>[
            _LabeledSlider(
              label: 'Blur',
              valueLabel: settings.blurSigma.toStringAsFixed(0),
              value: settings.blurSigma,
              min: 0,
              max: 24,
              onChanged: (value) => _controller.updateSettings(
                settings.copyWith(blurSigma: value),
              ),
            ),
            _LabeledSlider(
              label: 'Dimming',
              valueLabel:
                  '${(_controller.presentation.contrastScrimOpacity * 100).round()}%',
              value: settings.dimming,
              min: 0,
              max: 0.85,
              onChanged: (value) =>
                  _controller.updateSettings(settings.copyWith(dimming: value)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Loop video'),
              subtitle: const Text('Playback still pauses outside the app.'),
              value: settings.loop,
              onChanged: (value) =>
                  _controller.updateSettings(settings.copyWith(loop: value)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Parallax'),
              subtitle: const Text('Disabled by reduced-motion preference.'),
              value: settings.parallax,
              onChanged: (value) => _controller.updateSettings(
                settings.copyWith(parallax: value),
              ),
            ),
          ],
        ),
        const SizedBox(height: NexusSpacing.x3),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.cloud_off_outlined),
            title: const Text('Sync theme assets'),
            subtitle: Text(
              _controller.syncEnabled
                  ? 'Explicit encrypted sync enabled.'
                  : 'Local only by default.',
            ),
            value: _controller.syncEnabled,
            onChanged: _controller.setSyncEnabled,
          ),
        ),
        const SizedBox(height: NexusSpacing.x4),
        FilledButton.icon(
          onPressed: selected == null || _controller.activating
              ? null
              : _activate,
          icon: const Icon(Icons.check_circle_outline),
          label: Text(
            _controller.activating ? 'Activating safely…' : 'Activate theme',
          ),
        ),
      ],
    );
  }

  Future<void> _pick(ThemeAssetKind kind) async {
    final candidate = await widget.pickAsset?.call(kind);
    if (candidate == null) return;
    await _controller.selectThemeAsset(candidate);
  }

  Future<void> _activate() async {
    final activated = await _controller.activateSelected();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          activated
              ? 'Theme activated.'
              : 'Theme activation failed; previous theme restored.',
        ),
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    final presentation = controller.presentation;
    final asset = controller.selectedAsset ?? controller.activeAsset;
    return Semantics(
      label: 'Theme preview with enforced contrast overlay',
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: NexusColors.border),
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                NexusColors.raised,
                NexusColors.oled,
                NexusColors.focus,
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ColoredBox(
                color: NexusColors.oled.withValues(
                  alpha: presentation.contrastScrimOpacity,
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      asset?.kind == ThemeAssetKind.video
                          ? presentation.shouldPlayVideo
                                ? Icons.play_circle_outline
                                : Icons.pause_circle_outline
                          : Icons.image_outlined,
                      size: 42,
                    ),
                    const SizedBox(height: NexusSpacing.x2),
                    Text(
                      asset == null
                          ? 'Select local media to preview'
                          : presentation.assetPath ?? 'Poster unavailable',
                      textAlign: TextAlign.center,
                    ),
                    if (asset?.kind == ThemeAssetKind.video &&
                        !presentation.shouldPlayVideo)
                      const Text('Static accessibility/battery fallback'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlCard extends StatelessWidget {
  const _ControlCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(NexusSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon),
              const SizedBox(width: NexusSpacing.x2),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: NexusSpacing.x2),
          ...children,
        ],
      ),
    ),
  );
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(valueLabel),
        ],
      ),
      Slider(value: value, min: min, max: max, onChanged: onChanged),
    ],
  );
}

final class _MemoryThemeStore implements ThemeActivationStore {
  @override
  Future<void> stage(ThemeAssetCandidate candidate) async {}

  @override
  Future<void> commit(String candidateId) async {}

  @override
  Future<void> rollbackTo(String? candidateId) async {}
}
