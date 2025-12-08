import 'dart:math';
import 'package:flutter/material.dart';

/// Animated space background with starfield
class SpaceBackground extends StatefulWidget {
  const SpaceBackground({super.key});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SpaceBackgroundPainter(
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SpaceBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random(42); // Fixed seed for consistent stars

  _SpaceBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Deep space background
    final bgRect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0a0e27),
          const Color(0xFF1a1a2e),
          const Color(0xFF16213e),
        ],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // Draw stars in multiple layers for parallax effect
    _drawStarLayer(canvas, size, 100, 1.0, 0.3);
    _drawStarLayer(canvas, size, 60, 1.5, 0.5);
    _drawStarLayer(canvas, size, 30, 2.0, 0.7);

    // Draw distant nebula
    _drawNebula(canvas, size);
  }

  void _drawStarLayer(
    Canvas canvas,
    Size size,
    int count,
    double speedMultiplier,
    double opacity,
  ) {
    final paint = Paint()..color = Colors.white.withOpacity(opacity);

    for (int i = 0; i < count; i++) {
      final starRandom = Random(i + count.hashCode);
      
      final x = starRandom.nextDouble() * size.width;
      final baseY = starRandom.nextDouble() * size.height;
      
      // Parallax movement
      final y = (baseY + (animationValue * size.height * speedMultiplier * 0.1)) % size.height;
      
      // Twinkle effect
      final twinkle = (sin(animationValue * 2 * pi + i) + 1) / 2;
      final starSize = (1.0 + twinkle) * 1.5;
      
      paint.color = Colors.white.withOpacity(opacity * (0.5 + twinkle * 0.5));
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  void _drawNebula(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.7, size.height * 0.3);
    final radius = size.width * 0.4;

    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF9d4edd).withOpacity(0.1),
          const Color(0xFF7209b7).withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, nebulaPaint);
  }

  @override
  bool shouldRepaint(_SpaceBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
