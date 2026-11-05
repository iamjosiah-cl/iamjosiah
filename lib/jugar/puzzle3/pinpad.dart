import 'package:flutter/material.dart';
import 'package:portafolio/portfolio_web/portafolio.dart';
import 'puzzle3.dart';

class ColorGrid extends StatefulWidget {
  const ColorGrid({super.key});

  @override
  State<ColorGrid> createState() => _ColorGridState();
}

class _ColorGridState extends State<ColorGrid> {
  final List<Color> colorCycle = [
    Colors.black,
    Colors.green,
    Colors.red,
    Colors.amber,
    Colors.blue,
  ];

  final List<Color> correctOrder = [
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.amber,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.amber,
    Colors.green,
  ];

  List<int> colorIndices = List.filled(9, 0);

  void _changeColor(int index) {
    setState(() {
      colorIndices[index] = (colorIndices[index] + 1) % colorCycle.length;
    });

    _verificarColores();
  }

  void _verificarColores() {
    bool esCorrecto = true;
    for (int i = 0; i < 9; i++) {
      if (colorCycle[colorIndices[i]] != correctOrder[i]) {
        esCorrecto = false;
        break;
      }
    }

    if (esCorrecto) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("¡Correcto!"),
          content: const Text("Has ordenado los colores correctamente."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPortfolio()),
                );
              },
              child: const Text("Aceptar"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Puzzle3()),
          );
        },
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey[700]!, width: 1.5),
              ),
              color: Colors.grey[850],
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[850]!, Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Cambia los colores para que sean como el patrón",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          Color baseColor = colorCycle[colorIndices[index]];
                          return GestureDetector(
                            onTap: () => _changeColor(index),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    baseColor.withOpacity(0.85),
                                    Colors.black,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(4, 4),
                                    blurRadius: 6,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.05),
                                    offset: const Offset(-2, -2),
                                    blurRadius: 6,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[700]!),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
