import 'package:flutter/material.dart';
import 'package:portafolio/jugar/game_wrapper.dart';
import 'package:portafolio/jugar/space_miner/space_miner_game.dart';

/// Intro screen for Space Miner game
class InicioSpaceMiner extends StatefulWidget {
  const InicioSpaceMiner({super.key});

  @override
  State<InicioSpaceMiner> createState() => _InicioSpaceMinerState();
}

class _InicioSpaceMinerState extends State<InicioSpaceMiner>
    with SingleTickerProviderStateMixin {
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

    // Start animation after delay
    Future.delayed(const Duration(seconds: 1), () async {
      await _ctrl.forward();
      if (mounted) setState(() => _showButton = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goToGame() {
    setState(() {
      _showOverlay = true;
      _overlayOpacity = 1.0;
    });

    Future.delayed(const Duration(seconds: 1), () {
      final isFullScreen = GameWrapper.of(context)?.isFullScreen ?? false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameWrapper(
            initialFullScreen: isFullScreen,
            child: const SpaceMinerGame(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _SpaceIntroPainter(progress: _anim.value),
            ),
          ),

          // Title and subtitle
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated title
                AnimatedBuilder(
                  animation: _anim,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _anim.value,
                      child: Transform.scale(
                        scale: 0.5 + (_anim.value * 0.5),
                        child: child,
                      ),
                    );
                  },
                  child: const Text(
                    'Space Miner',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00ffff),
                      shadows: [
                        Shadow(
                          color: Color(0xFF00ffff),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _anim,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _anim.value,
                      child: child,
                    );
                  },
                  child: const Text(
                    'Minería Espacial Incremental',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF9d4edd),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Continue button
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Center(
                child: ElevatedButton(
                  onPressed: _goToGame,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 20,
                    ),
                    backgroundColor: const Color(0xFF00ffff).withOpacity(0.2),
                    foregroundColor: const Color(0xFF00ffff),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(
                        color: Color(0xFF00ffff),
                        width: 2,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Comenzar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Fade to black overlay
          if (_showOverlay)
            AnimatedOpacity(
              opacity: _overlayOpacity,
              duration: const Duration(milliseconds: 800),
              child: Container(color: Colors.black),
            ),
        ],
      ),
    );
  }
}

/// Custom painter for intro background
class _SpaceIntroPainter extends CustomPainter {
  final double progress;

  const _SpaceIntroPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Deep space background
    final bgRect = Offset.zero & size;
    canvas.drawRect(
      bgRect,
      Paint()..color = const Color(0xFF0a0e27),
    );

    // Animated glow from center
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * (0.3 + 0.7 * progress);

    final shader = RadialGradient(
      colors: [
        const Color(0xFF00ffff).withOpacity(0.3 * progress),
        const Color(0xFF9d4edd).withOpacity(0.2 * progress),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = shader
        ..blendMode = BlendMode.plus,
    );

    // Stars
    final starPaint = Paint()..color = Colors.white.withOpacity(0.8);
    for (int i = 0; i < 50; i++) {
      final x = (i * 123.456) % size.width;
      final y = (i * 789.012) % size.height;
      final starSize = 1.0 + (i % 3);
      
      canvas.drawCircle(Offset(x, y), starSize * progress, starPaint);
    }
  }

  @override
  bool shouldRepaint(_SpaceIntroPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
