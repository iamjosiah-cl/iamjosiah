import 'package:flutter/material.dart';
import '../../jugar/interactive.dart';
import 'puzzle2.dart';
import 'back.dart';

class LeftWallScreen extends StatefulWidget {
  const LeftWallScreen({super.key});

  @override
  State<LeftWallScreen> createState() => _LeftWallScreenState();
}

class _LeftWallScreenState extends State<LeftWallScreen> {
  String? _selectedPosterId;
  bool _cartelRevealed = false;
  bool _isLoading = true;

  final Map<String, Map<String, dynamic>> postersData = {
    'flayer': {
      'title': 'Volante',
      'icon': Icons.campaign,
      'color': Colors.redAccent,
      'content': '¡Gran evento este fin de semana!\nNo te lo pierdas.',
    },
    'pista': {
      'title': 'Nota Curiosa',
      'icon': Icons.lightbulb,
      'color': Colors.yellow.shade700,
      'content': 'El número 1 es clave...\npero cuidado con el orden.\n\n□-1-□-□',
    },
    'cartel1': {
      'title': 'Aviso',
      'icon': Icons.warning,
      'color': Colors.orange,
      'content': 'Piso resbaladizo.\nTenga precaución.\n\n5 -□-□-□',
    },
    'cartel2': {
      'title': 'Información',
      'icon': Icons.info,
      'color': Colors.blue,
      'content': 'Horario de atención:\nLunes a Viernes 9:00 - 18:00',
    },
  };

  void _showPoster(String id) {
    setState(() {
      _selectedPosterId = id;
      _cartelRevealed = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
       setState(() => _isLoading = false);
    }
  }

  void _hidePoster() {
    setState(() {
      _selectedPosterId = null;
      _cartelRevealed = false;
    });
  }

  void _onPosterTap() {
    if (_selectedPosterId == 'pista' && !_cartelRevealed) {
      setState(() {
        _cartelRevealed = true;
      });
    } else {
      _hidePoster();
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    return Scaffold(
      body: HorizontalLayoutWrapper(
        child: Stack(
          children: [
            // Fondo muralla
            Positioned.fill(
              child: Container(color: Colors.grey[850]),
            ),

            // Texto superior con ícono de lupa
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Puedes ver información \n en los carteles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Imágenes en fila centrada
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...postersData.keys.map((key) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _poster(key),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Imagen ampliada
            if (_selectedPosterId != null)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _onPosterTap,
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Colors.white24, blurRadius: 20)],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              postersData[_selectedPosterId]!['icon'] as IconData,
                              size: 60,
                              color: postersData[_selectedPosterId]!['color'] as Color,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              postersData[_selectedPosterId]!['title'] as String,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              postersData[_selectedPosterId]!['content'] as String,
                              style: const TextStyle(fontSize: 18, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "(Toca para cerrar)",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Flecha izquierda → BackWall (Animated)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  iconSize: 48,
                  onPressed: () {
                     // Navigating "Left" from Left Wall goes to Back Wall
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 600),
                        pageBuilder: (_,__,___) => const BackWallScreen(),
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
            ),

            // Flecha derecha → Puzzle2 (Animated)
            Positioned(
              right: 20,
              top: MediaQuery.of(context).size.height / 2 - 24,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                iconSize: 48,
                onPressed: () {
                  // Navigating "Right" from Left Wall goes to Front (Puzzle2)
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 600),
                        pageBuilder: (_,__,___) => const Puzzle2(),
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
    );
  }


  Widget _poster(String id) {
    final data = postersData[id]!;
    return GestureDetector(
      onTap: () => _showPoster(id),
      child: Container(
        width: 160,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 3,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(data['icon'] as IconData, size: 50, color: data['color'] as Color),
            const SizedBox(height: 12),
            Text(
              data['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
