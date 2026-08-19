import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';

class CosmicOrbNavButton extends StatefulWidget {
  final VoidCallback onTap;
  
  const CosmicOrbNavButton({super.key, required this.onTap});
  
  @override
  State<CosmicOrbNavButton> createState() => _CosmicOrbNavButtonState();
}

class _CosmicOrbNavButtonState extends State<CosmicOrbNavButton> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotationController;
  late final AnimationController _glowController;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 16),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotationController, _glowController]),
      builder: (context, child) {
        final pulseScale = 0.95 + (_pulseController.value * 0.13);
        final glowAlpha = 0.4 + (_glowController.value * 0.45);
        final rotation = _rotationController.value * 360;
        
        return Transform.scale(
          scale: pulseScale,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          NexusTheme.pureWhite.withValues(alpha: glowAlpha * 0.45),
                          NexusTheme.cyan.withValues(alpha: glowAlpha * 0.35),
                          NexusTheme.purple.withValues(alpha: glowAlpha * 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  
                  Transform.rotate(
                    angle: rotation * 3.14159 / 180,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: NexusTheme.cyan.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: CustomPaint(
                        painter: _OrbRingPainter(progress: _rotationController.value),
                      ),
                    ),
                  ),
                  
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: NexusTheme.orbGradient,
                      boxShadow: NexusTheme.glowShadow,
                      border: Border.all(
                        color: NexusTheme.cyan.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.auto_awesome,
                        color: NexusTheme.oledBlack,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: NexusTheme.pureWhite.withValues(alpha: glowAlpha * 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrbRingPainter extends CustomPainter {
  final double progress;
  
  _OrbRingPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          NexusTheme.pureWhite,
          NexusTheme.cyan,
          NexusTheme.purple,
          NexusTheme.pureWhite,
        ],
        startAngle: -3.14159 / 2,
        endAngle: 3 * 3.14159 / 2,
      ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2));
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 1,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _OrbRingPainter && oldDelegate.progress != progress;
  }
}
