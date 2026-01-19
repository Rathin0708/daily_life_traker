import '../../data/models/routine_models.dart';

class QuestMapper {
  /// Maps existing tasks to quest types based on priority and nature
  static List<LoggedTask> assignQuestTypes(List<LoggedTask> tasks) {
    return tasks.map((task) {
      String questType = _determineQuestType(task);
      String difficulty = _determineDifficulty(task);
      int xpReward = _calculateXpReward(task, questType, difficulty);
      
      return LoggedTask(
        taskTemplateId: task.taskTemplateId,
        name: task.name,
        status: task.status,
        completionTime: task.completionTime,
        skipReason: task.skipReason,
        startTime: task.startTime,
        durationMinutes: task.durationMinutes,
        category: task.category,
        priority: task.priority,
        type: task.type,
        currentValue: task.currentValue,
        targetValue: task.targetValue,
        unit: task.unit,
        icon: task.icon,
        // New quest properties
        xpReward: xpReward,
        questType: questType,
        difficulty: difficulty,
        isDungeonTask: task.isDungeonTask,
        dungeonSessionId: task.dungeonSessionId,
      );
    }).toList();
  }

  /// Determines quest type based on priority and nature
  static String _determineQuestType(LoggedTask task) {
    // High priority tasks are usually main quests
    if (task.priority.toLowerCase() == 'high') {
      // If it's a recurring important task, it's likely a main quest
      return 'main';
    }
    
    // Tasks marked as mandatory could be main quests
    final mandatoryKeywords = [
      'must', 'mandatory', 'essential', 'critical', 'important', 
      'vital', 'crucial', 'required'
    ];
    final lowerName = task.name.toLowerCase();
    
    if (mandatoryKeywords.any((keyword) => lowerName.contains(keyword))) {
      return 'main';
    }
    
    // High priority tasks that aren't mandatory are boss quests
    if (task.priority.toLowerCase() == 'high') {
      return 'boss';
    }
    
    // Default to side quest
    return 'side';
  }

  /// Determines difficulty based on various factors
  static String _determineDifficulty(LoggedTask task) {
    // Based on priority
    switch (task.priority.toLowerCase()) {
      case 'high': return 'hard';
      case 'medium': return 'normal';
      case 'low': return 'easy';
    }
    
    // Based on duration/time commitment
    if (task.durationMinutes != null) {
      if (task.durationMinutes! > 120) return 'very_hard'; // More than 2 hours
      if (task.durationMinutes! > 60) return 'hard'; // 1-2 hours
      if (task.durationMinutes! > 30) return 'normal'; // 30 min - 1 hour
    }
    
    return 'normal';
  }

  /// Calculates XP reward based on quest type and difficulty
  static int _calculateXpReward(LoggedTask task, String questType, String difficulty) {
    int baseXp = 100;
    
    // Adjust based on quest type
    switch (questType) {
      case 'main': baseXp = (baseXp * 1.5).round(); break;
      case 'boss': baseXp = (baseXp * 2.0).round(); break;
      case 'side': baseXp = (baseXp * 1.0).round(); break;
    }
    
    // Adjust based on difficulty
    switch (difficulty) {
      case 'easy': baseXp = (baseXp * 0.8).round(); break;
      case 'normal': baseXp = (baseXp * 1.0).round(); break;
      case 'hard': baseXp = (baseXp * 1.2).round(); break;
      case 'very_hard': baseXp = (baseXp * 1.5).round(); break;
    }
    
    return baseXp.round();
  }
}