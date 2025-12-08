import 'package:flutter/material.dart';

import 'package:portafolio/jugar/puzzle1/left.dart';
import 'package:portafolio/jugar/puzzle1/pinpad.dart';
import 'package:portafolio/jugar/puzzle1/right.dart';
import 'package:portafolio/jugar/dashboard_juegos.dart';

// Helper for horizontal layout
class HorizontalLayoutWrapper extends StatelessWidget {
  final Widget child;
  const HorizontalLayoutWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) => child;
}

// Helper for InteractiveArrow
class InteractiveArrow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const InteractiveArrow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.black54,
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class Puzzle1 extends StatefulWidget {
  const Puzzle1({super.key});

  @override
  State<Puzzle1> createState() => _Puzzle1State();
}

class _Puzzle1State extends State<Puzzle1> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Removed Firebase/Session tracking as this is a standalone portfolio version.

    // Espera al primer frame antes de iniciar animación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isLoading = false);

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _mostrarAlertaInicial();
      });
    });
  }

  void _mostrarAlertaInicial() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Alerta',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, _, __) {
        return FadeTransition(
          opacity: animation,
          child: AlertDialog(
            title: const Text('Escapa de la Mansión', style: TextStyle(fontSize: 24)),
            content: const Text('Encuentra el código para poder salir.', style: TextStyle(fontSize: 18)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Empezar', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToGamepage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GamesPage()),
    );
  }

  void _navigateToPinpad(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, _) => const PinpadScreen(),
        transitionsBuilder: (context, animation, _, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _navigateLeft(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, _) => const LeftWallScreen(),
        transitionsBuilder: (context, animation, _, child) {
          // Slide from Left (-1.0)
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _navigateRight(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, _) => const RightWallScreen(),
        transitionsBuilder: (context, animation, _, child) {
          // Slide from Right (1.0)
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _confirmExitToHome(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Salir al menú de juegos?'),
        content: const Text('¿Estás seguro de que quieres salir del desafío?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToGamepage(context);
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          HorizontalLayoutWrapper(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.brown[900], // Dark wall
                    child: Center(
                      child: Container(
                        width: 300,
                        height: 500,
                        decoration: BoxDecoration(
                          color: Colors.brown[700],
                          border: Border.all(color: Colors.black, width: 8),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                             BoxShadow(
                               color: Colors.black.withOpacity(0.5), 
                               blurRadius: 10,
                               offset: const Offset(0, 5)
                            )
                          ]
                        ),
                        child: Stack(
                          children: [
                            // Frame details
                            Container(
                               margin: const EdgeInsets.all(16),
                               decoration: BoxDecoration(
                                 border: Border.all(color: Colors.brown[800]!, width: 2),
                               ),
                            ),
                            // Door Handle
                            Positioned(
                              right: 20,
                              top: 250,
                              child: Container(
                                width: 15,
                                height: 15,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.amber,
                                  boxShadow: [
                                    BoxShadow(blurRadius: 2, color: Colors.black45)
                                  ]
                                )
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.help_outline, color: Colors.white),
                        iconSize: 30,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Pista'),
                              content: const Text('¿Encontraste: "📄"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.home, color: Colors.white),
                        iconSize: 36,
                        onPressed: () => _confirmExitToHome(context),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  top: MediaQuery.of(context).size.height / 2 - 48,
                  child: InteractiveArrow(
                    icon: Icons.arrow_back_ios_new,
                    label: 'Ir hacia\nla izquierda',
                    onTap: () => _navigateLeft(context),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: MediaQuery.of(context).size.height / 2 - 48,
                  child: InteractiveArrow(
                    icon: Icons.arrow_forward_ios,
                    label: 'Ir hacia\nla derecha',
                    onTap: () => _navigateRight(context),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () => _navigateToPinpad(context),
                    child: Container(
                      width: 120,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[600]!, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 8,
                            offset: Offset(4, 4),
                          )
                        ]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                           Container(
                             margin: const EdgeInsets.symmetric(horizontal: 12),
                             height: 30,
                             color: Colors.black,
                           ),
                           const Icon(Icons.grid_3x3, color: Colors.white54, size: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: _isLoading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: IgnorePointer(
              ignoring: !_isLoading,
              child: Container(
                color: Colors.black,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
