import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../data/models/routine_models.dart';
import '../../core/theme/solo_leveling_theme.dart';
import '../../core/utils/hunter_stats_calculator.dart';

class AnimeSystemEvaluation extends StatefulWidget {
  const AnimeSystemEvaluation({super.key});

  @override
  State<AnimeSystemEvaluation> createState() => _AnimeSystemEvaluationState();
}

class _AnimeSystemEvaluationState extends State<AnimeSystemEvaluation>
    with SingleTickerProviderStateMixin {
  late AnimationController _evaluationController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _statRevealAnimation;

  @override
  void initState() {
    super.initState();
    
    _evaluationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _scanLineAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _evaluationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    
    _statRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _evaluationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    // Start evaluation animation
    _evaluationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final routineVM = context.watch<RoutineViewModel?>();
    final authVM = context.watch<AuthViewModel>();

    if (routineVM == null || routineVM.todayLog == null) {
      return _buildLoadingScreen();
    }

    final log = routineVM.todayLog!;
    final dailyRank = HunterStatsCalculator.calculateDailyRank(log.followScore);
    final statsIncreases = HunterStatsCalculator.calculateStatIncreases(log.tasks);

    return Scaffold(
      backgroundColor: SoloLevelingColors.absoluteBlack,
      appBar: AppBar(
        backgroundColor: SoloLevelingColors.absoluteBlack,
        title: Text(
          'SYSTEM EVALUATION',
          style: SoloLevelingTypography.systemTitle.copyWith(fontSize: 20),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Animated background
          _buildEvaluationBackground(),
          
          // Scan line effect
          _buildScanLineEffect(),
          
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDailyRankDisplay(dailyRank, log.followScore),
                const SizedBox(height: 32),
                _buildPerformanceMetrics(log),
                const SizedBox(height: 32),
                _buildXPSummary(log),
                const SizedBox(height: 32),
                _buildStatImprovements(statsIncreases),
                const SizedBox(height: 32),
                _buildReflectionSection(routineVM),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: SoloLevelingColors.absoluteBlack,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(SoloLevelingColors.electricBlue),
        ),
      ),
    );
  }

  Widget _buildEvaluationBackground() {
    return AnimatedBuilder(
      animation: _evaluationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                SoloLevelingColors.deepCharcoal.withOpacity(0.8),
                SoloLevelingColors.absoluteBlack,
              ],
              center: const Alignment(-0.2, -0.3),
              radius: 1.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanLineEffect() {
    return AnimatedBuilder(
      animation: _scanLineAnimation,
      builder: (context, child) {
        return Positioned(
          left: 0,
          right: 0,
          top: MediaQuery.of(context).size.height * _scanLineAnimation.value,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  SoloLevelingColors.electricBlue.withOpacity(0.8),
                  SoloLevelingColors.neonCyan.withOpacity(0.6),
                  SoloLevelingColors.electricBlue.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyRankDisplay(String rank, double score) {
    Color rankColor = _getRankColor(rank);
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: _getRankGradient(rank),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: rankColor,
          width: 3,
        ),
        boxShadow: SoloLevelingShadows.auraEffect(rankColor, intensity: 1.2),
      ),
      child: Column(
        children: [
          Text(
            'DAILY PERFORMANCE RATING',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 14,
              color: SoloLevelingColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            rank,
            style: SoloLevelingTypography.rankDisplay.copyWith(
              fontSize: 80,
              color: rankColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${score.toStringAsFixed(1)}% COMPLETION',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 18,
              color: SoloLevelingColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildPerformanceDescription(rank),
        ],
      ),
    );
  }

  Widget _buildPerformanceDescription(String rank) {
    String description;
    IconData icon;
    Color color;
    
    switch (rank) {
      case 'S':
        description = 'OUTSTANDING PERFORMANCE';
        icon = Icons.auto_awesome;
        color = SoloLevelingColors.amberGold;
        break;
      case 'A':
        description = 'EXCELLENT EXECUTION';
        icon = Icons.trending_up;
        color = SoloLevelingColors.electricBlue;
        break;
      case 'B':
        description = 'SATISFACTORY RESULTS';
        icon = Icons.check_circle;
        color = SoloLevelingColors.successGlow;
        break;
      case 'C':
        description = 'MINIMUM REQUIREMENTS MET';
        icon = Icons.info;
        color = SoloLevelingColors.warningPulse;
        break;
      default:
        description = 'PERFORMANCE REVIEW REQUIRED';
        icon = Icons.warning;
        color = SoloLevelingColors.crimsonRed;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            description,
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(DailyLog log) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SoloLevelingColors.cardSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SoloLevelingColors.panelBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MISSION METRICS',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 16,
              color: SoloLevelingColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          _MetricRow(
            label: 'TOTAL TASKS',
            value: '${log.tasks.length}',
            icon: Icons.assignment,
            color: SoloLevelingColors.electricBlue,
          ),
          
          _MetricRow(
            label: 'COMPLETED',
            value: '${log.tasks.where((t) => t.status == TaskStatus.completed || t.status == TaskStatus.late).length}',
            icon: Icons.check_circle,
            color: SoloLevelingColors.successGlow,
          ),
          
          _MetricRow(
            label: 'SUCCESS RATE',
            value: '${(log.tasks.where((t) => t.status == TaskStatus.completed || t.status == TaskStatus.late).length / log.tasks.length * 100).toStringAsFixed(1)}%',
            icon: Icons.show_chart,
            color: SoloLevelingColors.amberGold,
          ),
          
          _MetricRow(
            label: 'HIGH PRIORITY',
            value: '${(log.tasks.where((t) => t.priority.toLowerCase() == 'high').length)}',
            icon: Icons.priority_high,
            color: SoloLevelingColors.warningPulse,
          ),
        ],
      ),
    );
  }

  Widget _buildXPSummary(DailyLog log) {
    int baseXP = log.tasks
        .where((t) => t.status == TaskStatus.completed || t.status == TaskStatus.late)
        .fold(0, (sum, task) => sum + task.xpReward);
    
    int bonusXP = 0;
    if (log.dailyRank == 'S') bonusXP += 500;
    if (log.tasks.any((t) => t.questType == 'boss' && 
        (t.status == TaskStatus.completed || t.status == TaskStatus.late))) {
      bonusXP += 300;
    }

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
        border: Border.all(color: SoloLevelingColors.panelBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENERGY ACQUISITION SUMMARY',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 16,
              color: SoloLevelingColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          _XPRewardRow(
            label: 'BASE ENERGY',
            value: '+$baseXP',
            color: SoloLevelingColors.electricBlue,
          ),
          
          if (bonusXP > 0) ...[
            const SizedBox(height: 12),
            _XPRewardRow(
              label: 'BONUS ENERGY',
              value: '+$bonusXP',
              color: SoloLevelingColors.amberGold,
            ),
          ],
          
          const SizedBox(height: 16),
          Container(
            height: 2,
            color: SoloLevelingColors.panelBorder,
          ),
          const SizedBox(height: 16),
          
          _XPRewardRow(
            label: 'TOTAL ACQUIRED',
            value: '+${baseXP + bonusXP}',
            color: SoloLevelingColors.successGlow,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatImprovements(Map<String, int> statsIncreases) {
    return AnimatedBuilder(
      animation: _statRevealAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _statRevealAnimation.value,
          child: Opacity(
            opacity: _statRevealAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SoloLevelingColors.cardSurface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SoloLevelingColors.panelBorder.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ABILITY ENHANCEMENT',
                    style: SoloLevelingTypography.systemText.copyWith(
                      fontSize: 16,
                      color: SoloLevelingColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  if (statsIncreases.values.every((v) => v == 0))
                    _buildNoImprovementMessage()
                  else ...[
                    for (final entry in statsIncreases.entries)
                      if (entry.value > 0)
                        _StatImprovementRow(
                          stat: entry.key.toUpperCase(),
                          increase: '+${entry.value}',
                          color: _getStatColor(entry.key),
                        ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoImprovementMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SoloLevelingColors.slateGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info,
            size: 32,
            color: SoloLevelingColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'NO SIGNIFICANT ABILITY GROWTH DETECTED',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 14,
              color: SoloLevelingColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionSection(RoutineViewModel routineVM) {
    final log = routineVM.todayLog!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SoloLevelingColors.cardSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SoloLevelingColors.panelBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYSTEM REFLECTION',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 16,
              color: SoloLevelingColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          _ReflectionInput(
            label: 'MOOD ASSESSMENT',
            initialValue: log.mood ?? '',
            onChanged: (value) {
              // Update mood in VM
            },
          ),
          
          const SizedBox(height: 16),
          
          _ReflectionInput(
            label: 'PERFORMANCE ANALYSIS',
            initialValue: log.reflection ?? '',
            maxLines: 5,
            onChanged: (value) {
              // Update reflection in VM
            },
          ),
          
          const SizedBox(height: 24),
          
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Save reflection and complete evaluation
                routineVM.saveReflection(
                  mood: '', // Get from controller
                  reflection: '', // Get from controller
                );
                
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SoloLevelingColors.successGlow,
                foregroundColor: SoloLevelingColors.absoluteBlack,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('FINALIZE EVALUATION'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getRankColor(String rank) {
    switch (rank) {
      case 'S': return SoloLevelingColors.amberGold;
      case 'A': return SoloLevelingColors.electricBlue;
      case 'B': return SoloLevelingColors.successGlow;
      case 'C': return SoloLevelingColors.warningPulse;
      default: return SoloLevelingColors.crimsonRed;
    }
  }

  Gradient _getRankGradient(String rank) {
    switch (rank) {
      case 'S':
        return const LinearGradient(
          colors: [Color(0xFF2D2400), Color(0xFF4D3D00)],
        );
      case 'A':
        return const LinearGradient(
          colors: [Color(0xFF001D2D), Color(0xFF00334D)],
        );
      case 'B':
        return const LinearGradient(
          colors: [Color(0xFF002D14), Color(0xFF004D24)],
        );
      case 'C':
        return const LinearGradient(
          colors: [Color(0xFF2D1D00), Color(0xFF4D3300)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF2D0000), Color(0xFF4D0000)],
        );
    }
  }

  Color _getStatColor(String stat) {
    switch (stat) {
      case 'strength': return SoloLevelingColors.crimsonRed;
      case 'intelligence': return SoloLevelingColors.electricBlue;
      case 'agility': return SoloLevelingColors.successGlow;
      case 'discipline': return SoloLevelingColors.purpleEnergy;
      case 'willpower': return SoloLevelingColors.amberGold;
      default: return SoloLevelingColors.textSecondary;
    }
  }

  @override
  void dispose() {
    _evaluationController.dispose();
    super.dispose();
  }
}

// Supporting Widgets
class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: SoloLevelingTypography.systemText.copyWith(
                  fontSize: 14,
                  color: SoloLevelingColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: SoloLevelingTypography.statNumber.copyWith(
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _XPRewardRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isTotal;

  const _XPRewardRow({
    required this.label,
    required this.value,
    required this.color,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: SoloLevelingTypography.systemText.copyWith(
            fontSize: isTotal ? 16 : 14,
            color: isTotal 
              ? SoloLevelingColors.textPrimary 
              : SoloLevelingColors.textSecondary,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: SoloLevelingTypography.systemText.copyWith(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatImprovementRow extends StatelessWidget {
  final String stat;
  final String increase;
  final Color color;

  const _StatImprovementRow({
    required this.stat,
    required this.increase,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            stat,
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 14,
              color: SoloLevelingColors.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: SoloLevelingShadows.cardGlow(color, blur: 10),
            ),
            child: Text(
              increase,
              style: SoloLevelingTypography.systemText.copyWith(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionInput extends StatelessWidget {
  final String label;
  final String initialValue;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const _ReflectionInput({
    required this.label,
    required this.initialValue,
    this.maxLines = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SoloLevelingTypography.systemText.copyWith(
            fontSize: 12,
            color: SoloLevelingColors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: SoloLevelingColors.slateGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: SoloLevelingColors.panelBorder.withOpacity(0.5),
            ),
          ),
          child: TextField(
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintText: 'Enter assessment...',
              hintStyle: TextStyle(color: Colors.white38),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}