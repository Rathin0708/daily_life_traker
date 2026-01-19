import 'package:daily_routine_follow_tracker/data/models/user_model.dart' show AppUser;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import 'login_view.dart';
import '../dashboard/dashboard_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    if (authViewModel.isAuthenticated) {
      return const DashboardView();
    } else {
      return const LoginView();
    }
  }
}

// Wrapper to check penalty zone status
class PenaltyZoneWrapper extends StatelessWidget {
  final Widget child;
  final AppUser? user;
  
  const PenaltyZoneWrapper({
    Key? key,
    required this.child,
    this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if penalty zone is active
    if (user?.penaltyActivatedAt != null) {
      return PenaltyZoneOverlay(child: child);
    }
    
    return child;
  }
}

// Penalty Zone Overlay Widget
class PenaltyZoneOverlay extends StatelessWidget {
  final Widget child;

  const PenaltyZoneOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Apply dark red tint
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0F172A).withOpacity(0.9), // AppColors.background
                const Color(0xFF3A0E0E).withOpacity(0.7),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
        // Warning icon overlay
        Positioned(
          top: 100,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade900.withOpacity(0.8),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade200,
              size: 30,
            ),
          ),
        ),
        // Status indicator
        Positioned(
          top: 100,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade800,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PENALTY ZONE',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        // Main content
        child,
      ],
    );
  }
}
