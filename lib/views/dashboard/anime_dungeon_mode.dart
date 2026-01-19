import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/routine_models.dart';
import '../../core/theme/solo_leveling_theme.dart';

class AnimeDungeonMode extends StatefulWidget {
  final List<LoggedTask> tasks;
  final int durationMinutes;
  final String difficulty; // 'normal', 'hard', 'hell'

  const AnimeDungeonMode({
    Key? key,
    required this.tasks,
    required this.durationMinutes,
    required this.difficulty,
  }) : super(key: key);

  @override
  State<AnimeDungeonMode> createState() => _AnimeDungeonModeState();
}

class _AnimeDungeonModeState extends State<AnimeDungeonMode>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _ambientController;
  late AnimationController _runeController;
  late Animation<double> _timerPulseAnimation;
  late Animation<double> _ambientFloatAnimation;
  late Animation<double> _runeRotationAnimation;
  
  late Timer _gameTimer;
  int _remainingSeconds = 0;
  bool _isPaused = false;
  bool _isCompleted = false;
  int _completedTasks = 0;
  bool _isFailed = false;
  
  final List<bool> _taskCompletionStates = [];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    _taskCompletionStates = List.generate(widget.tasks.length, (index) => false);
    
    // Initialize animation controllers
    _timerController = AnimationController(
      duration: Duration(minutes: widget.durationMinutes),
      vsync: this,
    );
    
    _ambientController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _runeController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    // Setup animations
    _timerPulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _timerController,
        curve: const Interval(0.9, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _ambientFloatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ambientController, curve: Curves.linear),
    );
    
    _runeRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _runeController, curve: Curves.linear),
    );
    
    // Start the dungeon session
    _startDungeon();
  }

  void _startDungeon() {
    _timerController.forward();
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isCompleted && mounted) {
        setState(() {
          _remainingSeconds--;
        });
        
        // Check completion conditions
        if (_remainingSeconds <= 0) {
          _completeDungeon(success: true);
          timer.cancel();
        } else if (_remainingSeconds <= 30 && !_isFailed) {
          // Enter critical phase
          setState(() {
            _isFailed = true;
          });
        }
      }
    });
  }

  void _completeDungeon({bool success = true}) {
    setState(() {
      _isCompleted = true;
      _isPaused = false;
    });
    
    _gameTimer.cancel();
    _timerController.stop();
    _ambientController.stop();
    _runeController.stop();
    
    // Calculate rewards
    int bonusXP = _calculateBonusXP(success);
    
    // Show completion screen after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showCompletionScreen(success, bonusXP);
      }
    });
  }

  int _calculateBonusXP(bool success) {
    if (!success) return 0;
    
    int baseBonus = 0;
    switch (widget.difficulty) {
      case 'normal': baseBonus = 200; break;
      case 'hard': baseBonus = 500; break;
      case 'hell': baseBonus = 1000; break;
    }
    
    // Bonus for completing all tasks
    if (_completedTasks == widget.tasks.length) {
      baseBonus = (baseBonus * 1.5).round();
    }
    
    return baseBonus;
  }

  void _toggleTaskCompletion(int index) {
    if (_isCompleted) return;
    
    setState(() {
      _taskCompletionStates[index] = !_taskCompletionStates[index];
      if (_taskCompletionStates[index]) {
        _completedTasks++;
      } else {
        _completedTasks--;
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

  void _showCompletionScreen(bool success, int bonusXP) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DungeonCompletionSheet(
        isSuccess: success,
        bonusXP: bonusXP,
        completedTasks: _completedTasks,
        totalTasks: widget.tasks.length,
        onReturn: () {
          Navigator.pop(context); // Close sheet
          Navigator.pop(context, {
            'success': success,
            'bonusXP': bonusXP,
            'completedTasks': _completedTasks,
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeProgress = 1.0 - (_remainingSeconds / (widget.durationMinutes * 60));
    
    return Scaffold(
      backgroundColor: SoloLevelingColors.absoluteBlack,
      body: Stack(
        children: [
          // Ambient background effects
          _buildAmbientBackground(timeProgress),
          
          // Rune circle centerpiece
          _buildRuneCircle(timeProgress),
          
          // HUD elements
          _buildHUD(timeProgress),
          
          // Task list
          _buildTaskList(),
          
          // Control panel
          _buildControlPanel(),
          
          // Overlay effects
          if (_isFailed) _buildCriticalPhaseOverlay(),
          if (_isPaused) _buildPauseOverlay(),
        ],
      ),
    );
  }

  Widget _buildAmbientBackground(double timeProgress) {
    return AnimatedBuilder(
      animation: _ambientFloatAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _DungeonAmbientPainter(
            timeProgress: timeProgress,
            floatAnimation: _ambientFloatAnimation.value,
            difficulty: widget.difficulty,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildRuneCircle(double timeProgress) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _timerController,
          _runeController,
          _timerPulseAnimation,
        ]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _runeRotationAnimation.value * 6.28, // Full rotation
            child: Transform.scale(
              scale: _isFailed 
                ? 1.0 + (0.1 * _timerPulseAnimation.value) 
                : 1.0,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getRuneColor(timeProgress),
                    width: 4,
                  ),
                  boxShadow: _getRuneShadows(timeProgress),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rune segments
                    _buildRuneSegments(timeProgress),
                    
                    // Central timer display
                    _buildTimerDisplay(timeProgress),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRuneSegments(double timeProgress) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _RuneSegmentPainter(
          progress: timeProgress,
          isCritical: _isFailed,
        ),
      ),
    );
  }

  Widget _buildTimerDisplay(double timeProgress) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    Color textColor = _getTextColor(timeProgress);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          timeString,
          style: SoloLevelingTypography.statNumber.copyWith(
            fontSize: 28,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.difficulty.toUpperCase(),
          style: SoloLevelingTypography.systemText.copyWith(
            fontSize: 12,
            color: textColor.withOpacity(0.7),
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildHUD(double timeProgress) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dungeon Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SoloLevelingColors.cardSurface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SoloLevelingColors.panelBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DUNGEON MODE',
                  style: SoloLevelingTypography.systemText.copyWith(
                    fontSize: 12,
                    color: SoloLevelingColors.textSecondary,
                  ),
                ),
                Text(
                  '${_completedTasks}/${widget.tasks.length} TASKS',
                  style: SoloLevelingTypography.systemText.copyWith(
                    fontSize: 16,
                    color: _completedTasks == widget.tasks.length
                      ? SoloLevelingColors.successGlow
                      : SoloLevelingColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Progress indicator
          Container(
            width: 100,
            height: 6,
            decoration: BoxDecoration(
              color: SoloLevelingColors.panelBorder,
              borderRadius: BorderRadius.circular(3),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: constraints.maxWidth * timeProgress,
                  decoration: BoxDecoration(
                    gradient: _getProgressGradient(timeProgress),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 150,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SoloLevelingColors.cardSurface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SoloLevelingColors.panelBorder.withOpacity(0.5)),
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.tasks.length,
          itemBuilder: (context, index) {
            return _DungeonTaskCard(
              task: widget.tasks[index],
              isCompleted: _taskCompletionStates[index],
              onTap: () => _toggleTaskCompletion(index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (!_isCompleted)
            ElevatedButton(
              onPressed: _isPaused ? _resumeDungeon : _pauseDungeon,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPaused 
                  ? SoloLevelingColors.successGlow 
                  : SoloLevelingColors.warningPulse,
                foregroundColor: SoloLevelingColors.absoluteBlack,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(_isPaused ? 'RESUME' : 'PAUSE'),
            ),
          
          ElevatedButton(
            onPressed: _exitDungeon,
            style: ElevatedButton.styleFrom(
              backgroundColor: SoloLevelingColors.crimsonRed,
              foregroundColor: SoloLevelingColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ABORT MISSION'),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalPhaseOverlay() {
    return Container(
      color: SoloLevelingColors.crimsonRed.withOpacity(0.3),
      child: const Center(
        child: Text(
          'CRITICAL PHASE - COMPLETE IMMEDIATELY',
          style: TextStyle(
            color: SoloLevelingColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pause,
              size: 80,
              color: SoloLevelingColors.textPrimary,
            ),
            SizedBox(height: 20),
            Text(
              'DUNGEON PAUSED',
              style: TextStyle(
                color: SoloLevelingColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getRuneColor(double progress) {
    if (_isFailed) return SoloLevelingColors.dangerFlash;
    if (progress > 0.8) return SoloLevelingColors.warningPulse;
    if (progress > 0.5) return SoloLevelingColors.electricBlue;
    return SoloLevelingColors.textSecondary;
  }

  List<BoxShadow> _getRuneShadows(double progress) {
    if (_isFailed) {
      return SoloLevelingShadows.auraEffect(SoloLevelingColors.crimsonRed, intensity: 1.2);
    }
    
    Color glowColor = progress > 0.8 
      ? SoloLevelingColors.warningPulse 
      : SoloLevelingColors.electricBlue;
      
    return SoloLevelingShadows.cardGlow(glowColor, blur: 20);
  }

  Color _getTextColor(double progress) {
    if (_isFailed) return SoloLevelingColors.dangerFlash;
    if (progress > 0.8) return SoloLevelingColors.warningPulse;
    return SoloLevelingColors.textPrimary;
  }

  Gradient _getProgressGradient(double progress) {
    if (progress > 0.8) {
      return const LinearGradient(
        colors: [SoloLevelingColors.dangerFlash, SoloLevelingColors.crimsonRed],
      );
    } else if (progress > 0.5) {
      return const LinearGradient(
        colors: [SoloLevelingColors.warningPulse, SoloLevelingColors.amberGold],
      );
    } else {
      return SoloLevelingGradients.acceptQuest;
    }
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    _timerController.dispose();
    _ambientController.dispose();
    _runeController.dispose();
    super.dispose();
  }
}

// Supporting Widgets
class _DungeonAmbientPainter extends CustomPainter {
  final double timeProgress;
  final double floatAnimation;
  final String difficulty;

  _DungeonAmbientPainter({
    required this.timeProgress,
    required this.floatAnimation,
    required this.difficulty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw ambient particles
    final particlePaint = Paint()
      ..color = _getParticleColor().withOpacity(0.3 * (1.0 - timeProgress));
    
    for (int i = 0; i < 25; i++) {
      final x = (i * 43 + floatAnimation * 100) % size.width;
      final y = (i * 31 + floatAnimation * 80) % size.height;
      final radius = 1 + (i % 3);
      
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
    
    // Draw energy waves
    final wavePaint = Paint()
      ..color = _getWaveColor().withOpacity(0.1 * (1.0 - timeProgress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i < 5; i++) {
      final radius = 50 + (i * 30) + (floatAnimation * 20);
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        wavePaint,
      );
    }
  }

  Color _getParticleColor() {
    switch (difficulty) {
      case 'hell': return SoloLevelingColors.crimsonRed;
      case 'hard': return SoloLevelingColors.amberGold;
      default: return SoloLevelingColors.electricBlue;
    }
  }

  Color _getWaveColor() {
    switch (difficulty) {
      case 'hell': return SoloLevelingColors.dangerFlash;
      case 'hard': return SoloLevelingColors.warningPulse;
      default: return SoloLevelingColors.indigoGlow;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RuneSegmentPainter extends CustomPainter {
  final double progress;
  final bool isCritical;

  _RuneSegmentPainter({required this.progress, required this.isCritical});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    // Draw segment arcs
    final segmentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    
    // Background circle
    segmentPaint.color = SoloLevelingColors.panelBorder.withOpacity(0.3);
    canvas.drawCircle(center, radius, segmentPaint);
    
    // Progress arc
    segmentPaint.shader = _getProgressGradient().createShader(
      Rect.fromCircle(center: center, radius: radius),
    );
    
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      segmentPaint,
    );
    
    // Critical phase effects
    if (isCritical) {
      final criticalPaint = Paint()
        ..color = SoloLevelingColors.dangerFlash.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawCircle(center, radius + 5, criticalPaint);
    }
  }

  Gradient _getProgressGradient() {
    if (progress > 0.8) {
      return const LinearGradient(
        colors: [SoloLevelingColors.dangerFlash, SoloLevelingColors.crimsonRed],
      );
    } else {
      return SoloLevelingGradients.powerField;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _DungeonTaskCard extends StatelessWidget {
  final LoggedTask task;
  final bool isCompleted;
  final VoidCallback onTap;

  const _DungeonTaskCard({
    required this.task,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
            ? SoloLevelingColors.successGlow.withOpacity(0.2)
            : SoloLevelingColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
              ? SoloLevelingColors.successGlow
              : SoloLevelingColors.panelBorder,
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 16,
                  color: isCompleted 
                    ? SoloLevelingColors.successGlow 
                    : SoloLevelingColors.textSecondary,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(task.difficulty).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.difficulty.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: _getDifficultyColor(task.difficulty),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.name,
              style: SoloLevelingTypography.systemText.copyWith(
                fontSize: 10,
                color: isCompleted 
                  ? SoloLevelingColors.textSecondary 
                  : SoloLevelingColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '+${task.xpReward} XP',
              style: SoloLevelingTypography.systemText.copyWith(
                fontSize: 8,
                color: SoloLevelingColors.electricBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy': return SoloLevelingColors.successGlow;
      case 'normal': return SoloLevelingColors.textSecondary;
      case 'hard': return SoloLevelingColors.warningPulse;
      case 'very_hard': return SoloLevelingColors.crimsonRed;
      default: return SoloLevelingColors.textSecondary;
    }
  }
}

class _DungeonCompletionSheet extends StatelessWidget {
  final bool isSuccess;
  final int bonusXP;
  final int completedTasks;
  final int totalTasks;
  final VoidCallback onReturn;

  const _DungeonCompletionSheet({
    required this.isSuccess,
    required this.bonusXP,
    required this.completedTasks,
    required this.totalTasks,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SoloLevelingColors.cardSurface,
            SoloLevelingColors.slateGray,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: SoloLevelingColors.panelBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Result icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSuccess 
                  ? SoloLevelingColors.successGlow.withOpacity(0.2) 
                  : SoloLevelingColors.crimsonRed.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSuccess 
                    ? SoloLevelingColors.successGlow 
                    : SoloLevelingColors.crimsonRed,
                  width: 3,
                ),
              ),
              child: Icon(
                isSuccess ? Icons.check : Icons.close,
                size: 50,
                color: isSuccess 
                  ? SoloLevelingColors.successGlow 
                  : SoloLevelingColors.crimsonRed,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Result text
            Text(
              isSuccess ? 'DUNGEON CLEARED' : 'MISSION FAILED',
              style: SoloLevelingTypography.systemTitle.copyWith(
                fontSize: 24,
                color: isSuccess 
                  ? SoloLevelingColors.successGlow 
                  : SoloLevelingColors.crimsonRed,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SoloLevelingColors.cardSurface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _StatRow(
                    label: 'TASKS COMPLETED',
                    value: '$completedTasks/$totalTasks',
                    color: completedTasks == totalTasks 
                      ? SoloLevelingColors.successGlow 
                      : SoloLevelingColors.textPrimary,
                  ),
                  if (bonusXP > 0) ...[
                    const SizedBox(height: 8),
                    _StatRow(
                      label: 'BONUS XP',
                      value: '+$bonusXP',
                      color: SoloLevelingColors.electricBlue,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Return button
            ElevatedButton(
              onPressed: onReturn,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess 
                  ? SoloLevelingColors.successGlow 
                  : SoloLevelingColors.crimsonRed,
                foregroundColor: SoloLevelingColors.absoluteBlack,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isSuccess ? 'CLAIM REWARDS' : 'RETURN'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: SoloLevelingTypography.systemText.copyWith(
            fontSize: 14,
            color: SoloLevelingColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: SoloLevelingTypography.systemText.copyWith(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}