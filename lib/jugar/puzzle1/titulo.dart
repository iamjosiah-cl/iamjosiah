import 'package:flutter/material.dart';
import 'package:portafolio/jugar/puzzle1/puzzle1.dart';
import 'package:portafolio/jugar/game_wrapper.dart';

class Inicio1 extends StatefulWidget {
  const Inicio1({super.key});

  @override
  State<Inicio1> createState() => _Inicio1State();
}

class _Inicio1State extends State<Inicio1> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>     _anim;

  bool _showButton      = false;
  bool _showOverlay     = false;
  double _overlayOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

    // Arranque escalonado (solo la primera vez)
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
      _showOverlay     = true;
      _overlayOpacity  = 1.0;
    });

    Future.delayed(const Duration(seconds: 1), () {
      final isFullScreen = GameWrapper.of(context)?.isFullScreen ?? false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GameWrapper(
          initialFullScreen: isFullScreen,
          child: const Puzzle1(),
        )),
      );
    });
  }

  // ──────────────────────────────────────────────────────────
  // 📐  UI
  // ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Forzamos "simulación" de landscape (o sugerimos, 
    // pero para web esto suele ser desktop landscape de todos modos).
    // Si quieres bloquear la orientación, normalmente se requiere 'flutter/services.dart'
    // y SystemChrome, pero en web/desktop esto no siempre aplica.
    // Usaremos LayoutBuilder para adaptar si es muy angosto (mobile portrait).

    return LayoutBuilder(
      builder: (context, constraints) {
        // Simple check: si es más alto que ancho (portrait)
        bool isPortrait = constraints.maxHeight > constraints.maxWidth;



        // Landscape view
        return Scaffold(
          body: Stack(
            children: [
              AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _LightPainter(progress: _anim.value),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Puzzle 1',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Aseguramos contraste
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '"Niveles de azúcar"',
                      style: TextStyle(fontSize: 36, color: Colors.white,),
                    ),
                  ],
                ),
              ),
              // Botón “Continuar”
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        backgroundColor: Colors.orange.shade100,
                        foregroundColor: Colors.black87,
                        elevation: 4,
                      ),
                      child: const Text('Continuar'),
                    ),
                  ),
                ),
              ),
              // Fundido negro antes de navegar
              if (_showOverlay)
                AnimatedOpacity(
                  opacity: _overlayOpacity,
                  duration: const Duration(milliseconds: 800),
                  child: Container(color: Colors.black),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────
// 🎨  Painter de luz
// ──────────────────────────────────────────────────────────
class _LightPainter extends CustomPainter {
  final double progress;
  const _LightPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo negro
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black,
    );

    // Luz
    final center = Offset(size.width / 2, size.height * 0.05);
    final radius = size.shortestSide * (0.2 + 1.2 * progress);

    final shader = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.8 * progress),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader    = shader
        ..blendMode = BlendMode.plus,
    );
  }

  @override
  bool shouldRepaint(covariant _LightPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
