import 'package:flutter/material.dart';
import '../data/models/routine_models.dart';
import '../data/repositories/routine_repository.dart';

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

  double get averageScore {
    if (_allLogs.isEmpty) return 0;
    final total = _allLogs.fold(0.0, (sum, log) => sum + log.followScore);
    return total / _allLogs.length;
  }

  int get perfectDays {
    return _allLogs.where((l) => l.followScore >= 95).length;
  }
}
