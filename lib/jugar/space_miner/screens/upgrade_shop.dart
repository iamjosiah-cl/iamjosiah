import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portafolio/jugar/space_miner/game_state.dart';

/// Upgrade shop screen
class UpgradeShop extends StatelessWidget {
  const UpgradeShop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'Upgrade Shop',
          style: TextStyle(
            color: Color(0xFF00ffff),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF00ffff)),
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Auto-Miners'),
                const SizedBox(height: 12),
                ...MinerTypeEnum.values.map((type) => 
                  _buildMinerCard(context, gameState, type)
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle('Upgrades'),
                const SizedBox(height: 12),
                _buildClickUpgradeCard(context, gameState),
                const SizedBox(height: 12),
                _buildProductionMultiplierCard(context, gameState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF9d4edd),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMinerCard(
    BuildContext context,
    GameState gameState,
    MinerTypeEnum type,
  ) {
    final minerType = gameState.miners
        .where((m) => m.type == type)
        .firstOrNull ?? MinerType(type);
    
    final canAfford = gameState.minerals >= minerType.currentCost;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1a1a2e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: canAfford 
              ? const Color(0xFF00ffff).withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: canAfford
            ? () {
                if (gameState.purchaseMiner(type)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Purchased ${minerType.name}!'),
                      backgroundColor: const Color(0xFF00ffff),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF00ffff).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getMinerIcon(type),
                  color: const Color(0xFF00ffff),
                  size: 32,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      minerType.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      minerType.description,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatNumber(minerType.productionRate)}/s',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                        if (minerType.count > 0) ...[
                          const SizedBox(width: 16),
                          Text(
                            'Owned: ${minerType.count}',
                            style: const TextStyle(
                              color: Color(0xFF9d4edd),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Cost
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.diamond,
                    color: canAfford ? const Color(0xFF00ffff) : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatNumber(minerType.currentCost),
                    style: TextStyle(
                      color: canAfford ? const Color(0xFF00ffff) : Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClickUpgradeCard(BuildContext context, GameState gameState) {
    final cost = 50 * (1.5 * (gameState.clickUpgradeLevel + 1));
    final canAfford = gameState.minerals >= cost;
    
    return Card(
      color: const Color(0xFF1a1a2e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: canAfford 
              ? const Color(0xFF9d4edd).withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: canAfford
            ? () {
                if (gameState.purchaseClickUpgrade()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Click power upgraded!'),
                      backgroundColor: Color(0xFF9d4edd),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF9d4edd).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.touch_app,
                  color: Color(0xFF9d4edd),
                  size: 32,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Better Drill',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Increase click power',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Level: ${gameState.clickUpgradeLevel}',
                      style: const TextStyle(
                        color: Color(0xFF9d4edd),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.diamond,
                    color: canAfford ? const Color(0xFF9d4edd) : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatNumber(cost),
                    style: TextStyle(
                      color: canAfford ? const Color(0xFF9d4edd) : Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductionMultiplierCard(BuildContext context, GameState gameState) {
    final cost = 500 * (2.0 * (gameState.productionMultiplierLevel + 1));
    final canAfford = gameState.minerals >= cost;
    
    return Card(
      color: const Color(0xFF1a1a2e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: canAfford 
              ? const Color(0xFF9d4edd).withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: canAfford
            ? () {
                if (gameState.purchaseProductionMultiplier()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Production multiplier upgraded!'),
                      backgroundColor: Color(0xFF9d4edd),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF9d4edd).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF9d4edd),
                  size: 32,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Production Boost',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+10% production per level',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Level: ${gameState.productionMultiplierLevel}',
                      style: const TextStyle(
                        color: Color(0xFF9d4edd),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.diamond,
                    color: canAfford ? const Color(0xFF9d4edd) : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatNumber(cost),
                    style: TextStyle(
                      color: canAfford ? const Color(0xFF9d4edd) : Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMinerIcon(MinerTypeEnum type) {
    switch (type) {
      case MinerTypeEnum.drillBot:
        return Icons.precision_manufacturing;
      case MinerTypeEnum.laserMiner:
        return Icons.flash_on;
      case MinerTypeEnum.quantumExtractor:
        return Icons.science;
      case MinerTypeEnum.asteroidHarvester:
        return Icons.rocket_launch;
    }
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
