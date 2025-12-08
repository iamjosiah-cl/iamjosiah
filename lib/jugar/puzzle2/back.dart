import 'package:flutter/material.dart';
import '../../jugar/interactive.dart';
import 'left.dart';
import 'right.dart';

class BackWallScreen extends StatefulWidget {
  const BackWallScreen({super.key});

  @override
  State<BackWallScreen> createState() => _BackWallScreenState();
}

class _BackWallScreenState extends State<BackWallScreen>
    with SingleTickerProviderStateMixin {
  bool _showClave = false;
  late AnimationController _blinkController;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 1, end: 0.3).animate(_blinkController);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HorizontalLayoutWrapper(
        child: Stack(
          children: [
            // Fondo muralla
            Positioned.fill(
              child: Container(color: Colors.grey[850]),
            ),

            // Flecha izquierda para ir a LeftWall ... Wait.
            // If we are at BACK.
            // If I turn LEFT (arrow left on screen), I face RIGHT wall? 
            // Standard perspective:
            // FRONT (Puzzle2) -> Turn Left -> LEFT WALL.
            // LEFT WALL -> Turn Left -> BACK WALL.
            // BACK WALL -> Turn Left -> RIGHT WALL.
            // RIGHT WALL -> Turn Left -> FRONT.
            
            // So:
            // At LEFT, Left Arrow -> BACK.
            // At BACK, Left Arrow -> RIGHT.
            // At RIGHT, Left Arrow -> FRONT. 
            // At FRONT, Left Arrow -> LEFT.

            // And Right Arrows:
            // FRONT -> Turn Right -> RIGHT.
            // RIGHT -> Turn Right -> BACK.
            // BACK -> Turn Right -> LEFT.
            // LEFT -> Turn Right -> FRONT.

            // My implementation so far:
            // P2 (Front): Left -> LeftWall. (Correct)
            // LeftWall: Left -> BackWall. (Correct)
            // BackWall: Left -> RightWall. (Correct)
            // RightWall: Left -> Front. (Correct)

            // Pizarra con clave encima
            Center(
              child: GestureDetector(
                onTap: () {
                  if (!_showClave) {
                    setState(() {
                      _showClave = true;
                      _blinkController.stop();
                    });
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  constraints: const BoxConstraints(maxWidth: 600, maxHeight: 400),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3B33), // Blackboard green
                    border: Border.all(color: Colors.brown[700]!, width: 12),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                       BoxShadow(
                         color: Colors.black45,
                         blurRadius: 10,
                         offset: Offset(0, 10),
                       )
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                       // Chalk trace effect (simulated)
                       Positioned.fill(
                         child: Opacity(
                            opacity: 0.1, 
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.transparent, Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              ),
                            )
                         )
                       ),
                       
                       // Clue Text
                       if (_showClave)
                          TweenAnimationBuilder<double>(
                            duration: const Duration(seconds: 2),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: child,
                              );
                            },
                             child: const Column(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Text(
                                   "CLAVE SECRETA",
                                   style: TextStyle(
                                     fontFamily: 'Courier',
                                     color: Colors.white70,
                                     fontSize: 24,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                                 SizedBox(height: 20),
                                 Text(
                                   "□-□-□-8",
                                   style: TextStyle(
                                     fontFamily: 'Courier',
                                     color: Colors.white,
                                     fontSize: 50,
                                     fontWeight: FontWeight.bold,
                                     letterSpacing: 4
                                   ),
                                 ),
                               ]
                             ),
                          ),

                       // "Touch me" hint
                       if (!_showClave)
                          FadeTransition(
                            opacity: _opacity,
                             child: const Text(
                               "?",
                               style: TextStyle(
                                 color: Colors.white54,
                                 fontSize: 28,
                                 fontFamily: 'UnknownFont', // Fallback to default
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                          ),
                    ],
                  ),
                ),
              ),
            ),

            // Flechas de navegación en la parte inferior
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Flecha izquierda -> Right Wall
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      iconSize: 48,
                      onPressed: () {
                         // Back -> Left Arrow -> Right Wall
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 600),
                            pageBuilder: (_,__,___) => const RightWallScreen(),
                            transitionsBuilder: (_, animation, __, child) {
                               final offset = Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                                 .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
                               return SlideTransition(position: offset, child: child);
                            }
                          ),
                        );
                      },
                    ),
                  ),

                  // Flecha derecha -> Left Wall
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      iconSize: 48,
                      onPressed: () {
                        // Back -> Right Arrow -> Left Wall
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 600),
                            pageBuilder: (_,__,___) => const LeftWallScreen(),
                            transitionsBuilder: (_, animation, __, child) {
                               final offset = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                                 .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
                               return SlideTransition(position: offset, child: child);
                            }
                          ),
                        );
                      },
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
