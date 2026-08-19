import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';

class CosmicStarfieldBackground extends StatefulWidget {
  final Widget child;
  
  const CosmicStarfieldBackground({super.key, required this.child});
  
  @override
  State<CosmicStarfieldBackground> createState() => _CosmicStarfieldBackgroundState();
}

class _CosmicStarfieldBackgroundState extends State<CosmicStarfieldBackground> with TickerProviderStateMixin {
  late final AnimationController _parallaxController;
  late final AnimationController _twinkleController;
  
  final List<_Star> _stars = [];
  final List<_Nebula> _nebulae = [];
  
  @override
  void initState() {
    super.initState();
    
    _parallaxController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
    
    _twinkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _generateStars();
    _generateNebulae();
  }
  
  void _generateStars() {
    _stars.clear();
    for (int i = 0; i < 150; i++) {
      _stars.add(_Star(
        x: (DateTime.now().millisecondsSinceEpoch + i * 17) % 10000 / 10000.0,
        y: (DateTime.now().millisecondsSinceEpoch + i * 23) % 10000 / 10000.0,
        size: 0.5 + (i % 3) * 0.5,
        brightness: 0.3 + (i % 7) * 0.1,
        twinkleSpeed: 0.5 + (i % 5) * 0.3,
        color: _starColors[i % _starColors.length],
      ));
    }
  }
  
  void _generateNebulae() {
    _nebulae.clear();
    for (int i = 0; i < 3; i++) {
      _nebulae.add(_Nebula(
        x: 0.2 + i * 0.3,
        y: 0.15 + i * 0.25,
        radius: 0.3 + i * 0.1,
        color: _nebulaColors[i % _nebulaColors.length],
        rotationSpeed: 0.0001 + i * 0.0002,
      ));
    }
  }
  
  static const List<Color> _starColors = [
    NexusTheme.pureWhite,
    NexusTheme.cyan,
    NexusTheme.purple,
    NexusTheme.emerald,
  ];
  
  static const List<Color> _nebulaColors = [
    NexusTheme.cyan,
    NexusTheme.purple,
    NexusTheme.amber,
  ];
  
  @override
  void dispose() {
    _parallaxController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_parallaxController, _twinkleController]),
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: NexusTheme.oledBlack),
            ..._nebulae.map((nebula) => _buildNebula(nebula)),
            CustomPaint(
              size: Size.infinite,
              painter: _StarfieldPainter(
                stars: _stars,
                parallax: _parallaxController.value,
                twinkle: _twinkleController.value,
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
  
  Widget _buildNebula(_Nebula nebula) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _NebulaPainter(
          nebula: nebula,
          progress: _parallaxController.value,
        ),
      ),
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double brightness;
  final double twinkleSpeed;
  final Color color;
  
  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
    required this.twinkleSpeed,
    required this.color,
  });
}

class _Nebula {
  final double x;
  final double y;
  final double radius;
  final Color color;
  final double rotationSpeed;
  
  _Nebula({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.rotationSpeed,
  });
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double parallax;
  final double twinkle;
  
  _StarfieldPainter({
    required this.stars,
    required this.parallax,
    required this.twinkle,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkleFactor = 0.5 + 0.5 * sin((twinkle * 6.28) * star.twinkleSpeed);
      final alpha = (star.brightness * twinkleFactor).clamp(0.1, 1.0);
      
      final x = (star.x + parallax * 0.01) * size.width;
      final y = (star.y + parallax * 0.005) * size.height;
      
      canvas.drawCircle(
        Offset(x % size.width, y % size.height),
        star.size,
        Paint()..color = star.color.withValues(alpha: alpha),
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _NebulaPainter extends CustomPainter {
  final _Nebula nebula;
  final double progress;
  
  _NebulaPainter({required this.nebula, required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * nebula.x, size.height * nebula.y);
    final radius = size.width * nebula.radius;
    final rotation = progress * 6.28 * nebula.rotationSpeed * 1000;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          nebula.color.withValues(alpha: 0.08),
          nebula.color.withValues(alpha: 0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
    
    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
