import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Ajustes globales de animación.
///
/// Las animaciones de entrada deben sentirse instantáneas: duración corta,
/// desplazamiento mínimo y retrasos acotados para que el contenido nunca
/// "espere" a aparecer.
class MotionConfig {
  static const Duration enterDuration = Duration(milliseconds: 380);

  /// Los retrasos que piden los widgets se escalan y se limitan a este máximo,
  /// así un escalonado de 200/400/600/800 ms queda en 40/80/120/150 ms.
  static const Duration maxDelay = Duration(milliseconds: 150);
  static const double delayScale = 0.2;

  static Duration clampDelay(Duration requested) {
    final scaled = Duration(
      microseconds: (requested.inMicroseconds * delayScale).round(),
    );
    return scaled > maxDelay ? maxDelay : scaled;
  }
}

class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final bool animateInView;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = MotionConfig.enterDuration,
    this.offset = const Offset(0, 0.04),
    this.animateInView = false,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  final Key _visibilityKey = UniqueKey();
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    // Nunca más lento que la duración global, aunque alguien pida 800 ms.
    final duration = widget.duration > MotionConfig.enterDuration
        ? MotionConfig.enterDuration
        : widget.duration;
    _controller = AnimationController(vsync: this, duration: duration);

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = curve;
    // Desplazamiento limitado: solo una insinuación de movimiento.
    final o = widget.offset;
    _offset = Tween<Offset>(
      begin: Offset(o.dx.clamp(-0.06, 0.06), o.dy.clamp(-0.06, 0.06)),
      end: Offset.zero,
    ).animate(curve);

    if (!widget.animateInView) _startAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respeta "reducir movimiento" del sistema.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _hasAnimated = true;
      _controller.value = 1;
    }
  }

  void _startAnimation() {
    if (_hasAnimated) return;
    _hasAnimated = true;
    final delay = MotionConfig.clampDelay(widget.delay);
    if (delay == Duration.zero) {
      _controller.forward();
      return;
    }
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animatedChild = FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );

    // Se mantiene el VisibilityDetector siempre (aunque ya haya animado) para
    // no cambiar la estructura del árbol y perder el estado de los hijos.
    if (widget.animateInView) {
      return VisibilityDetector(
        key: _visibilityKey,
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.05) _startAnimation();
        },
        child: animatedChild,
      );
    }
    return animatedChild;
  }
}

/// Antes escribía el texto letra por letra (2 s). Ahora el texto aparece
/// completo de inmediato con un fade corto: se puede leer al instante.
/// Se mantiene la API para no romper los usos existentes.
class TypingText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final Duration startDelay;
  final bool animateInView;

  const TypingText({
    super.key,
    required this.text,
    required this.style,
    this.duration = Duration.zero,
    this.startDelay = Duration.zero,
    this.animateInView = false,
  });

  @override
  Widget build(BuildContext context) => Text(text, style: style);
}
