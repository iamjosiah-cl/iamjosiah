import 'package:flutter/material.dart';
import '../../jugar/interactive.dart';
import 'puzzle3.dart';

class BackWallScreen extends StatefulWidget {
  const BackWallScreen({super.key});

  @override
  State<BackWallScreen> createState() => _BackWallScreenState();
}

class _BackWallScreenState extends State<BackWallScreen> {
  bool _isLoading = true;
  double _opacity = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      setState(() => _isLoading = false);
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) setState(() => _opacity = 1.0);
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
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          child: Stack(
            children: [
              // Fondo - wood-like gradient instead of image
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.brown[800]!,
                        Colors.brown[700]!,
                        Colors.brown[900]!,
                      ],
                    ),
                  ),
                ),
              ),

              // Help icon at top
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
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
              ),

              // 3x3 Emoji Grid Pattern Display
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildEmojiCell('🥝'),
                          _buildEmojiCell('🍎'),
                          _buildEmojiCell('🧊'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildEmojiCell('🍋'),
                          _buildEmojiCell('📘'),
                          _buildEmojiCell('🚗'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildEmojiCell('🧩'),
                          _buildEmojiCell('🌻'),
                          _buildEmojiCell('🪴'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation arrows at bottom
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        iconSize: 48,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Puzzle3()),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        iconSize: 48,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Puzzle3()),
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
      ),
    );
  }

  Widget _buildEmojiCell(String emoji) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
