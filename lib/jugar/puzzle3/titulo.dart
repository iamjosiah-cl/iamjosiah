import 'package:flutter/material.dart';
import 'puzzle3.dart';

class Inicio3 extends StatefulWidget {
  const Inicio3({super.key});

  @override
  State<Inicio3> createState() => _Inicio3State();
}

class _Inicio3State extends State<Inicio3> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  bool _showButton = false;
  bool _showOverlay = false;
  double _overlayOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

    Future.delayed(const Duration(seconds: 2), () async {
      await _ctrl.forward();
      if (mounted) setState(() => _showButton = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goToNextScreen() {
    setState(() {
      _showOverlay = true;
      _overlayOpacity = 1.0;
    });

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Puzzle3()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // No portrait orientation check - removed as requested
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _LightPainter(progress: _anim.value),
          ),
        ),
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Puzzle 3',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              Text(
                '"Patrones y colores"',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: _showButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Center(
              child: ElevatedButton(
                onPressed: _goToNextScreen,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Continuar'),
              ),
            ),
          ),
        ),
        if (_showOverlay)
          AnimatedOpacity(
            opacity: _overlayOpacity,
            duration: const Duration(milliseconds: 800),
            child: Container(color: Colors.black),
          ),
      ],
    );
  }
}

class _LightPainter extends CustomPainter {
  final double progress;
  const _LightPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.black;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final center = Offset(size.width / 2, size.height * 0.05);
    final radius = size.shortestSide * (0.2 + 1.2 * progress);

    final gradient = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.8 * progress),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 0.4, 1.0],
    );

    final lightPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..blendMode = BlendMode.plus;

    canvas.drawRect(Offset.zero & size, lightPaint);
  }

  @override
  bool shouldRepaint(covariant _LightPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
