import 'package:flutter/material.dart';

// Helper widget for horizontal layout if needed, simplified for now
class HorizontalLayoutWrapper extends StatelessWidget {
  final Widget child;
  const HorizontalLayoutWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) => child;
}

class LeftWallScreen extends StatefulWidget {
  const LeftWallScreen({super.key});

  @override
  State<LeftWallScreen> createState() => _LeftWallScreenState();
}

class _LeftWallScreenState extends State<LeftWallScreen> {
  bool showPapel = false;
  bool _isLoading = true;
  double _opacity = 0.0;

  void _togglePapel(bool show) {
    setState(() {
      showPapel = show;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadAssets();
  }

  Future<void> _preloadAssets() async {
    // Placeholder assets handling: if real assets don't exist, this might fail or show nothing.
    // For now we assume assets are present or user will add them.
    // Commenting out precache to avoid crash if assets are missing, 
    // or we can wrap in try-catch.
    try {
      // Precache removed as images are no longer used
    } catch (e) {
      debugPrint("Error precaching images: $e");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _opacity = 1.0;
          });
        }
      });
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
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          child: Stack(
            children: [
              // Fondo muralla
              Positioned.fill(
                child: Container(color: Colors.grey[850]), // Wall color
              ),

              // Flecha para volver (derecha)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    iconSize: 48,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),

              // Bolita de papel
              if (!showPapel)
                Positioned(
                  bottom: 50,
                  left: MediaQuery.of(context).size.width / 2 - 25,
                  child: GestureDetector(
                    onTap: () => _togglePapel(true),
                    child: const Icon(Icons.description, color: Colors.white70, size: 50),
                  ),
                ),

              // Papel desplegado
              if (showPapel)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _togglePapel(false),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 300,
                          height: 400,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5E6CA), // Vintage paper color
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                          ),
                          child: Center(
                            child: Column(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                  Text(
                                    "¿Código de acceso?",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Text(
                                    "Ordena del más pequeño al más grande",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  SizedBox(height: 40),
                                  TextButton(
                                    onPressed: () => _togglePapel(false),
                                    child: const Text(
                                      "Volver",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  ),
                               ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
