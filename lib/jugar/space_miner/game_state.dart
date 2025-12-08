import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Core game state for Space Miner
class GameState extends ChangeNotifier {
  // Resources
  double _minerals = 0.0;
  double _clickPower = 1.0;
  
  // Auto-miners
  final List<MinerType> _miners = [];
  
  // Upgrades
  int _clickUpgradeLevel = 0;
  int _productionMultiplierLevel = 0;
  
  // Statistics
  int _totalClicks = 0;
  double _totalMineralsEarned = 0.0;
  DateTime _gameStartTime = DateTime.now();
  
  // Auto-save timer
  Timer? _autoSaveTimer;
  
  // Getters
  double get minerals => _minerals;
  double get clickPower => _clickPower;
  List<MinerType> get miners => List.unmodifiable(_miners);
  int get clickUpgradeLevel => _clickUpgradeLevel;
  int get productionMultiplierLevel => _productionMultiplierLevel;
  int get totalClicks => _totalClicks;
  double get totalMineralsEarned => _totalMineralsEarned;
  DateTime get gameStartTime => _gameStartTime;
  
  /// Calculate total production per second from all miners
  double get productionPerSecond {
    double total = 0.0;
    for (var miner in _miners) {
      total += miner.productionRate * miner.count;
    }
    // Apply production multiplier
    double multiplier = 1.0 + (productionMultiplierLevel * 0.1);
    return total * multiplier;
  }
  
  GameState() {
    _startAutoSave();
    _startProductionTimer();
  }
  
  /// Start auto-save every 30 seconds
  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      saveGame();
    });
  }
  
  /// Start production timer (updates minerals every second)
  void _startProductionTimer() {
    Timer.periodic(const Duration(seconds: 1), (_) {
      if (productionPerSecond > 0) {
        _minerals += productionPerSecond;
        notifyListeners();
      }
    });
  }
  
  /// Handle click on asteroid
  void onAsteroidClick() {
    _minerals += _clickPower;
    _totalClicks++;
    _totalMineralsEarned += _clickPower;
    notifyListeners();
  }
  
  /// Purchase a miner
  bool purchaseMiner(MinerTypeEnum type) {
    final minerType = _getMinerType(type);
    final cost = minerType.currentCost;
    
    if (_minerals >= cost) {
      _minerals -= cost;
      minerType.count++;
      notifyListeners();
      return true;
    }
    return false;
  }
  
  /// Purchase click upgrade
  bool purchaseClickUpgrade() {
    final cost = _getClickUpgradeCost();
    if (_minerals >= cost) {
      _minerals -= cost;
      _clickUpgradeLevel++;
      _updateClickPower();
      notifyListeners();
      return true;
    }
    return false;
  }
  
  /// Purchase production multiplier upgrade
  bool purchaseProductionMultiplier() {
    final cost = _getProductionMultiplierCost();
    if (_minerals >= cost) {
      _minerals -= cost;
      _productionMultiplierLevel++;
      notifyListeners();
      return true;
    }
    return false;
  }
  
  /// Get cost for next click upgrade
  double _getClickUpgradeCost() {
    return 50 * (1.5 * (_clickUpgradeLevel + 1));
  }
  
  /// Get cost for next production multiplier
  double _getProductionMultiplierCost() {
    return 500 * (2.0 * (_productionMultiplierLevel + 1));
  }
  
  /// Update click power based on upgrades
  void _updateClickPower() {
    _clickPower = 1.0;
    if (_clickUpgradeLevel >= 1) _clickPower += 1;
    if (_clickUpgradeLevel >= 2) _clickPower += 4; // Total +5
    if (_clickUpgradeLevel >= 3) _clickPower += 5; // Total +10
    if (_clickUpgradeLevel >= 4) _clickPower += 40; // Total +50
  }
  
  /// Get miner type by enum
  MinerType _getMinerType(MinerTypeEnum type) {
    try {
      return _miners.firstWhere((m) => m.type == type);
    } catch (e) {
      // Create new miner type if doesn't exist
      final newMiner = MinerType(type);
      _miners.add(newMiner);
      return newMiner;
    }
  }
  
  /// Calculate offline earnings
  double _calculateOfflineEarnings(Duration timePassed) {
    // Cap at 4 hours
    final cappedDuration = timePassed.inSeconds > 14400 
        ? const Duration(hours: 4) 
        : timePassed;
    
    return productionPerSecond * cappedDuration.inSeconds;
  }
  
  /// Save game to local storage
  Future<void> saveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final saveData = {
        'minerals': _minerals,
        'clickPower': _clickPower,
        'clickUpgradeLevel': _clickUpgradeLevel,
        'productionMultiplierLevel': _productionMultiplierLevel,
        'totalClicks': _totalClicks,
        'totalMineralsEarned': _totalMineralsEarned,
        'gameStartTime': _gameStartTime.toIso8601String(),
        'lastSaveTime': DateTime.now().toIso8601String(),
        'miners': _miners.map((m) => {
          'type': m.type.index,
          'count': m.count,
        }).toList(),
      };
      
      await prefs.setString('space_miner_save', jsonEncode(saveData));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving game: $e');
      }
    }
  }
  
  /// Load game from local storage
  Future<void> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saveString = prefs.getString('space_miner_save');
      
      if (saveString == null) return;
      
      final saveData = jsonDecode(saveString) as Map<String, dynamic>;
      
      _minerals = (saveData['minerals'] as num).toDouble();
      _clickPower = (saveData['clickPower'] as num).toDouble();
      _clickUpgradeLevel = saveData['clickUpgradeLevel'] as int;
      _productionMultiplierLevel = saveData['productionMultiplierLevel'] as int;
      _totalClicks = saveData['totalClicks'] as int;
      _totalMineralsEarned = (saveData['totalMineralsEarned'] as num).toDouble();
      _gameStartTime = DateTime.parse(saveData['gameStartTime'] as String);
      
      final lastSave = DateTime.parse(saveData['lastSaveTime'] as String);
      final timePassed = DateTime.now().difference(lastSave);
      
      // Load miners
      _miners.clear();
      final minersData = saveData['miners'] as List<dynamic>;
      for (var minerData in minersData) {
        final type = MinerTypeEnum.values[minerData['type'] as int];
        final miner = MinerType(type);
        miner.count = minerData['count'] as int;
        _miners.add(miner);
      }
      
      // Calculate offline earnings
      if (timePassed.inSeconds > 60) {
        final offlineEarnings = _calculateOfflineEarnings(timePassed);
        _minerals += offlineEarnings;
        // We'll show a popup in the UI about offline earnings
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading game: $e');
      }
    }
  }
  
  /// Reset game (for testing or prestige in future)
  Future<void> resetGame() async {
    _minerals = 0.0;
    _clickPower = 1.0;
    _clickUpgradeLevel = 0;
    _productionMultiplierLevel = 0;
    _totalClicks = 0;
    _totalMineralsEarned = 0.0;
    _gameStartTime = DateTime.now();
    _miners.clear();
    
    await saveGame();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    saveGame(); // Save one last time
    super.dispose();
  }
}

