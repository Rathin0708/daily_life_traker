import 'package:flutter/material.dart';
import '../data/models/routine_models.dart';
import '../data/repositories/routine_repository.dart';
import '../core/utils/routine_calculator.dart';
import '../core/utils/streak_calculator.dart';
import '../core/utils/hunter_stats_calculator.dart';
import '../core/utils/quest_mapper.dart';
import '../core/utils/penalty_zone_manager.dart';
import 'package:uuid/uuid.dart';

class RoutineViewModel extends ChangeNotifier {
  final RoutineRepository _repository;
  final String _userId;

  DailyLog? _todayLog;
  List<DailyLog> _lastWeekLogs = [];
  List<RoutineTemplate> _templates = [];
  bool _isLoading = false;

  RoutineViewModel(this._repository, this._userId) {
    _loadData();
  }

  DailyLog? get todayLog => _todayLog;
  List<DailyLog> get lastWeekLogs => _lastWeekLogs;
  List<RoutineTemplate> get templates => _templates;
  bool get isLoading => _isLoading;

  Future<void> _loadData() async {
    _setLoading(true);
    _todayLog = await _repository.getDailyLog(_userId, DateTime.now());
    _lastWeekLogs = await _repository.getAllLogs(_userId);
    
    // If no log exists for today, we might want to generate one from templates
    if (_todayLog == null) {
      await _generateTodayLog();
    }
    
    _setLoading(false);
  }

  Future<void> _generateTodayLog() async {
    final templatesSnapshot = await _repository.getUserTemplates(_userId).first;
    _templates = templatesSnapshot;

    if (_templates.isNotEmpty) {
      final now = DateTime.now();
      final dayName = _getDayName(now.weekday);
      
      final activeTemplate = _templates.cast<RoutineTemplate?>().firstWhere(
        (t) => t!.isActive && t.daysOfWeek.contains(dayName),
        orElse: () => null,
      );

      if (activeTemplate == null) return;

      var loggedTasks = activeTemplate.tasks.map((t) => LoggedTask(
        taskTemplateId: t.id,
        name: t.name,
        startTime: t.startTime,
        durationMinutes: t.durationMinutes,
        category: t.category,
        priority: t.priority,
        type: t.type,
        icon: t.icon,
        targetValue: t.targetValue,
        unit: t.unit,
        currentValue: 0.0,
      )).toList();
      
      // Assign quest types to the tasks
      loggedTasks = QuestMapper.assignQuestTypes(loggedTasks);

      _todayLog = DailyLog(
        id: const Uuid().v4(),
        userId: _userId,
        date: now,
        tasks: loggedTasks,
        followScore: 0.0,
        // Set initial daily rank
        dailyRank: 'D',
      );

      await _repository.saveDailyLog(_todayLog!);
      _syncLastWeekLogs();
      notifyListeners();
    }
  }

  Future<int> updateTaskStatus(int index, TaskStatus status, {String? skipReason}) async {
    if (_todayLog == null) return 0;

    final updatedTasks = List<LoggedTask>.from(_todayLog!.tasks);
    final oldTask = updatedTasks[index];
    
    updatedTasks[index] = LoggedTask(
      taskTemplateId: oldTask.taskTemplateId,
      name: oldTask.name,
      status: status,
      completionTime: status == TaskStatus.completed || status == TaskStatus.late 
          ? DateTime.now() 
          : null,
      skipReason: skipReason,
      startTime: oldTask.startTime,
      durationMinutes: oldTask.durationMinutes,
      category: oldTask.category,
      priority: oldTask.priority,
      type: oldTask.type,
      currentValue: status == TaskStatus.completed || status == TaskStatus.late ? oldTask.targetValue : (status == TaskStatus.pending ? 0.0 : oldTask.currentValue),
      targetValue: oldTask.targetValue,
      unit: oldTask.unit,
      icon: oldTask.icon,
      // Preserve quest properties
      xpReward: oldTask.xpReward,
      questType: oldTask.questType,
      difficulty: oldTask.difficulty,
      isDungeonTask: oldTask.isDungeonTask,
      dungeonSessionId: oldTask.dungeonSessionId,
    );

    final newScore = RoutineCalculator.calculateFollowScore(updatedTasks);

    _todayLog = DailyLog(
      id: _todayLog!.id,
      userId: _todayLog!.userId,
      date: _todayLog!.date,
      tasks: updatedTasks,
      followScore: newScore,
      mood: _todayLog!.mood,
      reflection: _todayLog!.reflection,
      // Update daily rank based on new score
      dailyRank: HunterStatsCalculator.calculateDailyRank(newScore),
    );

    await _repository.saveDailyLog(_todayLog!);
    _syncLastWeekLogs();
    notifyListeners();

    // Return XP reward for this task
    if (status == TaskStatus.completed || status == TaskStatus.late) {
      return oldTask.xpReward;
    }
    return 0;
  }

