import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/calendar_viewmodel.dart';
import '../../data/models/routine_models.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final calendarVM = context.watch<CalendarViewModel?>();

    if (calendarVM == null) return const Center(child: CircularProgressIndicator());

    final now = calendarVM.focusedDay;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy').format(now)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => calendarVM.setFocusedDay(DateTime(now.year, now.month - 1)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => calendarVM.setFocusedDay(DateTime(now.year, now.month + 1)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((d) => Text(d, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))
                  .toList(),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: daysInMonth + (startingWeekday - 1),
              itemBuilder: (context, index) {
                if (index < startingWeekday - 1) return const SizedBox.shrink();
                
                final day = index - (startingWeekday - 2);
                final date = DateTime(now.year, now.month, day);
                final log = calendarVM.monthlyLogs.firstWhere(
                  (l) => l.date.day == day && l.date.month == now.month && l.date.year == now.year,
                  orElse: () => DailyLog(id: '', userId: '', date: date, tasks: [], followScore: -1),
                );

                return _buildCalendarDay(context, date, log);
              },
            ),
          ),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(BuildContext context, DateTime date, DailyLog log) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    Color color = Colors.transparent;
    
    if (log.followScore >= 90) {
      color = Colors.green.withValues(alpha: 0.7);
    } else if (log.followScore >= 50) {
      color = Colors.amber.withValues(alpha: 0.7);
    } else if (log.followScore >= 0) {
      color = Colors.red.withValues(alpha: 0.7);
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: color != Colors.transparent ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Colors.green, '90%+'),
          const SizedBox(width: 16),
          _legendItem(Colors.amber, '50%+'),
          const SizedBox(width: 16),
          _legendItem(Colors.red, '<50%'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
