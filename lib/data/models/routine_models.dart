import 'package:cloud_firestore/cloud_firestore.dart';

enum HabitType { checkbox, counter, duration }

enum TaskStatus { completed, late, skipped, pending, partial }

class TaskTemplate {
  final String id;
  final String name;
  final String startTime; // Format "HH:mm"
  final int durationMinutes;
  final String category;
  final HabitType type;
  final String icon;
  final double targetValue;
  final String unit;
  final String priority;

  TaskTemplate({
    required this.id,
    required this.name,
    required this.startTime,
    required this.durationMinutes,
    this.category = 'General',
    this.type = HabitType.checkbox,
    this.icon = 'check_circle',
    this.targetValue = 1.0,
    this.unit = '',
    this.priority = 'Medium',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'category': category,
      'type': type.name,
      'icon': icon,
      'targetValue': targetValue,
      'unit': unit,
      'priority': priority,
    };
  }

  factory TaskTemplate.fromMap(Map<String, dynamic> map) {
    return TaskTemplate(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      startTime: map['startTime'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      category: map['category'] ?? 'General',
      type: HabitType.values.byName(map['type'] ?? 'checkbox'),
      icon: map['icon'] ?? 'check_circle',
      targetValue: (map['targetValue'] ?? 1.0).toDouble(),
      unit: map['unit'] ?? '',
      priority: map['priority'] ?? 'Medium',
    );
  }
}

class RoutineTemplate {
  final String id;
  final String userId;
  final String name;
  final List<String> daysOfWeek; // ['Monday', 'Tuesday'...]
  final List<TaskTemplate> tasks;
  final bool isActive;

  RoutineTemplate({
    required this.id,
    required this.userId,
    required this.name,
    required this.daysOfWeek,
    required this.tasks,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'daysOfWeek': daysOfWeek,
      'tasks': tasks.map((x) => x.toMap()).toList(),
      'isActive': isActive,
    };
  }

  factory RoutineTemplate.fromMap(Map<String, dynamic> map) {
    return RoutineTemplate(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      daysOfWeek: List<String>.from(map['daysOfWeek'] ?? []),
      tasks: List<TaskTemplate>.from(
        (map['tasks'] as List<dynamic>? ?? []).map((x) => TaskTemplate.fromMap(x)),
      ),
      isActive: map['isActive'] ?? true,
    );
  }
}

class LoggedTask {
  final String taskTemplateId;
  final String name;
  final TaskStatus status;
  final DateTime? completionTime;
  final String? skipReason;
  final String? startTime; // "HH:mm"
  final int? durationMinutes;
  final String category;
  final String priority; // "High", "Medium", "Low"
  final HabitType type;
  final double currentValue;
  final double targetValue;
  final String unit;
  final String icon;

  // New Quest-related fields
  final int xpReward; // XP given when completed
  final String questType; // 'main'/'side'/'boss'
  final String difficulty; // 'easy'/'normal'/'hard'/'very_hard'
  final bool isDungeonTask; // Whether this task is part of a dungeon session
  final int dungeonSessionId; // ID of the dungeon session if applicable

  LoggedTask({
    required this.taskTemplateId,
    required this.name,
    this.status = TaskStatus.pending,
    this.completionTime,
    this.skipReason,
    this.startTime,
    this.durationMinutes,
    this.category = 'General',
    this.priority = 'Medium',
    this.type = HabitType.checkbox,
    this.currentValue = 0.0,
    this.targetValue = 1.0,
    this.unit = '',
    this.icon = 'check_circle',
    // New Quest fields
    this.xpReward = 100,
    this.questType = 'side',
    this.difficulty = 'normal',
    this.isDungeonTask = false,
    this.dungeonSessionId = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskTemplateId': taskTemplateId,
      'name': name,
      'status': status.name,
      'completionTime': completionTime?.toIso8601String(),
      'skipReason': skipReason,
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'category': category,
      'priority': priority,
      'type': type.name,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'unit': unit,
      'icon': icon,
      // New Quest fields
      'xpReward': xpReward,
      'questType': questType,
      'difficulty': difficulty,
      'isDungeonTask': isDungeonTask,
      'dungeonSessionId': dungeonSessionId,
    };
  }

  factory LoggedTask.fromMap(Map<String, dynamic> map) {
    return LoggedTask(
      taskTemplateId: map['taskTemplateId'] ?? '',
      name: map['name'] ?? '',
      status: _safeStatus(map['status']),
      completionTime: map['completionTime'] != null 
          ? DateTime.parse(map['completionTime']) 
          : null,
      skipReason: map['skipReason'],
      startTime: map['startTime'],
      durationMinutes: map['durationMinutes'],
      category: map['category'] ?? 'General',
      priority: map['priority'] ?? 'Medium',
      type: HabitType.values.byName(map['type'] ?? 'checkbox'),
      currentValue: (map['currentValue'] ?? 0.0).toDouble(),
      targetValue: (map['targetValue'] ?? 1.0).toDouble(),
      unit: map['unit'] ?? '',
      icon: map['icon'] ?? 'check_circle',
      // New Quest fields
      xpReward: map['xpReward'] ?? 100,
      questType: map['questType'] ?? 'side',
      difficulty: map['difficulty'] ?? 'normal',
      isDungeonTask: map['isDungeonTask'] ?? false,
      dungeonSessionId: map['dungeonSessionId'] ?? 0,
    );
  }

  static TaskStatus _safeStatus(String? name) {
    try {
      return TaskStatus.values.byName(name ?? 'pending');
    } catch (_) {
      return TaskStatus.pending;
    }
  }
}

class DailyLog {
  final String id;
  final String userId;
  final DateTime date;
  final List<LoggedTask> tasks;
  final double followScore;
  final String? mood;
  final String? reflection;
  
  // New Quest-related fields
  final String dailyRank; // C/B/A/S based on performance
  final int xpGained;
  final Map<String, int> statImprovements; // { 'strength': 1, 'discipline': 2 }
  final bool enteredPenaltyZone;

  DailyLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.tasks,
    required this.followScore,
    this.mood,
    this.reflection,
    // New Quest fields
    this.dailyRank = 'C',
    this.xpGained = 0,
    this.statImprovements = const {},
    this.enteredPenaltyZone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'tasks': tasks.map((x) => x.toMap()).toList(),
      'followScore': followScore,
      'mood': mood,
      'reflection': reflection,
      // New Quest fields
      'dailyRank': dailyRank,
      'xpGained': xpGained,
      'statImprovements': statImprovements,
      'enteredPenaltyZone': enteredPenaltyZone,
    };
  }

  factory DailyLog.fromMap(Map<String, dynamic> map) {
    return DailyLog(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      tasks: List<LoggedTask>.from(
        (map['tasks'] as List<dynamic>? ?? []).map((x) => LoggedTask.fromMap(x)),
      ),
      followScore: (map['followScore'] ?? 0).toDouble(),
      mood: map['mood'],
      reflection: map['reflection'],
      // New Quest fields
      dailyRank: map['dailyRank'] ?? 'C',
      xpGained: map['xpGained'] ?? 0,
      statImprovements: Map<String, int>.from(map['statImprovements'] ?? {}),
      enteredPenaltyZone: map['enteredPenaltyZone'] ?? false,
    );
  }
}
