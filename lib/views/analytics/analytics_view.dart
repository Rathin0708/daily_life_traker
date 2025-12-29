import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/analytics_viewmodel.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final analyticsVM = context.watch<AnalyticsViewModel?>();

    if (analyticsVM == null || analyticsVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatCards(analyticsVM),
            const SizedBox(height: 24),
            _buildChartSection(context, analyticsVM),
            const SizedBox(height: 24),
            _buildImprovementTips(analyticsVM),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(AnalyticsViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: _statCard('Avg Score', '${vm.averageScore.toStringAsFixed(1)}%', Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard('Perfect Days', '${vm.perfectDays}', Colors.green),
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
