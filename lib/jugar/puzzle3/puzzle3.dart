import 'package:flutter/material.dart';
import '../../jugar/interactive.dart';
import 'package:portafolio/portfolio_web/portafolio.dart';
import 'back.dart';
import 'pinpad.dart';

class Puzzle3 extends StatefulWidget {
  const Puzzle3({super.key});

  @override
  State<Puzzle3> createState() => _Puzzle3State();
}

class _Puzzle3State extends State<Puzzle3> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _opacity = 1.0);
    });
  }

  void _navigateToPinpad(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const ColorGrid(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ));
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MyPortfolio()),
    );
  }

  void _confirmExitToHome(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                _navigateToHome(context);
              },
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );
  }

  void _navigateLeft(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BackWallScreen()));
  }

  void _navigateRight(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BackWallScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: HorizontalLayoutWrapper(
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: Stack(
                children: [
                  // Closed door - reused from Puzzle 1
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
                                offset: const Offset(0, 5),
                              )
                            ],
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Interactive arrows
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

                  // Help and Home icons
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
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Pista'),
                                  content: const Text('Fíjate bien de los colores.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
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

                  // Pinpad - styled container instead of image
                  Center(
                    child: GestureDetector(
                      onTap: () => _navigateToPinpad(context),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[600]!, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.grid_3x3,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'PINPAD',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
