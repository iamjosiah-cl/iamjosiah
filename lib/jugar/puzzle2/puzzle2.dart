import 'package:flutter/material.dart';
import '../../jugar/interactive.dart';
import '../dashboard_juegos.dart';
import 'left.dart';
import 'right.dart';
import 'pinpad.dart';

class Puzzle2 extends StatefulWidget {
  const Puzzle2({super.key});

  @override
  State<Puzzle2> createState() => _Puzzle2State();
}

class _Puzzle2State extends State<Puzzle2> with SingleTickerProviderStateMixin {
  static bool _introAlreadyShown = false;
  bool _isLoading = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_introAlreadyShown) {
        _introAlreadyShown = true;
        _showIntroDialog();
      }
    });

    // Start loading immediately in web context (or wait for layout)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted) {
         setState(() => _isLoading = false);
         _fadeController.forward();
      }
    });
  }

  void _showIntroDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'IntroDialog',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: AlertDialog(
            title: const Text('Desafío 2'),
            content: const Text('Este es tu segundo desafío. Intenta escapar, no hay más información.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToPinpad(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const PinpadScreen(),
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

  void _navigateToGamepage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const GamesPage()));
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
                _navigateToGamepage(context);
              },
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(),
      );
    }

    return Scaffold(
      body: HorizontalLayoutWrapper(
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
            Positioned(
              top: 40,
              right: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: Colors.white),
                    iconSize: 30,
                    onPressed: _showIntroDialog,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.home, color: Colors.white),
                    iconSize: 36,
                    onPressed: () => _confirmExitToHome(context),
                  ),
                ],
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
    );
  }
}
