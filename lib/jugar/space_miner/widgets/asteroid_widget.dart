import 'dart:math';
import 'package:flutter/material.dart';

/// Animated asteroid that can be clicked
class AsteroidWidget extends StatefulWidget {
  final VoidCallback onTap;
  final double size;

  const AsteroidWidget({
    super.key,
    required this.onTap,
    this.size = 200,
  });

  @override
  State<AsteroidWidget> createState() => _AsteroidWidgetState();
}

class _AsteroidWidgetState extends State<AsteroidWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _clickController;
  final List<ClickParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _clickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _clickController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    
    // Trigger click animation
    _clickController.forward(from: 0);
    
    // Create particles
    setState(() {
      final random = Random();
      for (int i = 0; i < 8; i++) {
        _particles.add(ClickParticle(
          angle: random.nextDouble() * 2 * pi,
          speed: 50 + random.nextDouble() * 50,
          startTime: DateTime.now(),
        ));
      }
    });

    // Clean up old particles
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _particles.removeWhere((p) => 
            DateTime.now().difference(p.startTime).inMilliseconds > 500
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            AnimatedBuilder(
              animation: _clickController,
              builder: (context, child) {
                return Container(
                  width: widget.size + (_clickController.value * 20),
                  height: widget.size + (_clickController.value * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00ffff).withOpacity(
                          0.3 * (1 - _clickController.value),
                        ),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Asteroid
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * pi,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: AsteroidPainter(),
                  ),
                );
              },
            ),

            // Particles
            ...(_particles.map((particle) => _buildParticle(particle))),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(ClickParticle particle) {
    final elapsed = DateTime.now().difference(particle.startTime).inMilliseconds;
    final progress = (elapsed / 500).clamp(0.0, 1.0);
    
    final distance = particle.speed * progress;
    final opacity = 1.0 - progress;
    
    final dx = cos(particle.angle) * distance;
    final dy = sin(particle.angle) * distance;

    return Positioned(
      left: widget.size / 2 + dx,
      top: widget.size / 2 + dy,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF00ffff),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00ffff).withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClickParticle {
  final double angle;
  final double speed;
  final DateTime startTime;

  ClickParticle({
    required this.angle,
    required this.speed,
    required this.startTime,
  });
}

/// Custom painter for asteroid
class AsteroidPainter extends CustomPainter {
  final Random _random = Random(123);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Base asteroid color
    final basePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6b6b6b),
          const Color(0xFF4a4a4a),
          const Color(0xFF2a2a2a),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Draw base circle
    canvas.drawCircle(center, radius, basePaint);

    // Add craters
    _drawCraters(canvas, center, radius);

    // Add rocky texture
    _drawRockyTexture(canvas, center, radius);

    // Add highlight
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
          radius: radius * 0.4,
        ),
      );

    canvas.drawCircle(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
      radius * 0.4,
      highlightPaint,
    );
  }

  void _drawCraters(Canvas canvas, Offset center, double radius) {
    final craterPaint = Paint()..color = const Color(0xFF1a1a1a);

    final craterRandom = Random(456);
    for (int i = 0; i < 12; i++) {
      final angle = craterRandom.nextDouble() * 2 * pi;
      final distance = craterRandom.nextDouble() * radius * 0.7;
      final craterRadius = 5 + craterRandom.nextDouble() * 15;

      final craterCenter = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      canvas.drawCircle(craterCenter, craterRadius, craterPaint);
    }
  }

  void _drawRockyTexture(Canvas canvas, Offset center, double radius) {
    final texturePaint = Paint()
      ..color = const Color(0xFF3a3a3a)
      ..style = PaintingStyle.fill;

    final textureRandom = Random(789);
    for (int i = 0; i < 30; i++) {
      final angle = textureRandom.nextDouble() * 2 * pi;
      final distance = textureRandom.nextDouble() * radius * 0.9;
      final size = 2 + textureRandom.nextDouble() * 4;

      final point = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      canvas.drawCircle(point, size, texturePaint);
    }
  }

  @override
  bool shouldRepaint(AsteroidPainter oldDelegate) => false;
}
