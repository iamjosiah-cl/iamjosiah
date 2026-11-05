import 'package:flutter/material.dart';
import 'package:portafolio/jugar/dashboard_juegos.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFF0B1120);
    final textColor = Colors.white.withOpacity(0.7);
    final accentColor = const Color(0xFF60A5FA); // Azul claro
    final heartColor = Colors.red;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IZQUIERDA
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: const [
                        TextSpan(text: 'Iam'),
                        TextSpan(
                          text: ' Josiah',
                          style: TextStyle(color: Color(0xFF60A5FA)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingeniero Civil en Informática apasionado\\n'
                        'por el desarrollo de software y la innovación tecnológica.',
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // DERECHA
              Column(
                crossAxisAlignment:
                isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                 Wrap(
                   spacing: 24,
                   children: [
                     _HoverLink(
                       text: '¿Aún quieres jugar? aquí estoy :)',
                       baseStyle: TextStyle(color: textColor),
                       hoverColor: accentColor,
                       onTap: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(builder: (context) => const GamesPage()),
                         );
                       },
                     ),
                   ],
                 ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '© ${DateTime.now().year} Josías Jofré. Hecho con ',
                        style: TextStyle(color: textColor),
                      ),
                      Icon(Icons.favorite, color: heartColor, size: 16),
                      const SizedBox(width: 4),
                      Text('en Chile', style: TextStyle(color: textColor)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HoverLink extends StatefulWidget {
  final String text;
  final TextStyle baseStyle;
  final Color hoverColor;
  final VoidCallback onTap;

  const _HoverLink({
    required this.text,
    required this.baseStyle,
    required this.hoverColor,
    required this.onTap,
  });

  @override
  State<_HoverLink> createState() => _HoverLinkState();
}

class _HoverLinkState extends State<_HoverLink> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_)  => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: widget.baseStyle.copyWith(
            color: _isHovering ? widget.hoverColor : widget.baseStyle.color,
            decoration: _isHovering ? TextDecoration.underline : TextDecoration.none,
            decorationColor: widget.hoverColor,
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}
