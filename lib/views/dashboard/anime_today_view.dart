import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../data/models/routine_models.dart';
import '../../core/theme/solo_leveling_theme.dart';
import '../dashboard/system_evaluation_view.dart';
import 'dungeon_mode_screen.dart';

class AnimeTodayView extends StatelessWidget {
  const AnimeTodayView({super.key});

  @override
  Widget build(BuildContext context) {
    final routineVM = context.watch<RoutineViewModel?>();
    
    if (routineVM == null || routineVM.isLoading) {
      return const _LoadingScreen();
    }

    final log = routineVM.todayLog;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAnimeAppBar(context, log?.followScore ?? 0),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHunterHeader(context),
                  const SizedBox(height: 32),
                  _buildQuestBoard(context, routineVM),
                  const SizedBox(height: 48),
                  if (log != null && log.tasks.isNotEmpty)
                    _buildCompleteDayButton(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddQuestButton(context, routineVM),
    );
  }

  Widget _buildAnimeAppBar(BuildContext context, double score) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: SoloLevelingColors.absoluteBlack,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Dynamic Background Gradient
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: score >= 90 
                    ? [SoloLevelingColors.electricBlue.withOpacity(0.3), SoloLevelingColors.indigoGlow.withOpacity(0.2)]
                    : score >= 70
                      ? [SoloLevelingColors.amberGold.withOpacity(0.2), SoloLevelingColors.purpleEnergy.withOpacity(0.1)]
                      : [SoloLevelingColors.crimsonRed.withOpacity(0.2), SoloLevelingColors.deepCharcoal],
                ),
              ),
            ),
            
            // Power Meter Visualization
            Center(
              child: _PowerMeter(progress: score / 100),
            ),
            
            // Ambient Particles
            const _AmbientParticles(),
          ],
        ),
      ),
    );
  }

  Widget _buildHunterHeader(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SoloLevelingColors.cardSurface.withOpacity(0.9),
            SoloLevelingColors.slateGray.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SoloLevelingColors.panelBorder.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: SoloLevelingShadows.cardGlow(SoloLevelingColors.electricBlue, blur: 20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user?.displayName != null 
              ? 'HUNTER ${user!.displayName?.toUpperCase() ?? 'ANONYMOUS'}' 
              : 'INITIATE ACCESS GRANTED',
            style: SoloLevelingTypography.systemTitle.copyWith(
              fontSize: 24,
              color: SoloLevelingColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusBadge(
                icon: Icons.local_fire_department,
                label: 'SURVIVAL DAYS',
                value: '${user?.currentStreak ?? 0}',
                color: SoloLevelingColors.amberGold,
              ),
              
              _buildStatusBadge(
                icon: Icons.star,
                label: 'HUNTER LEVEL',
                value: '${user?.level ?? 1}',
                color: SoloLevelingColors.electricBlue,
              ),
              
              _buildStatusBadge(
                icon: Icons.grade,
                label: 'CURRENT RANK',
                value: user != null 
                  ? _getRankString(user.hunterRank) 
                  : 'E',
                color: SoloLevelingColors.purpleEnergy,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: SoloLevelingTypography.statNumber.copyWith(
            fontSize: 20,
            color: color,
          ),
        ),
        Text(
          label,
          style: SoloLevelingTypography.systemText.copyWith(
            fontSize: 10,
            color: SoloLevelingColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestBoard(BuildContext context, RoutineViewModel vm) {
    final log = vm.todayLog;
    
    if (log == null || log.tasks.isEmpty) {
      return _buildEmptyQuestBoard(context, vm);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('DAILY MISSION BOARD'),
        const SizedBox(height: 20),
        
        // Quest Categories
        ...log.tasks.asMap().entries.map((entry) {
          return _buildQuestPanel(context, entry.value, entry.key, vm);
        }).toList(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: SoloLevelingColors.panelBorder,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: SoloLevelingTypography.systemText.copyWith(
          fontSize: 14,
          letterSpacing: 2.0,
          color: SoloLevelingColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildQuestPanel(
    BuildContext context, 
    LoggedTask task, 
    int index, 
    RoutineViewModel vm
  ) {
    final isCompleted = task.status == TaskStatus.completed || 
                       task.status == TaskStatus.late;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: _getQuestGradient(task.questType, isCompleted),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getQuestBorderColor(task.questType, isCompleted),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: _getQuestShadows(task.questType, isCompleted),
      ),
      child: InkWell(
        onTap: () => _handleTaskTap(context, task, index, vm),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quest Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuestTags(task),
                  _buildXPReward(task),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Quest Title
              Text(
                task.name,
                style: SoloLevelingTypography.questTitle.copyWith(
                  color: isCompleted 
                    ? SoloLevelingColors.textSecondary 
                    : SoloLevelingColors.textPrimary,
                  decoration: task.status == TaskStatus.skipped 
                    ? TextDecoration.lineThrough 
                    : null,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Quest Details
              _buildQuestDetails(task),
              
              const SizedBox(height: 12),
              
              // Action Area
              _buildQuestActions(context, task, index, vm, isCompleted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestTags(LoggedTask task) {
    return Row(
      children: [
        _QuestTag(
          text: task.questType.toUpperCase(),
          color: _getQuestTypeColor(task.questType),
        ),
        const SizedBox(width: 8),
        _QuestTag(
          text: task.difficulty.toUpperCase(),
          color: _getDifficultyColor(task.difficulty),
        ),
        if (task.startTime != null) ...[
          const SizedBox(width: 8),
          _QuestTag(
            text: task.startTime!,
            color: SoloLevelingColors.textSecondary,
          ),
        ],
      ],
    );
  }

  Widget _buildXPReward(LoggedTask task) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: SoloLevelingGradients.acceptQuest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: SoloLevelingShadows.cardGlow(SoloLevelingColors.electricBlue),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 14, color: SoloLevelingColors.textPrimary),
          const SizedBox(width: 4),
          Text(
            '+${task.xpReward}',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 12,
              color: SoloLevelingColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestDetails(LoggedTask task) {
    return Row(
      children: [
        Icon(
          _getStatusIcon(task.status),
          size: 14,
          color: _getStatusColor(task.status),
        ),
        const SizedBox(width: 8),
        Text(
          task.status.name.toUpperCase(),
          style: SoloLevelingTypography.systemText.copyWith(
            fontSize: 12,
            color: _getStatusColor(task.status),
          ),
        ),
        const SizedBox(width: 16),
        Icon(Icons.access_time, size: 14, color: SoloLevelingColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          _getTimeRemaining(task.startTime),
          style: SoloLevelingTypography.systemText.copyWith(
            fontSize: 12,
            color: SoloLevelingColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestActions(
    BuildContext context,
    LoggedTask task,
    int index,
    RoutineViewModel vm,
    bool isCompleted,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!isCompleted)
          ElevatedButton(
            onPressed: () => vm.updateTaskStatus(index, TaskStatus.completed),
            style: ElevatedButton.styleFrom(
              backgroundColor: SoloLevelingColors.successGlow,
              foregroundColor: SoloLevelingColors.absoluteBlack,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('COMPLETE'),
          )
        else
          OutlinedButton(
            onPressed: () => vm.updateTaskStatus(index, TaskStatus.pending),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: SoloLevelingColors.textSecondary),
              foregroundColor: SoloLevelingColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('RESET'),
          ),
      ],
    );
  }

  Widget _buildEmptyQuestBoard(BuildContext context, RoutineViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: SoloLevelingColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SoloLevelingColors.panelBorder.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 60,
            color: SoloLevelingColors.textSecondary,
          ),
          const SizedBox(height: 20),
          Text(
            'NO ACTIVE MISSIONS',
            style: SoloLevelingTypography.systemText.copyWith(
              color: SoloLevelingColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Deploy your first objective to begin the hunt.',
            textAlign: TextAlign.center,
            style: SoloLevelingTypography.systemText.copyWith(
              color: SoloLevelingColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddQuestDialog(context, vm),
            child: const Text('DEPLOY MISSION'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteDayButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SoloLevelingColors.cardSurface.withOpacity(0.8),
            SoloLevelingColors.slateGray.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SoloLevelingColors.panelBorder.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'MISSION DAY COMPLETE?',
            style: SoloLevelingTypography.systemText.copyWith(
              color: SoloLevelingColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SystemEvaluationView(),
                ),
              );
            },
            icon: const Icon(Icons.nightlight_round),
            label: const Text('SUBMIT FOR EVALUATION'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddQuestButton(BuildContext context, RoutineViewModel vm) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddQuestDialog(context, vm),
      backgroundColor: SoloLevelingColors.electricBlue,
      foregroundColor: SoloLevelingColors.textPrimary,
      icon: const Icon(Icons.add),
      label: const Text('NEW MISSION'),
    );
  }

  // Helper Methods
  void _handleTaskTap(BuildContext context, LoggedTask task, int index, RoutineViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SoloLevelingColors.cardSurface,
      builder: (context) => _TaskDetailSheet(task: task, index: index, viewModel: vm),
    );
  }

  void _showAddQuestDialog(BuildContext context, RoutineViewModel vm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingColors.cardSurface,
        title: Text(
          'DEPLOY NEW MISSION',
          style: SoloLevelingTypography.systemText,
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter mission parameters...',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
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

  // Utility methods for styling
  Gradient _getQuestGradient(String questType, bool isCompleted) {
    if (isCompleted) {
      return const LinearGradient(
        colors: [Color(0xFF2F4F4F), Color(0xFF36454F)],
      );
    }
    
    switch (questType) {
      case 'boss':
        return SoloLevelingGradients.bossAura;
      case 'main':
        return const LinearGradient(
          colors: [Color(0xFF191970), Color(0xFF4B0082)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF1C1C1C), Color(0xFF2D2D2D)],
        );
    }
  }

  Color _getQuestBorderColor(String questType, bool isCompleted) {
    if (isCompleted) return SoloLevelingColors.successGlow;
    
    switch (questType) {
      case 'boss': return SoloLevelingColors.amberGold;
      case 'main': return SoloLevelingColors.electricBlue;
      default: return SoloLevelingColors.panelBorder;
    }
  }

  List<BoxShadow> _getQuestShadows(String questType, bool isCompleted) {
    if (isCompleted) {
      return SoloLevelingShadows.cardGlow(SoloLevelingColors.successGlow, blur: 10);
    }
    
    switch (questType) {
      case 'boss':
        return SoloLevelingShadows.auraEffect(SoloLevelingColors.amberGold, intensity: 0.8);
      case 'main':
        return SoloLevelingShadows.cardGlow(SoloLevelingColors.electricBlue, blur: 15);
      default:
        return SoloLevelingShadows.cardGlow(SoloLevelingColors.panelBorder, blur: 5);
    }
  }

  Color _getQuestTypeColor(String questType) {
    switch (questType) {
      case 'boss': return SoloLevelingColors.amberGold;
      case 'main': return SoloLevelingColors.electricBlue;
      default: return SoloLevelingColors.textSecondary;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy': return SoloLevelingColors.successGlow;
      case 'normal': return SoloLevelingColors.textSecondary;
      case 'hard': return SoloLevelingColors.warningPulse;
      case 'very_hard': return SoloLevelingColors.crimsonRed;
      default: return SoloLevelingColors.textSecondary;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed: return Icons.check_circle;
      case TaskStatus.late: return Icons.schedule;
      case TaskStatus.skipped: return Icons.cancel;
      default: return Icons.pending;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed: return SoloLevelingColors.successGlow;
      case TaskStatus.late: return SoloLevelingColors.warningPulse;
      case TaskStatus.skipped: return SoloLevelingColors.crimsonRed;
      default: return SoloLevelingColors.textSecondary;
    }
  }

  String _getTimeRemaining(String? startTime) {
    if (startTime == null) return 'ANYTIME';
    
    try {
      final parts = startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final now = DateTime.now();
      final targetTime = DateTime(now.year, now.month, now.day, hour, minute);
      final difference = targetTime.difference(now);
      
      if (difference.isNegative) {
        return 'OVERDUE';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}H ${difference.inMinutes % 60}M';
      } else {
        return '${difference.inMinutes} MIN';
      }
    } catch (e) {
      return 'INVALID TIME';
    }
  }

  String _getRankString(int rank) {
    const ranks = ['E', 'D', 'C', 'B', 'A', 'S', 'MONARCH'];
    return rank > 0 && rank <= ranks.length ? ranks[rank - 1] : 'E';
  }
}

// Supporting Widgets
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: SoloLevelingColors.absoluteBlack,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(SoloLevelingColors.electricBlue),
        ),
      ),
    );
  }
}

class _PowerMeter extends StatelessWidget {
  final double progress;

  const _PowerMeter({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: SoloLevelingColors.panelBorder,
          width: 8,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SoloLevelingColors.cardSurface,
            ),
          ),
          
          // Progress arc
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: _ProgressArcPainter(progress: progress),
            ),
          ),
          
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: SoloLevelingTypography.statNumber.copyWith(
                  fontSize: 28,
                  color: progress >= 0.9 
                    ? SoloLevelingColors.successGlow 
                    : progress >= 0.7 
                      ? SoloLevelingColors.warningPulse 
                      : SoloLevelingColors.crimsonRed,
                ),
              ),
              Text(
                'POWER',
                style: SoloLevelingTypography.systemText.copyWith(
                  fontSize: 12,
                  color: SoloLevelingColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressArcPainter extends CustomPainter {
  final double progress;

  _ProgressArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    // Background arc
    final backgroundPaint = Paint()
      ..color = SoloLevelingColors.panelBorder.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: progress >= 0.9
          ? [SoloLevelingColors.successGlow, SoloLevelingColors.electricBlue]
          : progress >= 0.7
            ? [SoloLevelingColors.warningPulse, SoloLevelingColors.amberGold]
            : [SoloLevelingColors.crimsonRed, SoloLevelingColors.dangerFlash],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AmbientParticles extends StatelessWidget {
  const _AmbientParticles();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(),
      size: Size.infinite,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SoloLevelingColors.electricBlue.withOpacity(0.1)
      ..strokeWidth = 1;
    
    // Draw subtle particles
    for (int i = 0; i < 15; i++) {
      final x = (i * 47.0) % size.width;
      final y = (i * 31.0) % size.height;
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuestTag extends StatelessWidget {
  final String text;
  final Color color;

  const _QuestTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: SoloLevelingTypography.systemText.copyWith(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TaskDetailSheet extends StatelessWidget {
  final LoggedTask task;
  final int index;
  final RoutineViewModel viewModel;

  const _TaskDetailSheet({
    required this.task,
    required this.index,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.name,
            style: SoloLevelingTypography.questTitle,
          ),
          const SizedBox(height: 16),
          
          // Detailed stats
          _DetailRow(label: 'TYPE', value: task.questType.toUpperCase()),
          _DetailRow(label: 'DIFFICULTY', value: task.difficulty.toUpperCase()),
          _DetailRow(label: 'XP REWARD', value: '+${task.xpReward}'),
          _DetailRow(label: 'STATUS', value: task.status.name.toUpperCase()),
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  viewModel.updateTaskStatus(index, TaskStatus.completed);
                  Navigator.pop(context);
                },
                child: const Text('COMPLETE'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: SoloLevelingTypography.systemText.copyWith(
              color: SoloLevelingColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: SoloLevelingTypography.systemText.copyWith(
              color: SoloLevelingColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}