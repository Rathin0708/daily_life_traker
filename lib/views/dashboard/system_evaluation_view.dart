import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../data/models/routine_models.dart';
import '../../core/utils/hunter_stats_calculator.dart';
import '../../core/widgets/hunter_progress_ring.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/system_notification_overlay.dart';

class SystemEvaluationView extends StatelessWidget {
  const SystemEvaluationView({super.key});

  @override
  Widget build(BuildContext context) {
    final routineVM = context.watch<RoutineViewModel?>();
    final authVM = context.watch<AuthViewModel>();

    if (routineVM == null || routineVM.todayLog == null) {
      return const Scaffold(
        body: Center(child: Text('No data available')),
      );
    }

    final log = routineVM.todayLog!;
    final dailyRank = HunterStatsCalculator.calculateDailyRank(log.followScore);
    final statsIncreases = HunterStatsCalculator.calculateStatIncreases(log.tasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Evaluation'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank display
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getRankColor(dailyRank),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'DAILY RANK',
                    style: TextStyle(
                      color: _getRankColor(dailyRank),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dailyRank,
                    style: TextStyle(
                      color: _getRankColor(dailyRank),
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${log.followScore.toStringAsFixed(1)}% COMPLETION',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // XP and rewards
            _buildSectionCard(
              'REWARDS SUMMARY',
              [
                ListTile(
                  leading: const Icon(Icons.star, color: AppColors.primary),
                  title: const Text('Base XP Earned'),
                  trailing: Text('+${log.xpGained} XP'),
                ),
                if (log.dailyRank == 'S')
                  ListTile(
                    leading: const Icon(Icons.local_fire_department, color: Colors.orange),
                    title: const Text('S-Rank Bonus'),
                    trailing: const Text('+500 XP'),
                  ),
                if (log.tasks.any((t) => t.questType == 'boss' && 
                    (t.status == TaskStatus.completed || t.status == TaskStatus.late)))
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.purple),
                    title: const Text('Boss Quest Bonus'),
                    trailing: const Text('+300 XP'),
                  ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Stat improvements
            _buildSectionCard(
              'STAT INCREASES',
              [
                for (final entry in statsIncreases.entries)
                  if (entry.value > 0)
                    ListTile(
                      leading: _getStatIcon(entry.key),
                      title: Text(_getStatName(entry.key)),
                      trailing: Text('+${entry.value} pts'),
                    ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Reflection section
            _buildReflectionSection(routineVM, context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReflectionSection(RoutineViewModel routineVM, BuildContext context) {
    final log = routineVM.todayLog!;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Text(
                'SYSTEM REFLECTION',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: TextEditingController(text: log.mood),
                    decoration: const InputDecoration(
                      labelText: 'Mood',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Update mood in VM
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: log.reflection),
                    decoration: const InputDecoration(
                      labelText: 'Today\'s Reflection',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      hintText: 'What did you learn today? What can be improved?',
                    ),
                    maxLines: 5,
                    onChanged: (value) {
                      // Update reflection in VM
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Save reflection and complete evaluation
                      routineVM.saveReflection(
                        mood: '', // Get from controller
                        reflection: '', // Get from controller
                      );
                      
                      // Show system message
                      showSystemNotification(
                        context,
                        'Hunter performance evaluated. Stats updated.',
                        type: 'success',
                      );
                      
                      Navigator.pop(context);
                    },
                    child: const Text('SUBMIT EVALUATION'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case 'S': return Colors.purple.shade400;
      case 'A': return Colors.orange.shade400;
      case 'B': return Colors.blue.shade400;
      case 'C': return Colors.green.shade400;
      default: return Colors.grey.shade400;
    }
  }

  Widget _getStatIcon(String stat) {
    switch (stat) {
      case 'strength': return Icon(Icons.directions_run, color: Colors.red.shade400);
      case 'intelligence': return Icon(Icons.psychology, color: Colors.blue.shade400);
      case 'agility': return Icon(Icons.speed, color: Colors.green.shade400);
      case 'discipline': return Icon(Icons.self_improvement, color: Colors.purple.shade400);
      case 'willpower': return Icon(Icons.grain, color: Colors.orange.shade400);
      default: return const Icon(Icons.help);
    }
  }

  String _getStatName(String stat) {
    switch (stat) {
      case 'strength': return 'Strength';
      case 'intelligence': return 'Intelligence';
      case 'agility': return 'Agility';
      case 'discipline': return 'Discipline';
      case 'willpower': return 'Willpower';
      default: return stat;
    }
  }
}