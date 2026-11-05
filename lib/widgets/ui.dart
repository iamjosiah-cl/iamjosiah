import 'package:flutter/material.dart';
import 'package:portafolio/styles/beacon_style.dart';

/// Barra de acento con el gradiente de marca, usada bajo los títulos.
class AccentBar extends StatelessWidget {
  final double width;
  const AccentBar({super.key, this.width = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      width: width,
      decoration: BoxDecoration(
        gradient: BeaconStyle.accentGrad,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Texto pintado con el gradiente de marca.
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.gradient = BeaconStyle.accentGrad,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

/// Píldora pequeña tipo "eyebrow" sobre los títulos.
class EyebrowChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  const EyebrowChip(this.label, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: BeaconStyle.accent.withAlpha(20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: BeaconStyle.accent.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: BeaconStyle.accent),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: BeaconStyle.accent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta "glass" con borde que se ilumina y leve elevación al hover.
class HoverCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final VoidCallback? onTap;
  final double radius;

  const HoverCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.width,
    this.onTap,
    this.radius = BeaconStyle.radius,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      width: widget.width,
      padding: widget.padding,
      transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
      decoration: BoxDecoration(
        color: _hover ? const Color(0xCC111C33) : BeaconStyle.cardBgGlass,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: _hover ? BeaconStyle.cardBorderHover : BeaconStyle.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: _hover ? const Color(0x2622D3EE) : const Color(0x33000000),
            blurRadius: _hover ? 24 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: widget.child,
    );

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: widget.onTap == null
          ? card
          : GestureDetector(onTap: widget.onTap, child: card),
    );
  }
}
