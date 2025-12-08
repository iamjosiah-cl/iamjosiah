import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portafolio/jugar/space_miner/game_state.dart';

/// Statistics screen showing game progress
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'Statistics',
          style: TextStyle(
            color: Color(0xFF9d4edd),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF9d4edd)),
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          final timePlayed = DateTime.now().difference(gameState.gameStartTime);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatCard(
                  icon: Icons.diamond,
                  title: 'Total Minerals Mined',
                  value: _formatNumber(gameState.totalMineralsEarned),
                  color: const Color(0xFF00ffff),
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  icon: Icons.touch_app,
                  title: 'Total Clicks',
                  value: gameState.totalClicks.toString(),
                  color: const Color(0xFF9d4edd),
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  icon: Icons.speed,
                  title: 'Production Rate',
                  value: '${_formatNumber(gameState.productionPerSecond)}/s',
                  color: const Color(0xFFc77dff),
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  icon: Icons.timer,
                  title: 'Time Played',
                  value: _formatDuration(timePlayed),
                  color: const Color(0xFF7209b7),
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  icon: Icons.trending_up,
                  title: 'Click Power',
                  value: _formatNumber(gameState.clickPower),
                  color: const Color(0xFF00ffff),
                ),
                
                const SizedBox(height: 24),
                
                // Miners owned
                if (gameState.miners.isNotEmpty) ...[
                  const Text(
                    'Miners Owned',
                    style: TextStyle(
                      color: Color(0xFF9d4edd),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...gameState.miners.where((m) => m.count > 0).map((miner) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildMinerStat(miner),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinerStat(MinerType miner) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00ffff).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            miner.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            'x${miner.count}',
            style: const TextStyle(
              color: Color(0xFF00ffff),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    } else {
      return number.toStringAsFixed(1);
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
