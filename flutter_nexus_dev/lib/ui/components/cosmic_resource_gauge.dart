import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';

class CosmicResourceGauge extends StatefulWidget {
  final String title;
  final int percent;
  final Color activeColor;
  
  const CosmicResourceGauge({
    super.key,
    required this.title,
    required this.percent,
    required this.activeColor,
  });
  
  @override
  State<CosmicResourceGauge> createState() => _CosmicResourceGaugeState();
}

class _CosmicResourceGaugeState extends State<CosmicResourceGauge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.percent / 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(covariant CosmicResourceGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      _animation = Tween<double>(begin: oldWidget.percent / 100, end: widget.percent / 100).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentPercent = (_animation.value * 100).round();
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 4,
                    backgroundColor: NexusTheme.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(NexusTheme.white10),
                  ),
                ),
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: _animation.value,
                    strokeWidth: 4,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.activeColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$currentPercent%',
                      style: NexusTheme.monoBody.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: NexusTheme.pureWhite,
                      ),
                    ),
                    Text(
                      widget.title,
                      style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white40),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: 64,
              height: 4,
              decoration: BoxDecoration(
                color: NexusTheme.white10,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.activeColor, widget.activeColor.withValues(alpha: 0.5)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
