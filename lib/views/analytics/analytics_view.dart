import 'package:daily_routine_follow_tracker/data/models/user_model.dart' show AppUser;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/analytics_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/utils/hunter_stats_calculator.dart';
import '../../core/widgets/hunter_progress_ring.dart';
import '../../core/theme/app_theme.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final analyticsVM = context.watch<AnalyticsViewModel?>();
    final authVM = context.watch<AuthViewModel?>();
    final user = authVM?.currentUser;

    if (analyticsVM == null || analyticsVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hunter Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHunterProfileCard(user),
            const SizedBox(height: 24),
            _buildStatCards(analyticsVM, user),
            const SizedBox(height: 24),
            _buildChartSection(context, analyticsVM),
            const SizedBox(height: 24),
            _buildImprovementTips(analyticsVM),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(AnalyticsViewModel vm, AppUser? user) {
    return Row(
      children: [
        Expanded(
          child: _statCard('Avg Power', '${vm.averageScore.toStringAsFixed(1)}%', AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard('Survival Days', '${vm.perfectDays}', AppColors.success),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildHunterProfileCard(AppUser? user) {
    if (user == null) return const SizedBox.shrink();
    
    final rank = HunterStatsCalculator.rankToString(user.hunterRank);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getRankGradientStart(rank),
            _getRankGradientEnd(rank),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getRankColor(rank).withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HUNTER RANK',
                    style: TextStyle(
                      color: _getRankTextColor(rank),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    rank,
                    style: TextStyle(
                      color: _getRankTextColor(rank),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              HunterProgressRing(
                progress: (user.level % 10) / 10, // Level progress to next rank
                size: 80,
                rank: rank,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMiniCard('STR', user.strength.toString(), Colors.red.shade400),
              _buildStatMiniCard('INT', user.intelligence.toString(), Colors.blue.shade400),
              _buildStatMiniCard('AGI', user.agility.toString(), Colors.green.shade400),
              _buildStatMiniCard('WIL', user.willpower.toString(), Colors.orange.shade400),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMiniCard(String label, String value, Color color) {
    return Container(
      width: 60,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case 'E': return Colors.grey.shade500;
      case 'D': return Colors.brown.shade400;
      case 'C': return Colors.green.shade400;
      case 'B': return Colors.blue.shade400;
      case 'A': return Colors.orange.shade400;
      case 'S': return Colors.purple.shade400;
      case 'Monarch': return Colors.yellow.shade400;
      default: return Colors.grey.shade500;
    }
  }

  Color _getRankGradientStart(String rank) {
    switch (rank) {
      case 'E': return const Color(0xFF4A5568);
      case 'D': return const Color(0xFF92400E);
      case 'C': return const Color(0xFF059669);
      case 'B': return const Color(0xFF2563EB);
      case 'A': return const Color(0xFFEA580C);
      case 'S': return const Color(0xFF7E22CE);
      case 'Monarch': return const Color(0xFFCA8A04);
      default: return const Color(0xFF4A5568);
    }
  }

  Color _getRankGradientEnd(String rank) {
    switch (rank) {
      case 'E': return const Color(0xFF2D3748);
      case 'D': return const Color(0xFF7C2D12);
      case 'C': return const Color(0xFF065F46);
      case 'B': return const Color(0xFF1D4ED8);
      case 'A': return const Color(0xFF92400E);
      case 'S': return const Color(0xFF6D28D9);
      case 'Monarch': return const Color(0xFFA16207);
      default: return const Color(0xFF2D3748);
    }
  }

  Color _getRankTextColor(String rank) {
    switch (rank) {
      case 'Monarch': return Colors.yellow.shade200;
      default: return Colors.white;
    }
  }

  Widget _buildChartSection(BuildContext context, AnalyticsViewModel vm) {
    if (vm.allLogs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('Not enough data for charts yet.')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Discipline Trend (Last 30 Days)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: vm.allLogs.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.followScore);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementTips(AnalyticsViewModel vm) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Tips', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.lightbulb_outline, color: Colors.amber),
              title: Text('Try to complete hard tasks early in the morning.'),
              dense: true,
            ),
            ListTile(
              leading: Icon(Icons.flash_on, color: Colors.orange),
              title: Text('Don\'t break your streak! Even 10 minutes counts.'),
              dense: true,
            ),
          ],
        ),
      ),
    );
  }
}
