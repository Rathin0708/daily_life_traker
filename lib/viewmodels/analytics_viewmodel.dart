import 'package:flutter/material.dart';
import '../data/models/routine_models.dart';
import '../data/repositories/routine_repository.dart';
import '../core/utils/hunter_stats_calculator.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final RoutineRepository _repository;
  final String _userId;

  List<DailyLog> _allLogs = [];
  bool _isLoading = false;

  AnalyticsViewModel(this._repository, this._userId) {
    _fetchData();
  }

  List<DailyLog> get allLogs => _allLogs;
  bool get isLoading => _isLoading;

  void _fetchData() {
    _isLoading = true;
    notifyListeners();

    // Get last 30 days of data for analytics
    final now = DateTime.now();
    _repository.getMonthlyLogs(_userId, now.year, now.month).listen((logs) {
      _allLogs = logs..sort((a, b) => a.date.compareTo(b.date));
      _isLoading = false;
      notifyListeners();
    });
  }

  // Added missing method
  Future<void> loadAnalyticsData() async {
    _fetchData();
  }

  double get averageScore {
    if (_allLogs.isEmpty) return 0;
    final total = _allLogs.fold(0.0, (sum, log) => sum + log.followScore);
    return total / _allLogs.length;
  }

  int get perfectDays {
    return _allLogs.where((l) => l.followScore >= 95).length;
  }

  // Added properties for anime analytics
  List<int>? get rankHistory {
    if (_allLogs.isEmpty) return [1]; // Default to rank 1 if no logs
    return _allLogs.map((log) => HunterStatsCalculator.calculateNumericDailyRank(log.followScore)).toList().cast<int>();
  }

  double? get averageDailyRank {
    final ranks = rankHistory;
    if (ranks == null || ranks.isEmpty) return 0.0;
    return ranks.reduce((a, b) => a + b) / ranks.length;
  }

  int? get bestDailyRank {
    final ranks = rankHistory;
    if (ranks == null || ranks.isEmpty) return 1;
    return ranks.reduce((a, b) => a > b ? a : b);
  }

  double? get avgStrength {
    // Calculate average strength gain over time
    return 10.0; // Placeholder - actual calculation would depend on user stats history
  }

  double? get avgIntelligence {
    return 10.0; // Placeholder
  }

  double? get avgAgility {
    return 10.0; // Placeholder
  }

  double? get avgDiscipline {
    return 10.0; // Placeholder
  }

  double? get avgWillpower {
    return 10.0; // Placeholder
  }

  List<double>? get weeklyPerformance {
    if (_allLogs.isEmpty) return [0, 0, 0, 0, 0, 0, 0]; // 7 days of zeros
    
    // Take last 7 days of data
    final last7Days = _allLogs.length > 7 ? _allLogs.sublist(_allLogs.length - 7) : _allLogs;
    final result = List<double>.filled(7, 0.0);
    
    for (int i = 0; i < last7Days.length && i < 7; i++) {
      result[6 - i] = last7Days[last7Days.length - 1 - i].followScore;
    }
    
    return result;
  }

  double? get mainQuestCompletionRate {
    final completedMain = _allLogs.fold(0, (sum, log) => 
      sum + log.tasks.where((task) => 
        task.questType == 'main' && 
        (task.status == TaskStatus.completed || task.status == TaskStatus.late)).length
    );
    
    final totalMain = _allLogs.fold(0, (sum, log) => 
      sum + log.tasks.where((task) => task.questType == 'main').length
    );
    
    return totalMain > 0 ? (completedMain / totalMain) * 100 : 0.0;
  }

  double? get sideQuestCompletionRate {
    final completedSide = _allLogs.fold(0, (sum, log) => 
      sum + log.tasks.where((task) => 
        task.questType == 'side' && 
        (task.status == TaskStatus.completed || task.status == TaskStatus.late)).length
    );
    
    final totalSide = _allLogs.fold(0, (sum, log) => 
      sum + log.tasks.where((task) => task.questType == 'side').length
    );
    
    return totalSide > 0 ? (completedSide / totalSide) * 100 : 0.0;
  }

  double? get bossQuestCompletionRate {
    final completedBoss = _allLogs.fold(0, (sum, log) => 
      sum + log.tasks.where((task) => 
        task.questType == 'boss' && 
        (task.status == TaskStatus.completed || task.status == TaskStatus.late)).length
    );
    
    final totalBoss = _allLogs.fold(0, (sum, log) => 
      sum + log.tasks.where((task) => task.questType == 'boss').length
    );
    
    return totalBoss > 0 ? (completedBoss / totalBoss) * 100 : 0.0;
  }

  int get currentStreak {
    // Placeholder - should be calculated from user data
    return 5; 
  }

  int get bestStreak {
    // Placeholder - should be calculated from user data
    return 10;
  }

  double get averageStreak {
    // Placeholder - should be calculated from user data
    return 7.5;
  }
}