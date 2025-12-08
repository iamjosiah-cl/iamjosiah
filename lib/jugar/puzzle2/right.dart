import 'dart:math';
import 'package:flutter/material.dart';
import '../../jugar/interactive.dart';
import 'puzzle2.dart';
import 'back.dart';

class RightWallScreen extends StatefulWidget {
  const RightWallScreen({super.key});

  @override
  State<RightWallScreen> createState() => _RightWallScreenState();
}

class _RightWallScreenState extends State<RightWallScreen> {
  // String? _imagenExpandida; removed inside state logic

  final int filas = 5;
  final int columnas = 6;
  final int totalCajones = 5 * 6;

  List<bool> cajonesAbiertos = List.generate(5 * 6, (_) => false);
  int indiceConPista = Random().nextInt(5 * 6);

  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
       setState(() => _isLoading = false);
    }
  }

  bool _mostrarPista = false;

  void abrirCajon(int index) {
    setState(() {
      cajonesAbiertos[index] = true;
      if (index == indiceConPista) {
        _mostrarPista = true;
      }
    });
  }

  void _cerrarPista() {
    setState(() {
      _mostrarPista = false;
    });
  }

  Widget _buildCajon(int index) {
    final bool abierto = cajonesAbiertos[index];
    final bool esPista = index == indiceConPista;

    return GestureDetector(
      onTap: () => abrirCajon(index),
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: abierto ? Colors.brown[400] : Colors.brown[800],
          border: Border.all(color: Colors.brown.shade900, width: 4),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            if (!abierto)
              const BoxShadow(
                color: Colors.black45,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
          ],
        ),
        child: Center(
          child: abierto
              ? (esPista
                  ? const Icon(Icons.description, size: 40, color: Colors.white)
                  : null) // Empty drawer
              : Container( // Handle
                  width: 40,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0,1))]
                  ),
                ),
        ),
      ),
    );
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

            // Texto instructivo en la parte superior
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Busca entre los cajones',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Cajones en el centro
            Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 720,
                  height: 640,
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: columnas,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: List.generate(totalCajones, _buildCajon),
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
                  // Flecha izquierda → Puzzle2
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      iconSize: 48,
                      onPressed: () {
                        // Left from Right Wall goes to Puzzle2
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 600),
                            pageBuilder: (_,__,___) => const Puzzle2(),
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

                  // Flecha derecha → BackWall
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      iconSize: 48,
                      onPressed: () {
                         // Right from Right Wall goes to Back Wall
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 600),
                            pageBuilder: (_,__,___) => const BackWallScreen(),
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

            // Overlay de pista cuando se encuentra el cajón especial
            if (_mostrarPista)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _cerrarPista,
                  child: Container(
                    color: Colors.black.withOpacity(0.85),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5E6CA),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.description,
                              size: 60,
                              color: Colors.brown,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "PISTA ENCONTRADA",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "□-□-3-□",
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                                letterSpacing: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              "(Toca para cerrar)",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
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
