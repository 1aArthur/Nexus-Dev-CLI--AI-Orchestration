import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';

class CosmicRadarScanner extends StatefulWidget {
  final double size;
  final Color radarColor;
  
  const CosmicRadarScanner({
    super.key,
    required this.size,
    required this.radarColor,
  });
  
  @override
  State<CosmicRadarScanner> createState() => _CosmicRadarScannerState();
}

class _CosmicRadarScannerState extends State<CosmicRadarScanner> with TickerProviderStateMixin {
  late final AnimationController _sweepController;
  late final AnimationController _pingController;
  late final AnimationController _blipController;
  
  final List<_RadarBlip> _blips = [];
  
  @override
  void initState() {
    super.initState();
    
    _sweepController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _pingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _blipController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _generateBlips();
  }
  
  void _generateBlips() {
    _blips.clear();
    for (int i = 0; i < 8; i++) {
      _blips.add(_RadarBlip(
        angle: (i * 45.0) + (DateTime.now().millisecondsSinceEpoch % 45),
        distance: 0.3 + (i * 0.08) % 0.7,
        intensity: 0.3 + (i * 0.1) % 0.7,
      ));
    }
  }
  
  @override
  void dispose() {
    _sweepController.dispose();
    _pingController.dispose();
    _blipController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_sweepController, _pingController, _blipController]),
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RadarPainter(
            sweepAngle: _sweepController.value * 360,
            pingRadius: _pingController.value,
            blips: _blips,
            radarColor: widget.radarColor,
            blipProgress: _blipController.value,
          ),
        );
      },
    );
  }
}

class _RadarBlip {
  final double angle;
  final double distance;
  final double intensity;
  
  _RadarBlip({required this.angle, required this.distance, required this.intensity});
}

class _RadarPainter extends CustomPainter {
  final double sweepAngle;
  final double pingRadius;
  final List<_RadarBlip> blips;
  final Color radarColor;
  final double blipProgress;
  
  _RadarPainter({
    required this.sweepAngle,
    required this.pingRadius,
    required this.blips,
    required this.radarColor,
    required this.blipProgress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    for (int i = 1; i <= 4; i++) {
      final r = radius * i / 4;
      canvas.drawCircle(center, r, Paint()
        ..color = radarColor.withValues(alpha: 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
    }
    
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), Paint()
      ..color = radarColor.withValues(alpha: 0.1)
      ..strokeWidth = 1);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), Paint()
      ..color = radarColor.withValues(alpha: 0.1)
      ..strokeWidth = 1);
    
    final sweepRad = sweepAngle * 3.14159 / 180;
    final sweepEnd = Offset(
      center.dx + radius * 0.95 * cos(sweepRad),
      center.dy + radius * 0.95 * sin(sweepRad),
    );
    canvas.drawLine(center, sweepEnd, Paint()
      ..color = radarColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round);
    
    for (int i = 1; i <= 5; i++) {
      final trailAngle = (sweepAngle - i * 8) * 3.14159 / 180;
      final trailEnd = Offset(
        center.dx + radius * 0.95 * cos(trailAngle),
        center.dy + radius * 0.95 * sin(trailAngle),
      );
      canvas.drawLine(center, trailEnd, Paint()
        ..color = radarColor.withValues(alpha: 0.15 * (1 - i * 0.15))
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round);
    }
    
    for (int i = 0; i < 3; i++) {
      final ringRadius = radius * ((pingRadius + i * 0.33) % 1.0);
      canvas.drawCircle(center, ringRadius, Paint()
        ..color = radarColor.withValues(alpha: 0.15 * (1 - ((pingRadius + i * 0.33) % 1.0)))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
    }
    
    for (final blip in blips) {
      final blipAngle = (blip.angle + blipProgress * 360) * 3.14159 / 180;
      final blipRadius = radius * blip.distance;
      final blipPos = Offset(
        center.dx + blipRadius * cos(blipAngle),
        center.dy + blipRadius * sin(blipAngle),
      );
      
      final alpha = blip.intensity * (0.5 + 0.5 * sin(blipProgress * 6.28));
      canvas.drawCircle(blipPos, 3, Paint()
        ..color = radarColor.withValues(alpha: alpha)
        ..style = PaintingStyle.fill);
      
      canvas.drawCircle(blipPos, 6, Paint()
        ..color = radarColor.withValues(alpha: alpha * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
    }
    
    canvas.drawCircle(center, 4, Paint()..color = radarColor);
    canvas.drawCircle(center, 2, Paint()..color = NexusTheme.pureWhite);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
