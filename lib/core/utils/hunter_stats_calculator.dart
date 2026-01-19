import '../../data/models/routine_models.dart';
import 'package:flutter/material.dart';

class HunterStatsCalculator {
  /// Calculates stat increases based on task completion
  static Map<String, int> calculateStatIncreases(List<LoggedTask> tasks) {
    int strength = 0;
    int intelligence = 0;
    int agility = 0;
    int discipline = 0;
    int willpower = 0;

    for (final task in tasks) {
      if (task.status == TaskStatus.completed || task.status == TaskStatus.late) {
        // Strength increases with physical tasks
        if (_isPhysicalTask(task)) {
          strength += _calculateStatIncrease(task);
        }
        
        // Intelligence increases with learning tasks
        if (_isLearningTask(task)) {
          intelligence += _calculateStatIncrease(task);
        }
        
        // Agility increases with morning routines
        if (_isMorningTask(task)) {
          agility += _calculateStatIncrease(task);
        }
        
        // Discipline increases with streak consistency
        if (_isDisciplineTask(task)) {
          discipline += _calculateStatIncrease(task);
        }
        
        // Willpower increases with boss quest completion
        if (_isBossQuest(task)) {
          willpower += _calculateStatIncrease(task) * 2; // Bonus for boss quests
        }
      }
    }

    return {
      'strength': strength,
      'intelligence': intelligence,
      'agility': agility,
      'discipline': discipline,
      'willpower': willpower,
    };
  }

  /// Determines if a task is physical (exercise, workout, etc.)
  static bool _isPhysicalTask(LoggedTask task) {
    final physicalKeywords = [
      'exercise', 'workout', 'gym', 'run', 'walk', 'stretch', 'yoga', 
      'sports', 'swim', 'lift', 'cardio', 'fitness', 'training'
    ];
    final lowerName = task.name.toLowerCase();
    return physicalKeywords.any((keyword) => lowerName.contains(keyword));
  }

  /// Determines if a task is learning-related (study, read, etc.)
  static bool _isLearningTask(LoggedTask task) {
    final learningKeywords = [
      'study', 'read', 'learn', 'course', 'book', 'research', 
      'practice', 'skill', 'education', 'knowledge', 'improve'
    ];
    final lowerName = task.name.toLowerCase();
    return learningKeywords.any((keyword) => lowerName.contains(keyword));
  }

  /// Determines if a task is a morning routine
  static bool _isMorningTask(LoggedTask task) {
    if (task.startTime != null) {
      final parts = task.startTime!.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        // Morning is considered before 10 AM
        return hour >= 5 && hour < 10;
      }
    }
    return false;
  }

  /// Determines if a task contributes to discipline
  static bool _isDisciplineTask(LoggedTask task) {
    // All completed tasks contribute to discipline, but high priority more so
    return task.priority.toLowerCase() == 'high';
  }

  /// Determines if a task is a boss quest
  static bool _isBossQuest(LoggedTask task) {
    return task.questType == 'boss';
  }

  /// Calculates stat increase based on task difficulty and completion
  static int _calculateStatIncrease(LoggedTask task) {
    switch (task.difficulty.toLowerCase()) {
      case 'easy':
        return 1;
      case 'normal':
        return 2;
      case 'hard':
        return 3;
      case 'very_hard':
        return 5;
      default:
        return 2;
    }
  }

  /// Calculates Hunter rank based on level
  static int calculateHunterRank(int level) {
    if (level < 10) return 1; // E
    if (level < 25) return 2; // D
    if (level < 50) return 3; // C
    if (level < 100) return 4; // B
    if (level < 200) return 5; // A
    if (level < 500) return 6; // S
    return 7; // Monarch
  }

  /// Converts rank number to rank string
  static String rankToString(int rankNum) {
    switch (rankNum) {
      case 1: return 'E';
      case 2: return 'D';
      case 3: return 'C';
      case 4: return 'B';
      case 5: return 'A';
      case 6: return 'S';
      case 7: return 'Monarch';
      default: return 'E';
    }
  }

  /// Calculates daily rank based on follow score
  static String calculateDailyRank(double followScore) {
    if (followScore >= 95) return 'S';
    if (followScore >= 85) return 'A';
    if (followScore >= 70) return 'B';
    if (followScore >= 50) return 'C';
    return 'D';
  }
}