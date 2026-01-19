import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'anime_system_evaluation.dart';
import '../../data/models/routine_models.dart';
import '../../core/widgets/progress_rings.dart';
import '../../core/widgets/hunter_progress_ring.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/motivation.dart';
import '../../core/widgets/weekly_habit_grid.dart';
import '../../core/widgets/system_notification_overlay.dart';
import '../../core/utils/hunter_stats_calculator.dart';

class TodayView extends StatelessWidget {
  const TodayView({super.key});

  @override
  Widget build(BuildContext context) {
    final routineVM = context.watch<RoutineViewModel?>();

    if (routineVM == null || routineVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final log = routineVM.todayLog;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, log?.followScore ?? 0),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDynamicHeader(context),
                  const SizedBox(height: 32),
                  _buildWeeklyGrid(routineVM),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'DAILY DISCIPLINE PIPELINE', () => _showAddTaskDialog(context, routineVM)),
                  const SizedBox(height: 16),
                  if (log == null || log.tasks.isEmpty)
                    _buildEmptyState(context, routineVM)
                  else
                    ...log.tasks.asMap().entries.map((entry) {
                      return _buildBeautifulTaskItem(context, entry.value, entry.key, routineVM);
                    }),
                  const SizedBox(height: 48),
                  if (log != null && log.tasks.isNotEmpty)
                    _buildFinishDayButton(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context, routineVM),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, double score) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;
    
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Decorative Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.secondary.withValues(alpha: 0.1),
                    AppColors.background,
                  ],
                ),
              ),
            ),
            // Hunter Progress Ring in Header
            Center(
              child: HunterProgressRing(
                progress: score / 100, // Normalize to 0-1
                size: 160,
                rank: user != null ? HunterStatsCalculator.rankToString(user.hunterRank) : 'E',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicHeader(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user?.displayName != null ? 'Hunter ${user!.displayName}' : 'Hunter Initiate',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
            const SizedBox(width: 4),
            Text(
              '${user?.currentStreak ?? 0} DAY SURVIVAL',
              style: TextStyle(
                color: Colors.orange.shade300,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(
              'HUNTER LV. ${user?.level ?? 1}',
              style: TextStyle(
                color: Colors.amber.shade300,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.grade, color: Colors.purple, size: 18),
            const SizedBox(width: 4),
            Text(
              'RANK ${user != null ? HunterStatsCalculator.rankToString(user.hunterRank) : 'E'}',
              style: TextStyle(
                color: Colors.purple.shade300,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(
            '"${DailyMotivation.randomQuote}"',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyGrid(RoutineViewModel vm) {
    if (vm.lastWeekLogs.isEmpty) return const SizedBox.shrink();

    // Get unique habits across last week's logs to show in the grid row
    final Map<String, LoggedTask> uniqueHabits = {};
    // Sort logs by date descending to get the most recent task metadata if available
    final sortedLogs = List<DailyLog>.from(vm.lastWeekLogs)..sort((a, b) => b.date.compareTo(a.date));
    
    for (var log in sortedLogs) {
      for (var task in log.tasks) {
        if (!uniqueHabits.containsKey(task.name)) {
          uniqueHabits[task.name] = task;
        }
      }
    }

    if (uniqueHabits.isEmpty) return const SizedBox.shrink();

    return WeeklyHabitGrid(
      habits: uniqueHabits.values.toList(),
      logs: vm.lastWeekLogs,
      focusedDate: DateTime.now(),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, RoutineViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text(
            'The canvas is empty.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Define your discipline for today.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddTaskDialog(context, vm),
            child: const Text('Add Your First Task'),
          ),
        ],
      ),
    );
  }

  Widget _buildBeautifulTaskItem(BuildContext context, LoggedTask task, int index, RoutineViewModel vm) {
    final bool isCompleted = task.status == TaskStatus.completed || task.status == TaskStatus.late;
    final authVM = context.read<AuthViewModel>();

    Future<void> handleStatusUpdate(TaskStatus status) async {
      final exp = await vm.updateTaskStatus(index, status);
      if (exp > 0) {
        // Calculate stat increases
        final statsIncreases = HunterStatsCalculator.calculateStatIncreases([task]);
        authVM.addExperience(exp, statIncreases: statsIncreases);
      }
      
      // Sync streak
      final streak = await vm.recalculateStreak();
      authVM.updateStreak(streak);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted 
              ? AppColors.success.withValues(alpha: 0.3) 
              : _getQuestBorderColor(task.questType),
          width: isCompleted ? 2 : 1.5,
        ),
        boxShadow: [
          if (task.questType == 'boss') 
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 0),
            )
          else if (task.questType == 'main')
            BoxShadow(
              color: AppColors.warning.withValues(alpha: 0.2),
              blurRadius: 5,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: () => handleStatusUpdate(isCompleted ? TaskStatus.pending : TaskStatus.completed),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppColors.success : Colors.transparent,
              border: Border.all(
                color: isCompleted ? AppColors.success : _getQuestBorderColor(task.questType),
                width: 2,
              ),
            ),
            child: isCompleted 
                ? const Icon(Icons.check, size: 20, color: Colors.white) 
                : _getQuestIcon(task.questType),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildQuestTypeBadge(task.questType),
                const SizedBox(width: 8),
                _buildDifficultyBadge(task.difficulty),
                const SizedBox(width: 8),
                _buildPriorityBadge(task.priority),
                const SizedBox(width: 8),
                _buildCategoryChip(task.category),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.name,
              style: TextStyle(
                color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                decoration: task.status == TaskStatus.skipped ? TextDecoration.lineThrough : null,
              ),
            ),
            if (task.type == HabitType.counter)
              _buildCounterControls(task, index, vm),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: _getStatusColor(task.status)),
                const SizedBox(width: 8),
                Text(
                  task.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(task.status).withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.star, size: 10, color: _getDifficultyColor(task.difficulty)),
                const SizedBox(width: 4),
                Text(
                  '+${task.xpReward} XP',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (task.startTime != null) ...[
                  const SizedBox(width: 8),
                  const Text('•', style: TextStyle(color: Colors.white24)),
                  const SizedBox(width: 8),
                  Icon(Icons.access_time, size: 10, color: Colors.white.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    task.startTime!,
                    style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
            if (task.status == TaskStatus.pending && task.startTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: _buildTimeRemainingLabel(task.startTime!),
              ),
          ],
        ),
        trailing: PopupMenuButton<TaskStatus>(
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          onSelected: handleStatusUpdate,
          itemBuilder: (context) => [
            const PopupMenuItem(value: TaskStatus.completed, child: Text('Completed')),
            const PopupMenuItem(value: TaskStatus.late, child: Text('Mark Late')),
            const PopupMenuItem(value: TaskStatus.skipped, child: Text('Skip Task')),
            const PopupMenuItem(value: TaskStatus.pending, child: Text('Reset status')),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high': color = AppColors.error; break;
      case 'medium': color = AppColors.warning; break;
      case 'low': color = AppColors.success; break;
      default: color = AppColors.textSecondary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTimeRemainingLabel(String startTime) {
    try {
      final parts = startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final now = DateTime.now();
      final targetTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      final difference = targetTime.difference(now);
      
      if (difference.isNegative) {
        return Text(
          'OVERDUE BY ${difference.abs().inMinutes} MIN',
          style: const TextStyle(color: AppColors.error, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        );
      } else if (difference.inHours > 0) {
        return Text(
          'STARTS IN ${difference.inHours}H ${difference.inMinutes % 60}M',
          style: TextStyle(color: AppColors.primary.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.bold),
        );
      } else {
        return Text(
          'STARTS IN ${difference.inMinutes} MIN',
          style: const TextStyle(color: AppColors.warning, fontSize: 9, fontWeight: FontWeight.bold),
        );
      }
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed: return AppColors.success;
      case TaskStatus.late: return AppColors.warning;
      case TaskStatus.partial: return AppColors.warning;
      case TaskStatus.skipped: return AppColors.error;
      case TaskStatus.pending: return AppColors.textSecondary;
    }
  }

  Color _getQuestBorderColor(String questType) {
    switch (questType) {
      case 'main': return AppColors.warning;
      case 'boss': return AppColors.error;
      case 'side': return AppColors.textSecondary;
      default: return AppColors.textSecondary;
    }
  }

  Widget _getQuestIcon(String questType) {
    switch (questType) {
      case 'main': return Icon(Icons.flag, size: 16, color: AppColors.warning);
      case 'boss': return Icon(Icons.star, size: 16, color: AppColors.error);
      case 'side': return Icon(Icons.add_task, size: 16, color: AppColors.textSecondary);
      default: return Icon(Icons.check_box_outline_blank, size: 16, color: AppColors.textSecondary);
    }
  }

  Widget _buildQuestTypeBadge(String questType) {
    Color color;
    String label;
    
    switch (questType) {
      case 'main':
        color = AppColors.warning;
        label = 'MAIN';
        break;
      case 'boss':
        color = AppColors.error;
        label = 'BOSS';
        break;
      case 'side':
        color = AppColors.textSecondary;
        label = 'SIDE';
        break;
      default:
        color = AppColors.textSecondary;
        label = 'TASK';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color, 
          fontSize: 8, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 0.5
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    String label;
    
    switch (difficulty) {
      case 'easy':
        color = AppColors.success;
        label = 'EASY';
        break;
      case 'normal':
        color = AppColors.textSecondary;
        label = 'NORM';
        break;
      case 'hard':
        color = AppColors.warning;
        label = 'HARD';
        break;
      case 'very_hard':
        color = AppColors.error;
        label = 'HELL';
        break;
      default:
        color = AppColors.textSecondary;
        label = 'NORM';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color, 
          fontSize: 8, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 0.5
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy': return AppColors.success;
      case 'normal': return AppColors.textSecondary;
      case 'hard': return AppColors.warning;
      case 'very_hard': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  Widget _buildCounterControls(LoggedTask task, int index, RoutineViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          _buildActionButton(Icons.remove, () => vm.updateHabitValue(index, (task.currentValue - 1).clamp(0, task.targetValue))),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${task.currentValue.toInt()} / ${task.targetValue.toInt()} ${task.unit}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildActionButton(Icons.add, () => vm.updateHabitValue(index, (task.currentValue + 1).clamp(0, task.targetValue))),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildFinishDayButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text(
            'Ready to close the day?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnimeSystemEvaluation()),
              );
            },
            icon: const Icon(Icons.nightlight_round),
            label: const Text('Complete Daily Evaluation'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, RoutineViewModel vm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('New Objective'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter mission name',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ABORT')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                vm.addTaskToToday(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('DEPLOY'),
          ),
        ],
      ),
    );
  }
}
