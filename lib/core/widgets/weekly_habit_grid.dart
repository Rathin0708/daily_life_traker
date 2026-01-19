import 'package:flutter/material.dart';
import '../../data/models/routine_models.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class WeeklyHabitGrid extends StatelessWidget {
  final List<LoggedTask> habits; // Unique habits to display
  final List<DailyLog> logs;
  final DateTime focusedDate;

  const WeeklyHabitGrid({
    super.key,
    required this.habits,
    required this.logs,
    required this.focusedDate,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the start of the week (Monday)
    final startOfWeek = focusedDate.subtract(Duration(days: focusedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).add(Duration(days: i)));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(weekDays),
          const SizedBox(height: 16),
          ...habits.map((habit) => _buildHabitRow(habit, weekDays)),
        ],
      ),
    );
  }

  Widget _buildHeader(List<DateTime> weekDays) {
    return Row(
      children: [
        const Expanded(flex: 3, child: SizedBox()),
        ...weekDays.map((date) => Expanded(
          child: Column(
            children: [
              Text(
                DateFormat('E').format(date).toUpperCase(),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                date.day.toString(),
                style: TextStyle(
                  color: _isToday(date) ? AppColors.primary : Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildHabitRow(LoggedTask habit, List<DateTime> weekDays) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(_getIconData(habit.icon), size: 14, color: AppColors.primary.withValues(alpha: 0.6)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    habit.name,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ...weekDays.map((date) => Expanded(
            child: _buildDot(habit, date),
          )),
        ],
      ),
    );
  }

  Widget _buildDot(LoggedTask habit, DateTime date) {
    final status = _getHabitStatusForDate(habit.taskTemplateId, habit.name, date);
    
    Color dotColor;
    switch (status) {
      case TaskStatus.completed:
      case TaskStatus.late:
        dotColor = AppColors.success;
        break;
      case TaskStatus.partial:
        dotColor = AppColors.warning;
        break;
      case TaskStatus.skipped:
        dotColor = AppColors.error;
        break;
      default:
        dotColor = Colors.white.withValues(alpha: 0.05);
    }

    return Center(
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: status == TaskStatus.pending ? Colors.transparent : dotColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: status == TaskStatus.pending ? Colors.white.withValues(alpha: 0.1) : dotColor,
            width: 1.5,
          ),
        ),
        child: status == TaskStatus.completed || status == TaskStatus.late
            ? Icon(Icons.check, size: 8, color: dotColor)
            : null,
      ),
    );
  }

  TaskStatus _getHabitStatusForDate(String templateId, String name, DateTime date) {
    final logForDay = logs.cast<DailyLog?>().firstWhere(
      (l) => _isSameDay(l!.date, date),
      orElse: () => null,
    );
    
    if (logForDay == null) return TaskStatus.pending;

    final task = logForDay.tasks.cast<LoggedTask?>().firstWhere(
      (t) => t!.taskTemplateId == templateId || t.name == name,
      orElse: () => null,
    );

    return task?.status ?? TaskStatus.pending;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'water': return Icons.water_drop;
      case 'fitness': return Icons.fitness_center;
      case 'meditation': return Icons.self_improvement;
      case 'reading': return Icons.menu_book;
      case 'coding': return Icons.code;
      default: return Icons.check_circle;
    }
  }
}
