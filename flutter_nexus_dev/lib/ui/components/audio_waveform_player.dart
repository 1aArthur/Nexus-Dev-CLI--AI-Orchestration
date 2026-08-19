import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';

class AudioWaveformPlayer extends StatefulWidget {
  final bool isPlaying;
  final String currentUtterance;
  final VoidCallback onStop;
  
  const AudioWaveformPlayer({
    super.key,
    required this.isPlaying,
    required this.currentUtterance,
    required this.onStop,
  });
  
  @override
  State<AudioWaveformPlayer> createState() => _AudioWaveformPlayerState();
}

class _AudioWaveformPlayerState extends State<AudioWaveformPlayer> with TickerProviderStateMixin {
  late final AnimationController _waveController;
  final List<double> _waveHeights = List.generate(32, (i) => 0.1 + (i % 5) * 0.15);
  
  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    if (widget.isPlaying) {
      _waveController.repeat();
    }
    _animateWaves();
  }
  
  @override
  void didUpdateWidget(covariant AudioWaveformPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _waveController.repeat();
      _animateWaves();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _waveController.stop();
    }
  }
  
  void _animateWaves() {
    if (!widget.isPlaying) return;
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted && widget.isPlaying) {
        setState(() {
          for (int i = 0; i < _waveHeights.length; i++) {
            _waveHeights[i] = 0.1 + (0.9 * (0.3 + 0.7 * (DateTime.now().millisecondsSinceEpoch + i * 17) % 1000 / 1000));
          }
        });
        _animateWaves();
      }
    });
  }
  
  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: NexusTheme.radiusMedium,
        border: Border.all(color: NexusTheme.cyan.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: NexusTheme.cyan.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: NexusTheme.cyan,
                  boxShadow: [BoxShadow(color: NexusTheme.cyan, blurRadius: 8)],
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut).repeat(),
              const SizedBox(width: 8),
              Text('VOICE SYNTHESIS', style: NexusTheme.monoLabel.copyWith(color: NexusTheme.cyan)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.stop, color: NexusTheme.red, size: 20),
                onPressed: widget.onStop,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(32, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width: 3,
                  height: 40 * _waveHeights[i],
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: NexusTheme.cyan.withValues(alpha: 0.5 + 0.5 * _waveHeights[i]),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: NexusTheme.cyan.withValues(alpha: _waveHeights[i] * 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.currentUtterance,
            style: NexusTheme.monoSmall.copyWith(color: NexusTheme.white70),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