/// Enum for miner types
enum MinerTypeEnum {
  drillBot,
  laserMiner,
  quantumExtractor,
  asteroidHarvester,
}

/// Miner type data
class MinerType {
  final MinerTypeEnum type;
  int count = 0;
  
  MinerType(this.type);
  
  /// Base production rate per second
  double get productionRate {
    switch (type) {
      case MinerTypeEnum.drillBot:
        return 0.1;
      case MinerTypeEnum.laserMiner:
        return 1.0;
      case MinerTypeEnum.quantumExtractor:
        return 10.0;
      case MinerTypeEnum.asteroidHarvester:
        return 100.0;
    }
  }
  
  /// Base cost
  double get baseCost {
    switch (type) {
      case MinerTypeEnum.drillBot:
        return 10.0;
      case MinerTypeEnum.laserMiner:
        return 100.0;
      case MinerTypeEnum.quantumExtractor:
        return 1000.0;
      case MinerTypeEnum.asteroidHarvester:
        return 10000.0;
    }
  }
  
  /// Current cost (exponential scaling)
  double get currentCost {
    return baseCost * (1.15 * count + 1);
  }
  
  /// Display name
  String get name {
    switch (type) {
      case MinerTypeEnum.drillBot:
        return 'Drill Bot';
      case MinerTypeEnum.laserMiner:
        return 'Laser Miner';
      case MinerTypeEnum.quantumExtractor:
        return 'Quantum Extractor';
      case MinerTypeEnum.asteroidHarvester:
        return 'Asteroid Harvester';
    }
  }
  
  /// Description
  String get description {
    switch (type) {
      case MinerTypeEnum.drillBot:
        return 'Basic mining robot';
      case MinerTypeEnum.laserMiner:
        return 'Advanced laser extraction';
      case MinerTypeEnum.quantumExtractor:
        return 'Quantum-powered mining';
      case MinerTypeEnum.asteroidHarvester:
        return 'Massive harvesting ship';
    }
  }
}
