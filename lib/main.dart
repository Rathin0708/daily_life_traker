import 'core/theme/app_theme.dart';
import 'core/theme/solo_leveling_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/routine_repository.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/routine_viewmodel.dart';
import 'viewmodels/template_viewmodel.dart';
import 'viewmodels/calendar_viewmodel.dart';
import 'viewmodels/analytics_viewmodel.dart';
import 'views/auth/auth_wrapper.dart';
import 'views/system/system_entry_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/utils/hunter_stats_calculator.dart';
import 'core/utils/penalty_zone_manager.dart';
import 'core/utils/user_migration.dart';

// We will add ViewModels here as we create them
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<RoutineRepository>(create: (_) => RoutineRepository()),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(context.read<AuthRepository>()),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, RoutineViewModel?>(
          create: (_) => null,
          update: (context, auth, previous) {
            if (auth.currentUser == null) return null;
            if (previous != null && previous.todayLog?.userId == auth.currentUser!.uid) {
              return previous;
            }
            return RoutineViewModel(
              context.read<RoutineRepository>(),
              auth.currentUser!.uid,
            );
          },
        ),
        ChangeNotifierProxyProvider<AuthViewModel, TemplateViewModel?>(
          create: (_) => null,
          update: (context, auth, previous) {
            if (auth.currentUser == null) return null;
            if (previous != null && previous.isLoading == false) {
              return previous;
            }
            return TemplateViewModel(
              context.read<RoutineRepository>(),
              auth.currentUser!.uid,
            );
          },
        ),
        ChangeNotifierProxyProvider<AuthViewModel, CalendarViewModel?>(
          create: (_) => null,
          update: (context, auth, previous) {
            if (auth.currentUser == null) return null;
            if (previous != null) return previous;
            return CalendarViewModel(
              context.read<RoutineRepository>(),
              auth.currentUser!.uid,
            );
          },
        ),
        ChangeNotifierProxyProvider<AuthViewModel, AnalyticsViewModel?>(
          create: (_) => null,
          update: (context, auth, previous) {
            if (auth.currentUser == null) return null;
            if (previous != null) return previous;
            return AnalyticsViewModel(
              context.read<RoutineRepository>(),
              auth.currentUser!.uid,
            );
          },
        ),
      ],
      child: MaterialApp(
        title: 'Routine Tracker',
        debugShowCheckedModeBanner: false,
        theme: SoloLevelingTheme.darkTheme,
        home: const SystemEntryScreen(),
      ),
    );
  }
}
