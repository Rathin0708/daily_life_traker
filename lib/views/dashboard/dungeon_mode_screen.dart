import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/routine_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/system_notification_overlay.dart';

class DungeonModeScreen extends StatefulWidget {
  final List<LoggedTask> tasks;
  final int durationMinutes;
  final String difficulty;

  const DungeonModeScreen({
    Key? key,
    required this.tasks,
    required this.durationMinutes,
    required this.difficulty,
  }) : super(key: key);

  @override
  _DungeonModeScreenState createState() => _DungeonModeScreenState();
}

class _DungeonModeScreenState extends State<DungeonModeScreen> 
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _isPaused = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    
    _timerController = AnimationController(
      duration: Duration(minutes: widget.durationMinutes),
      vsync: this,
    );
    
    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.linear),
    );

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completeDungeon(success: true);
      }
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isCompleted) {
        setState(() {
          _remainingSeconds--;
        });
        
        if (_remainingSeconds <= 0) {
          _completeDungeon(success: true);
          timer.cancel();
        }
      }
    });
  }

  void _pauseDungeon() {
    setState(() {
      _isPaused = true;
    });
    _timerController.stop();
  }

  void _resumeDungeon() {
    setState(() {
      _isPaused = false;
    });
    _timerController.forward();
  }

  void _exitDungeon() {
    _completeDungeon(success: false);
  }

  void _completeDungeon({bool success = true}) {
    setState(() {
      _isCompleted = true;
    });
    
    _timer.cancel();
    _timerController.stop();
    
    // Calculate bonus XP based on difficulty
    int bonusXp = 0;
    switch (widget.difficulty) {
      case 'normal': bonusXp = 200; break;
      case 'hard': bonusXp = 500; break;
      case 'hell': bonusXp = 1000; break;
    }
    
    // If successful, apply bonus XP to completed tasks
    if (success) {
      showSystemNotification(
        context,
        'Dungeon Clear! +$bonusXp XP Bonus!', 
        type: 'success'
      );
    } else {
      showSystemNotification(
        context,
        'Dungeon Failed! Penalty may apply.', 
        type: 'danger'
      );
    }
    
    // Navigate back with results
    Navigator.of(context).pop({
      'success': success,
      'bonusXp': success ? bonusXp : 0,
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A), // Very dark theme
      body: SafeArea(
        child: Column(
          children: [
            // Dungeon header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getDifficultyColor(widget.difficulty),
                    _getDifficultyColor(widget.difficulty).withOpacity(0.2),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'DUNGEON MODE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.difficulty.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Timer display
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _timerAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _getTimerColor(_timerAnimation.value),
                              width: 8,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _formatTime(_remainingSeconds),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _isPaused ? 'PAUSED' : 'CONTINUE TO SURVIVE',
                      style: TextStyle(
                        color: _isPaused ? Colors.orange : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Task list
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: widget.tasks.length,
                  itemBuilder: (context, index) {
                    final task = widget.tasks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: task.status == TaskStatus.completed 
                              ? AppColors.success 
                              : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: task.status == TaskStatus.completed 
                                  ? AppColors.success 
                                  : Colors.transparent,
                              border: Border.all(
                                color: task.status == TaskStatus.completed 
                                    ? AppColors.success 
                                    : AppColors.textSecondary,
                              ),
                            ),
                            child: task.status == TaskStatus.completed 
                                ? const Icon(Icons.check, size: 14, color: Colors.white) 
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              task.name,
                              style: TextStyle(
                                color: task.status == TaskStatus.completed 
                                    ? AppColors.textSecondary 
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Controls
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_isCompleted)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isPaused ? _resumeDungeon : _pauseDungeon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(_isPaused ? 'RESUME' : 'PAUSE'),
                      ),
                    ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _exitDungeon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('EXIT'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'normal': return Colors.blue.shade600;
      case 'hard': return Colors.orange.shade600;
      case 'hell': return Colors.red.shade600;
      default: return Colors.blue.shade600;
    }
  }

  Color _getTimerColor(double progress) {
    // Changes color as time runs out
    if (progress > 0.5) return Colors.green.shade400;
    if (progress > 0.25) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerController.dispose();
    super.dispose();
  }
}