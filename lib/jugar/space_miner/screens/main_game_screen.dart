import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portafolio/jugar/space_miner/game_state.dart';
import 'package:portafolio/jugar/space_miner/widgets/space_background.dart';
import 'package:portafolio/jugar/space_miner/widgets/asteroid_widget.dart';
import 'package:portafolio/jugar/space_miner/screens/upgrade_shop.dart';
import 'package:portafolio/jugar/space_miner/screens/statistics_screen.dart';

/// Main gameplay screen
class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  String? _floatingText;
  Offset? _floatingTextPosition;

  @override
  void initState() {
    super.initState();
    // Load game on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameState>().loadGame();
    });
  }

  void _showFloatingText(String text, Offset position) {
    setState(() {
      _floatingText = text;
      _floatingTextPosition = position;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _floatingText = null;
          _floatingTextPosition = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Space background
          const Positioned.fill(
            child: SpaceBackground(),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Center(
                    child: _buildAsteroidArea(),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),

          // Floating text for click feedback
          if (_floatingText != null && _floatingTextPosition != null)
            _buildFloatingText(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Minerals counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a2e).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF00ffff).withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00ffff).withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.diamond,
                      color: Color(0xFF00ffff),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatNumber(gameState.minerals),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Production rate
              if (gameState.productionPerSecond > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9d4edd).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF9d4edd).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    '${_formatNumber(gameState.productionPerSecond)}/s',
                    style: const TextStyle(
                      color: Color(0xFFc77dff),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAsteroidArea() {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return GestureDetector(
          onTapDown: (details) {
            gameState.onAsteroidClick();
            _showFloatingText(
              '+${_formatNumber(gameState.clickPower)}',
              details.globalPosition,
            );
          },
          child: AsteroidWidget(
            onTap: () {
              // Handled by GestureDetector above
            },
            size: 250,
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomButton(
            icon: Icons.shopping_cart,
            label: 'Shop',
            color: const Color(0xFF00ffff),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: context.read<GameState>(),
                    child: const UpgradeShop(),
                  ),
                ),
              );
            },
          ),
          _buildBottomButton(
            icon: Icons.bar_chart,
            label: 'Stats',
            color: const Color(0xFF9d4edd),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: context.read<GameState>(),
                    child: const StatisticsScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingText() {
    return Positioned(
      left: _floatingTextPosition!.dx - 30,
      top: _floatingTextPosition!.dy - 50,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, -value * 50),
            child: Opacity(
              opacity: 1.0 - value,
              child: Text(
                _floatingText!,
                style: TextStyle(
                  color: const Color(0xFF00ffff),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF00ffff).withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }
}
