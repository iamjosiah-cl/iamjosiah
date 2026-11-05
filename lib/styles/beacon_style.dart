import 'package:flutter/material.dart';

class BeaconStyle {
  // Paleta unificada (slate + cyan/violet)
  static const backgroundColor = Color(0xFF0B1220);

  static const cardBg = Color(0xFF0F172A); // slate-900
  static const cardBgGlass = Color(0xB30F172A); // slate-900 @ 70%
  static const cardBorder = Color(0x1FFFFFFF); // blanco @ 12%
  static const cardBorderHover = Color(0x5922D3EE); // cyan @ 35%

  static const textPrimary = Color(0xFFE2E8F0); // slate-200
  static const textSecondary = Color(0xFF94A3B8); // slate-400

  static const iconMuted = Color(0xFFCBD5E1); // slate-300

  static const accent = Color(0xFF22D3EE); // cyan-400
  static const accentViolet = Color(0xFF8B5CF6); // violet-500

  // Gradiente marca (cyan -> violet)
  static const accentGrad = LinearGradient(
    colors: [accent, accentViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const radius = 16.0;

  /// Transiciones de página cortas (fade de 180 ms, sin zoom).
  static const fastTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _FastFadeTransitionsBuilder(),
      TargetPlatform.iOS: _FastFadeTransitionsBuilder(),
      TargetPlatform.windows: _FastFadeTransitionsBuilder(),
      TargetPlatform.macOS: _FastFadeTransitionsBuilder(),
      TargetPlatform.linux: _FastFadeTransitionsBuilder(),
      TargetPlatform.fuchsia: _FastFadeTransitionsBuilder(),
    },
  );

  static final ThemeData _theme = _buildTheme();

  /// Tema global de la app (Material 3, oscuro).
  static ThemeData theme() => _theme;

  static ThemeData _buildTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      surface: cardBg,
    ).copyWith(primary: accent, secondary: accentViolet);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: backgroundColor,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      pageTransitionsTheme: fastTransitions,
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorder),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardBg,
        showDragHandle: true,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cardBorder),
        ),
        textStyle: const TextStyle(color: textPrimary, fontSize: 12),
        waitDuration: const Duration(milliseconds: 300),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x0DFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(const Color(0x33FFFFFF)),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),
    );
  }
}

class _FastFadeTransitionsBuilder extends PageTransitionsBuilder {
  const _FastFadeTransitionsBuilder();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 180);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }
}

/* ──────────────────────────  BACKGROUND  ────────────────────────── */

/// Fondo con "orbes" de luz suaves.
///
/// Antes eran 30 círculos animados con blur que se repintaban cada frame
/// (muy costoso en web). Ahora son gradientes radiales estáticos: mismo
/// ambiente visual, costo prácticamente nulo. Se mantiene el nombre para
/// no romper los usos existentes.
class AnimatedBackgroundOrbs extends StatelessWidget {
  const AnimatedBackgroundOrbs({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(color: BeaconStyle.backgroundColor),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Glow(
              alignment: Alignment(-0.9, -0.85),
              color: Color(0x4022D3EE), // cyan
              radius: 0.9,
            ),
            _Glow(
              alignment: Alignment(1.0, -0.2),
              color: Color(0x388B5CF6), // violet
              radius: 0.8,
            ),
            _Glow(
              alignment: Alignment(-0.4, 1.1),
              color: Color(0x262563EB), // blue
              radius: 1.0,
            ),
            _GridOverlay(),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double radius;

  const _Glow({
    required this.alignment,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: alignment,
          radius: radius,
          colors: [color, color.withAlpha(0)],
        ),
      ),
    );
  }
}

/// Cuadrícula muy sutil, típica de los sitios "tech" actuales.
class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(child: CustomPaint(painter: _GridPainter()));
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const step = 48.0;
    final paint = Paint()
      ..color = const Color(0x08FFFFFF)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
