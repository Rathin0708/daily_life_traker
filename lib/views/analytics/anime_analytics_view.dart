import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Changed from syncfusion_flutter_charts
import '../../viewmodels/analytics_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../data/models/user_model.dart';
import '../../core/theme/solo_leveling_theme.dart';
import '../../core/widgets/xp_system_widgets.dart';

class AnimeAnalyticsView extends StatelessWidget {
  const AnimeAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final analyticsVM = context.watch<AnalyticsViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      backgroundColor: SoloLevelingColors.absoluteBlack,
      appBar: AppBar(
        backgroundColor: SoloLevelingColors.absoluteBlack,
        title: Text(
          'HUNTER PERFORMANCE REPORT',
          style: SoloLevelingTypography.systemTitle.copyWith(fontSize: 20),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => analyticsVM.loadAnalyticsData(), // Updated method name
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user != null) _buildHunterProfileCard(user),
              const SizedBox(height: 32),
              _buildRankProgressSection(analyticsVM),
              const SizedBox(height: 32),
              _buildStatDistributionChart(analyticsVM),
              const SizedBox(height: 32),
              _buildWeeklyPerformanceChart(analyticsVM),
              const SizedBox(height: 32),
              _buildQuestCompletionChart(analyticsVM),
              const SizedBox(height: 32),
              _buildStreakAnalysis(analyticsVM),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHunterProfileCard(AppUser user) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SoloLevelingColors.cardSurface.withOpacity(0.9),
            SoloLevelingColors.slateGray.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: SoloLevelingColors.panelBorder.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getRankGlowColor(user.hunterRank),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Hunter Identity
          Text(
            'HUNTER ${user.displayName?.toUpperCase() ?? 'UNREGISTERED'}',
            style: SoloLevelingTypography.systemTitle.copyWith(
              fontSize: 24,
              color: SoloLevelingColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Rank Display
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: _getRankGradient(user.hunterRank),
              borderRadius: BorderRadius.circular(20),
              boxShadow: SoloLevelingShadows.auraEffect(
                _getRankGlowColor(user.hunterRank),
                intensity: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'RANK',
                  style: SoloLevelingTypography.systemText.copyWith(
                    fontSize: 14,
                    color: SoloLevelingColors.textSecondary,
                  ),
                ),
                Text(
                  _getRankString(user.hunterRank),
                  style: SoloLevelingTypography.rankDisplay.copyWith(
                    fontSize: 64,
                    color: _getRankGlowColor(user.hunterRank),
                  ),
                ),
                Text(
                  'HUNTER LEVEL ${user.level}',
                  style: SoloLevelingTypography.systemText.copyWith(
                    fontSize: 16,
                    color: SoloLevelingColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // XP Bar
          XPBar(
            currentXP: (user.currentXP ?? 0).toDouble(), // Updated to handle nullable
            maxXp: (user.nextLevelXP ?? 100).toDouble(), // Updated to handle nullable
            currentLevel: user.level,
            levelUpDuration: const Duration(milliseconds: 1500),
          ),
          const SizedBox(height: 24),
          
          // Hunter Stats Summary
          _buildStatSummaryRow(user),
        ],
      ),
    );
  }

  Widget _buildStatSummaryRow(AppUser user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SoloLevelingColors.slateGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SoloLevelingColors.panelBorder.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatMiniCard(
            label: 'STRENGTH',
            value: (user.strength ?? 0).toString(), // Updated to handle nullable
            color: SoloLevelingColors.crimsonRed,
          ),
          _StatMiniCard(
            label: 'INT',
            value: (user.intelligence ?? 0).toString(), // Updated to handle nullable
            color: SoloLevelingColors.electricBlue,
          ),
          _StatMiniCard(
            label: 'AGILITY',
            value: (user.agility ?? 0).toString(), // Updated to handle nullable
            color: SoloLevelingColors.successGlow,
          ),
          _StatMiniCard(
            label: 'DISCIPLINE',
            value: (user.discipline ?? 0).toString(), // Updated to handle nullable
            color: SoloLevelingColors.purpleEnergy,
          ),
          _StatMiniCard(
            label: 'WILL',
            value: (user.willpower ?? 0).toString(), // Updated to handle nullable
            color: SoloLevelingColors.amberGold,
          ),
        ],
      ),
    );
  }

  Widget _buildRankProgressSection(AnalyticsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SoloLevelingColors.cardSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SoloLevelingColors.panelBorder.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RANK PROGRESSION ANALYSIS',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 16,
              color: SoloLevelingColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          // Rank History Chart using fl_chart
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (vm.rankHistory?.length ?? 1).toDouble(),
                minY: 0,
                maxY: 7,
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        int dayNum = value.toInt() + 1;
                        return Text('Day $dayNum');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(_getRankString(value.toInt()));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: (vm.rankHistory ?? []).asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: SoloLevelingColors.purpleEnergy,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Progress Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ProgressMetric(
                label: 'AVG DAILY RANK',
                value: (vm.averageDailyRank ?? 0.0).toStringAsFixed(1), // Updated to handle nullable
                color: SoloLevelingColors.textPrimary,
              ),
              _ProgressMetric(
                label: 'PEAK RANK',
                value: _getRankString(vm.bestDailyRank ?? 1), // Updated to handle nullable
                color: SoloLevelingColors.amberGold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDistributionChart(AnalyticsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SoloLevelingColors.cardSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SoloLevelingColors.panelBorder.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STAT DISTRIBUTION ANALYSIS',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 16,
              color: SoloLevelingColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: (vm.avgStrength ?? 10.0), // Updated to handle nullable
                    color: SoloLevelingColors.crimsonRed,
                    title: "STR",
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: (vm.avgIntelligence ?? 10.0), // Updated to handle nullable
                    color: SoloLevelingColors.electricBlue,
                    title: "INT",
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: (vm.avgAgility ?? 10.0), // Updated to handle nullable
                    color: SoloLevelingColors.successGlow,
                    title: "AGI",
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: (vm.avgDiscipline ?? 10.0), // Updated to handle nullable
                    color: SoloLevelingColors.purpleEnergy,
                    title: "DIS",
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: (vm.avgWillpower ?? 10.0), // Updated to handle nullable
                    color: SoloLevelingColors.amberGold,
                    title: "WIL",
                    radius: 50,
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPerformanceChart(AnalyticsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SoloLevelingColors.cardSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SoloLevelingColors.panelBorder.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY PERFORMANCE TRENDS',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 16,
              color: SoloLevelingColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: 100,
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
                        int index = value.toInt();
                        if (index >= 0 && index < days.length) {
                          return Text(days[index]);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: (vm.weeklyPerformance ?? []).asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: SoloLevelingColors.electricBlue,
                        width: 10,
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCompletionChart(AnalyticsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SoloLevelingColors.cardSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SoloLevelingColors.panelBorder.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUEST TYPE COMPLETION RATES',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 16,
              color: SoloLevelingColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _QuestRateCard(
                    title: 'MAIN',
                    rate: vm.mainQuestCompletionRate ?? 0.0, // Updated to handle nullable
                    color: SoloLevelingColors.electricBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _QuestRateCard(
                    title: 'SIDE',
                    rate: vm.sideQuestCompletionRate ?? 0.0, // Updated to handle nullable
                    color: SoloLevelingColors.successGlow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _QuestRateCard(
                    title: 'BOSS',
                    rate: vm.bossQuestCompletionRate ?? 0.0, // Updated to handle nullable
                    color: SoloLevelingColors.amberGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakAnalysis(AnalyticsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SoloLevelingColors.cardSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SoloLevelingColors.panelBorder.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STREAK ANALYSIS',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 16,
              color: SoloLevelingColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StreakCard(
                title: 'CURRENT STREAK',
                value: vm.currentStreak.toString(),
                color: SoloLevelingColors.amberGold,
              ),
              _StreakCard(
                title: 'BEST STREAK',
                value: vm.bestStreak.toString(),
                color: SoloLevelingColors.successGlow,
              ),
              _StreakCard(
                title: 'AVG STREAK',
                value: vm.averageStreak.toStringAsFixed(1),
                color: SoloLevelingColors.electricBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getRankString(int rank) {
    const ranks = ['E', 'D', 'C', 'B', 'A', 'S', 'MONARCH'];
    return rank > 0 && rank <= ranks.length ? ranks[rank - 1] : 'E';
  }

  Color _getRankGlowColor(int rank) {
    switch (rank) {
      case 7: return SoloLevelingColors.amberGold; // MONARCH
      case 6: return SoloLevelingColors.amberGold; // S
      case 5: return SoloLevelingColors.electricBlue; // A
      case 4: return SoloLevelingColors.successGlow; // B
      case 3: return SoloLevelingColors.warningPulse; // C
      case 2: return SoloLevelingColors.crimsonRed; // D
      default: return SoloLevelingColors.dangerFlash; // E
    }
  }

  Gradient _getRankGradient(int rank) {
    switch (rank) {
      case 7: // MONARCH
        return SoloLevelingGradients.bossAura;
      case 6: // S
        return const LinearGradient(
          colors: [Color(0xFF2D2400), Color(0xFF4D3D00)],
        );
      case 5: // A
        return const LinearGradient(
          colors: [Color(0xFF001D2D), Color(0xFF00334D)],
        );
      case 4: // B
        return const LinearGradient(
          colors: [Color(0xFF002D14), Color(0xFF004D24)],
        );
      case 3: // C
        return const LinearGradient(
          colors: [Color(0xFF2D1D00), Color(0xFF4D3300)],
        );
      case 2: // D
        return const LinearGradient(
          colors: [Color(0xFF2D0000), Color(0xFF4D0000)],
        );
      default: // E
        return const LinearGradient(
          colors: [Color(0xFF2D0014), Color(0xFF4D0024)],
        );
    }
  }
}

// Supporting Widgets
class _StatMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            value,
            style: SoloLevelingTypography.statNumber.copyWith(
              fontSize: 16,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
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
}

class _ProgressMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ProgressMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
}

class _QuestRateCard extends StatelessWidget {
  final String title;
  final double rate;
  final Color color;

  const _QuestRateCard({
    required this.title,
    required this.rate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SoloLevelingColors.slateGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 12,
              color: SoloLevelingColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${rate.toStringAsFixed(1)}%',
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

class _StreakCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StreakCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SoloLevelingColors.slateGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 12,
              color: SoloLevelingColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: SoloLevelingTypography.statNumber.copyWith(
              fontSize: 20,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}