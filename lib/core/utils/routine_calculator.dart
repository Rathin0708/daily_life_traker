import '../../data/models/routine_models.dart';

class RoutineCalculator {
  /// Calculates the follow score based on task statuses.
  /// Completed = 1.0
  /// Late = 0.5
  /// Skipped = 0.0
  /// Pending = 0.0 (treated as not done yet)
  static double calculateFollowScore(List<LoggedTask> tasks) {
    if (tasks.isEmpty) return 0.0;

    double totalWeight = 0;
    for (var task in tasks) {
      switch (task.status) {
        case TaskStatus.completed:
          totalWeight += 1.0;
          break;
        case TaskStatus.late:
          totalWeight += 0.5;
          break;
        case TaskStatus.partial:
          if (task.targetValue > 0) {
            totalWeight += (task.currentValue / task.targetValue).clamp(0.0, 1.0);
          }
          break;
        case TaskStatus.skipped:
        case TaskStatus.pending:
          totalWeight += 0.0;
          break;
      }
    }

    return (totalWeight / tasks.length) * 100;
  }

  /// Determines if a streak should continue based on the follow score.
  /// Threshold is 90% as per requirements.
  static bool isStreakMaintained(double followScore) {
    return followScore >= 90.0;
  }
}
