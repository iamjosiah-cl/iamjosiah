import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portafolio/jugar/space_miner/game_state.dart';
import 'package:portafolio/jugar/space_miner/screens/main_game_screen.dart';

/// Main entry point for Space Miner game
class SpaceMinerGame extends StatelessWidget {
  const SpaceMinerGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const MainGameScreen(),
    );
  }
}