  Future<int> updateHabitValue(int index, double value) async {
    if (_todayLog == null) return 0;

    final updatedTasks = List<LoggedTask>.from(_todayLog!.tasks);
    final task = updatedTasks[index];
    
    // Calculate new status
    TaskStatus newStatus;
    if (value >= task.targetValue) {
      newStatus = TaskStatus.completed;
    } else if (value > 0) {
      newStatus = TaskStatus.partial;
    } else {
      newStatus = TaskStatus.pending;
    }

    updatedTasks[index] = LoggedTask(
      taskTemplateId: task.taskTemplateId,
      name: task.name,
      status: newStatus,
      currentValue: value,
      targetValue: task.targetValue,
      unit: task.unit,
      type: task.type,
      icon: task.icon,
      startTime: task.startTime,
      durationMinutes: task.durationMinutes,
      category: task.category,
      priority: task.priority,
      completionTime: newStatus == TaskStatus.completed ? DateTime.now() : null,
    );

    final newScore = RoutineCalculator.calculateFollowScore(updatedTasks);

    _todayLog = DailyLog(
      id: _todayLog!.id,
      userId: _todayLog!.userId,
      date: _todayLog!.date,
      tasks: updatedTasks,
      followScore: newScore,
      mood: _todayLog!.mood,
      reflection: _todayLog!.reflection,
    );

    await _repository.saveDailyLog(_todayLog!);
    _syncLastWeekLogs();
    notifyListeners();

    if (newStatus == TaskStatus.completed && task.status != TaskStatus.completed) return 100;
    return 0;
  }

  Future<void> addTaskToToday(String name) async {
    _todayLog ??= DailyLog(
      id: const Uuid().v4(),
      userId: _userId,
      date: DateTime.now(),
      tasks: [],
      followScore: 0.0,
    );

    final updatedTasks = List<LoggedTask>.from(_todayLog!.tasks);
    var newTask = LoggedTask(
      taskTemplateId: 'custom_${const Uuid().v4()}',
      name: name,
    );
    
    // Assign quest properties to the new task
    var questMappedTasks = QuestMapper.assignQuestTypes([newTask]);
    updatedTasks.add(questMappedTasks[0]);

    final newScore = RoutineCalculator.calculateFollowScore(updatedTasks);

    _todayLog = DailyLog(
      id: _todayLog!.id,
      userId: _todayLog!.userId,
      date: _todayLog!.date,
      tasks: updatedTasks,
      followScore: newScore,
      mood: _todayLog!.mood,
      reflection: _todayLog!.reflection,
      dailyRank: HunterStatsCalculator.calculateDailyRank(newScore),
    );

    await _repository.saveDailyLog(_todayLog!);
    notifyListeners();
  }

  Future<void> deleteTaskFromToday(int index) async {
    if (_todayLog == null) return;

    final updatedTasks = List<LoggedTask>.from(_todayLog!.tasks);
    updatedTasks.removeAt(index);

    final newScore = RoutineCalculator.calculateFollowScore(updatedTasks);

    _todayLog = DailyLog(
      id: _todayLog!.id,
      userId: _todayLog!.userId,
      date: _todayLog!.date,
      tasks: updatedTasks,
      followScore: newScore,
      mood: _todayLog!.mood,
      reflection: _todayLog!.reflection,
    );

    await _repository.saveDailyLog(_todayLog!);
    notifyListeners();
  }

  Future<void> saveReflection({required String mood, required String reflection}) async {
    if (_todayLog == null) return;

    _todayLog = DailyLog(
      id: _todayLog!.id,
      userId: _todayLog!.userId,
      date: _todayLog!.date,
      tasks: _todayLog!.tasks,
      followScore: _todayLog!.followScore,
      mood: mood,
      reflection: reflection,
    );

    await _repository.saveDailyLog(_todayLog!);
    notifyListeners();
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  Map<String, double> getPriorityCompletionStats() {
    if (_todayLog == null || _todayLog!.tasks.isEmpty) return {};
    
    final highPriorityTasks = _todayLog!.tasks.where((t) => t.priority.toLowerCase() == 'high').toList();
    if (highPriorityTasks.isEmpty) return {};
    
    final completedHigh = highPriorityTasks.where((t) => t.status == TaskStatus.completed || t.status == TaskStatus.late).length;
    return {
      'high_completion': completedHigh / highPriorityTasks.length,
    };
  }

  Future<int> recalculateStreak() async {
    final allLogs = await _repository.getAllLogs(_userId);
    return StreakCalculator.calculateCurrentStreak(allLogs);
  }

  void _syncLastWeekLogs() {
    if (_todayLog == null) return;
    final index = _lastWeekLogs.indexWhere((l) => l.id == _todayLog!.id);
    if (index != -1) {
      _lastWeekLogs[index] = _todayLog!;
    } else {
      _lastWeekLogs.add(_todayLog!);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
