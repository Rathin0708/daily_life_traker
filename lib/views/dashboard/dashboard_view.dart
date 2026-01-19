import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../data/models/user_model.dart';
import 'today_view.dart';
import '../routine_templates/template_list_view.dart';
import '../calendar/calendar_view.dart';
import '../analytics/analytics_view.dart';
import '../auth/auth_wrapper.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TodayView(),
    const CalendarView(),
    const AnalyticsView(),
    const TemplateListView(),
  ];

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    return PenaltyZoneWrapper(
      user: user,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hunter Tracker'),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => authViewModel.signOut(),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Row(
          children: [
            if (MediaQuery.of(context).size.width > 600)
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.today), label: Text('Today')),
                  NavigationRailDestination(icon: Icon(Icons.calendar_month), label: Text('Calendar')),
                  NavigationRailDestination(icon: Icon(Icons.bar_chart), label: Text('Analytics')),
                  NavigationRailDestination(icon: Icon(Icons.assignment), label: Text('Routines')),
                ],
              ),
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
        bottomNavigationBar: MediaQuery.of(context).size.width <= 600
            ? BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (idx) => setState(() => _selectedIndex = idx),
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
                  BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
                  BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
                  BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Routines'),
                ],
              )
            : null,
      ),
    );
  }
}
