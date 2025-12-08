import 'package:flutter/material.dart';

// Helper for horizontal layout
class HorizontalLayoutWrapper extends StatelessWidget {
  final Widget child;
  const HorizontalLayoutWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) => child;
}

class RightWallScreen extends StatefulWidget {
  const RightWallScreen({super.key});

  @override
  State<RightWallScreen> createState() => _RightWallScreenState();
}

class _RightWallScreenState extends State<RightWallScreen> {

  // Identifiers for items
  final List<String> currentOrder = [
    'hormiga',
    'ballena',
    'elefante',
    'raton',
  ];

  final List<String> correctOrder = [
    'hormiga',
    'raton',
    'elefante',
    'ballena',
  ];

  final Map<String, Map<String, dynamic>> itemsData = {
    'hormiga': {'label': '🐜', 'emoji': '🐜'},
    'raton': {'label': '🐭', 'emoji': '🐭'},
    'elefante': {'label': '🐘', 'emoji': '🐘'},
    'ballena': {'label': '🐋', 'emoji': '🐋'},
  };

  bool _isLoading = true;
  double _opacity = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
      // No assets to preload
      if (mounted) {
        setState(() {
            _isLoading = false;
        });
        Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) setState(() => _opacity = 1.0);
        });
      }
  }

  void _checkOrder() {
    // Helper simple equality
    bool listsEqual = true;
    if (currentOrder.length != correctOrder.length) {
      listsEqual = false;
    } else {
      for (int i = 0; i < currentOrder.length; i++) {
        if (currentOrder[i] != correctOrder[i]) {
          listsEqual = false;
          break;
        }
      }
    }

    if (listsEqual) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("¡Correcto!", style: TextStyle(fontSize: 24)),
          content: const Text(
            '¡Excelente! Has ordenado los animales correctamente de menor a mayor tamaño. \n\n La contraseña es: 0368',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Aceptar", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      );
    }
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
      backgroundColor: Colors.black,
      body: HorizontalLayoutWrapper(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.grey[850]),
              ),

              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600, maxHeight: 280),
                  width: double.infinity,
                  height: 280,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white70, width: 2),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Center(
                              child: Text(
                                'Puedes deslizar los elementos',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          Expanded(
                            child: ReorderableListView(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(
                                horizontal: (constraints.maxWidth - (currentOrder.length * 120)) > 0
                                    ? (constraints.maxWidth - (currentOrder.length * 120)) / 2
                                    : 0,
                              ),
                              buildDefaultDragHandles: false,
                              onReorder: (oldIndex, newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) newIndex--;
                                  final item = currentOrder.removeAt(oldIndex);
                                  currentOrder.insert(newIndex, item);
                                });
                                _checkOrder();
                              },
                              children: [
                                for (final id in currentOrder)
                                  Padding(
                                    key: ValueKey(id),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: ReorderableDragStartListener(
                                      index: currentOrder.indexOf(id),
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                           children: [
                                            Text(
                                              itemsData[id]?['label'] as String? ?? '?',
                                              style: const TextStyle(fontSize: 50),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Volver", style: TextStyle(color: Colors.white, fontSize: 18)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: MediaQuery.of(context).size.height / 2 - 24,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  iconSize: 48,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
