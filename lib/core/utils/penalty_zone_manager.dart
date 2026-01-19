import 'package:flutter/material.dart';
import '../../data/models/routine_models.dart';
import '../../data/models/user_model.dart';
import 'hunter_stats_calculator.dart';
import '../widgets/system_notification_overlay.dart';

class PenaltyZoneManager {
  static bool isPenaltyActive(AppUser? user) {
    return user?.penaltyActivatedAt != null;
  }

  static bool shouldActivatePenalty(DailyLog? todayLog) {
    if (todayLog == null) return false;
    
    // Check if any main quests were missed
    final mainQuests = todayLog.tasks.where((task) => task.questType == 'main');
    final completedMainQuests = mainQuests.where((task) => 
        task.status == TaskStatus.completed || task.status == TaskStatus.late);
    
    // If there are main quests and none were completed, activate penalty
    if (mainQuests.isNotEmpty && completedMainQuests.isEmpty) {
      return true;
    }
    
    // Check if streak was broken
    if (todayLog.followScore < 90.0) {
      return true;
    }
    
    return false;
  }

  static Future<void> activatePenalty(BuildContext context, AppUser? user) async {
    if (user == null) return;
    
    // Show system notification
    showSystemNotification(
      context, 
      'Penalty Zone Activated. Complete 2 extra quests to escape.', 
      type: 'danger'
    );
  }

  static bool canExitPenalty(List<LoggedTask> tasks, int tasksRequired) {
    // Count completed extra tasks
    final completedExtraTasks = tasks.where((task) => 
        task.status == TaskStatus.completed && task.questType == 'side').length;
    
    return completedExtraTasks >= tasksRequired;
  }

  static Future<void> deactivatePenalty(BuildContext context) async {
    // Show system notification
    showSystemNotification(
      context, 
      'Penalty Zone Exited. Discipline restored.', 
      type: 'success'
    );
  }
}