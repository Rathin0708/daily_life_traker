import '../../data/models/routine_models.dart';

class StreakCalculator {
  /// Calculates the current streak based on daily logs.
  /// Streak continues if followScore >= 90%.
  static int calculateCurrentStreak(List<DailyLog> logs) {
    if (logs.isEmpty) return 0;

    // Sort logs by date descending
    final sortedLogs = List<DailyLog>.from(logs)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime? lastDate;

    for (var log in sortedLogs) {
      if (log.followScore >= 90.0) {
        if (lastDate == null) {
          streak++;
          lastDate = log.date;
        } else {
          // Check if it's the previous day
          final difference = lastDate.difference(log.date).inDays;
          if (difference == 1) {
            streak++;
            lastDate = log.date;
          } else if (difference > 1) {
            // Gap in records, streak ends
            break;
          }
        }
      } else {
        // Score too low, streak ends
        break;
      }
    }
    return streak;
  }
}
