import 'package:flutter/material.dart';
import '../data/models/routine_models.dart';
import '../data/repositories/routine_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  final RoutineRepository _repository;
  final String _userId;

  DateTime _focusedDay = DateTime.now();
  List<DailyLog> _monthlyLogs = [];
  bool _isLoading = false;

  CalendarViewModel(this._repository, this._userId) {
    _fetchLogs();
  }

  DateTime get focusedDay => _focusedDay;
  List<DailyLog> get monthlyLogs => _monthlyLogs;
  bool get isLoading => _isLoading;

  void setFocusedDay(DateTime day) {
    if (day.month != _focusedDay.month || day.year != _focusedDay.year) {
      _focusedDay = day;
      _fetchLogs();
    } else {
      _focusedDay = day;
      notifyListeners();
    }
  }

  void _fetchLogs() {
    _isLoading = true;
    notifyListeners();

    _repository.getMonthlyLogs(_userId, _focusedDay.year, _focusedDay.month).listen((logs) {
      _monthlyLogs = logs;
      _isLoading = false;
      notifyListeners();
    });
  }
}
