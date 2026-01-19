import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/solo_leveling_theme.dart';

class XPBar extends StatefulWidget {
  final double currentXP;
  final double maxXp;
  final int currentLevel;
  final Duration? levelUpDuration;
  final VoidCallback? onLevelUp;

  const XPBar({
    Key? key,
    required this.currentXP,
    required this.maxXp,
    required this.currentLevel,
    this.levelUpDuration = const Duration(milliseconds: 2000),
    this.onLevelUp,
  }) : super(key: key);

  @override
  State<XPBar> createState() => _XPBarState();
}

class _XPBarState extends State<XPBar> with SingleTickerProviderStateMixin {
  late AnimationController _levelUpController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _energyAnimation;
  bool _isLevelingUp = false;
  int _displayLevel = 0;

  @override
  void initState() {
    super.initState();
    _displayLevel = widget.currentLevel;
    
    _levelUpController = AnimationController(
      duration: widget.levelUpDuration ?? const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _levelUpController,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );
    
    _energyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _levelUpController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant XPBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if level up occurred
    if (widget.currentLevel > oldWidget.currentLevel) {
      _triggerLevelUp();
    }
  }

  void _triggerLevelUp() {
    setState(() {
      _isLevelingUp = true;
      _displayLevel = widget.currentLevel;
    });
    
    _levelUpController.forward().then((_) {
      setState(() {
        _isLevelingUp = false;
      });
      _levelUpController.reset();
      
      // Callback for level up completion
      widget.onLevelUp?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.currentXP / widget.maxXp).clamp(0.0, 1.0);
    
    return AnimatedBuilder(
      animation: _levelUpController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isLevelingUp ? _pulseAnimation.value : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Level Display
              _buildLevelDisplay(),
              
              const SizedBox(height: 8),
              
              // XP Bar Container
              Container(
                width: 300,
                height: 24,
                decoration: BoxDecoration(
                  color: SoloLevelingColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: SoloLevelingColors.panelBorder,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    
                    // Progress Fill
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: constraints.maxWidth * progress,
                          decoration: BoxDecoration(
                            gradient: _getXPFillGradient(progress),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _isLevelingUp
                              ? SoloLevelingShadows.auraEffect(
                                  SoloLevelingColors.purpleEnergy,
                                  intensity: _energyAnimation.value,
                                )
                              : SoloLevelingShadows.cardGlow(
                                  _getProgressColor(progress),
                                  blur: 10,
                                ),
                          ),
                        );
                      },
                    ),
                    
                    // Energy Particles (during level up)
                    if (_isLevelingUp)
                      _EnergyParticles(animation: _energyAnimation),
                    
                    // Progress Text
                    Center(
                      child: Text(
                        '${widget.currentXP.round()}/${widget.maxXp.round()} XP',
                        style: SoloLevelingTypography.systemText.copyWith(
                          fontSize: 12,
                          color: SoloLevelingColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Level Up Indicator
              if (_isLevelingUp)
                _buildLevelUpIndicator(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: SoloLevelingGradients.powerField,
        borderRadius: BorderRadius.circular(20),
        boxShadow: SoloLevelingShadows.cardGlow(SoloLevelingColors.electricBlue),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            size: 16,
            color: SoloLevelingColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            'LEVEL $_displayLevel',
            style: SoloLevelingTypography.systemText.copyWith(
              color: SoloLevelingColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelUpIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: SoloLevelingGradients.dangerZone,
        borderRadius: BorderRadius.circular(12),
        boxShadow: SoloLevelingShadows.auraEffect(SoloLevelingColors.purpleEnergy),
      ),
      child: Text(
        'LEVEL UP!',
        style: SoloLevelingTypography.systemText.copyWith(
          color: SoloLevelingColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Gradient _getXPFillGradient(double progress) {
    if (progress >= 0.95) {
      // Near level up - intense purple energy
      return const LinearGradient(
        colors: [SoloLevelingColors.purpleEnergy, SoloLevelingColors.amberGold],
      );
    } else if (progress >= 0.7) {
      // Mid progress - blue to purple
      return SoloLevelingGradients.powerField;
    } else {
      // Early progress - blue tones
      return const LinearGradient(
        colors: [SoloLevelingColors.electricBlue, SoloLevelingColors.indigoGlow],
      );
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.95) return SoloLevelingColors.purpleEnergy;
    if (progress >= 0.7) return SoloLevelingColors.electricBlue;
    return SoloLevelingColors.indigoGlow;
  }

  @override
  void dispose() {
    _levelUpController.dispose();
    super.dispose();
  }
}

class _EnergyParticles extends StatelessWidget {
  final Animation<double> animation;

  const _EnergyParticles({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _EnergyParticlePainter(animationValue: animation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _EnergyParticlePainter extends CustomPainter {
  final double animationValue;

  _EnergyParticlePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SoloLevelingColors.purpleEnergy.withOpacity(0.6 * animationValue)
      ..strokeWidth = 2;
    
    // Draw energy bursts
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + (animationValue * pi);
      final radius = 30 * animationValue;
      final centerX = size.width / 2;
      final centerY = size.height / 2;
      
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      
      canvas.drawCircle(Offset(x, y), 3, paint);
      
      // Add glow effect
      final glowPaint = Paint()
        ..color = SoloLevelingColors.amberGold.withOpacity(0.3 * animationValue)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(Offset(x, y), 6, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LevelUpAnimation extends StatefulWidget {
  final int newLevel;
  final VoidCallback onCompleted;

  const LevelUpAnimation({
    Key? key,
    required this.newLevel,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<LevelUpAnimation> createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<LevelUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _energyAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );
    
    _energyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start animation sequence
    _startAnimation();
  }

  void _startAnimation() async {
    await _controller.forward();
    
    // Hold for dramatic effect
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      Navigator.of(context).pop();
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Stack(
        children: [
          // Energy Field Background
          AnimatedBuilder(
            animation: _energyAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: _LevelUpBackgroundPainter(
                  animationValue: _energyAnimation.value,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // Main Level Up Content
          Center(
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Energy Cracks Effect
                    _EnergyCracks(animation: _energyAnimation),
                    
                    const SizedBox(height: 40),
                    
                    // Level Display
                    _buildLevelDisplay(),
                    
                    const SizedBox(height: 20),
                    
                    // Power Surge Text
                    _buildPowerSurgeText(),
                    
                    const SizedBox(height: 40),
                    
                    // Stats Increase Preview
                    _buildStatsPreview(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelDisplay() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SoloLevelingGradients.bossAura,
        boxShadow: SoloLevelingShadows.auraEffect(SoloLevelingColors.purpleEnergy, intensity: 1.5),
      ),
      child: Column(
        children: [
          Text(
            'LEVEL',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 16,
              color: SoloLevelingColors.textSecondary,
            ),
          ),
          Text(
            '${widget.newLevel}',
            style: SoloLevelingTypography.rankDisplay.copyWith(
              fontSize: 72,
              color: SoloLevelingColors.amberGold,
              shadows: [
                Shadow(
                  color: SoloLevelingColors.amberGold,
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerSurgeText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: SoloLevelingColors.cardSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SoloLevelingColors.purpleEnergy.withOpacity(0.5),
        ),
      ),
      child: Text(
        'POWER SURGE DETECTED',
        style: SoloLevelingTypography.systemText.copyWith(
          fontSize: 18,
          color: SoloLevelingColors.purpleEnergy,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildStatsPreview() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SoloLevelingColors.cardSurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SoloLevelingColors.panelBorder.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'ABILITY ENHANCEMENT',
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 14,
              color: SoloLevelingColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Sample stat increases (would be dynamic in real implementation)
          _StatIncreaseRow(stat: 'STRENGTH', increase: '+2'),
          _StatIncreaseRow(stat: 'WILLPOWER', increase: '+3'),
          _StatIncreaseRow(stat: 'DISCIPLINE', increase: '+1'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _EnergyCracks extends StatelessWidget {
  final Animation<double> animation;

  const _EnergyCracks({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _EnergyCrackPainter(animationValue: animation.value),
          size: const Size(200, 200),
        );
      },
    );
  }
}

class _EnergyCrackPainter extends CustomPainter {
  final double animationValue;

  _EnergyCrackPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SoloLevelingColors.purpleEnergy.withOpacity(animationValue)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw crack lines radiating outward
    for (int i = 0; i < 12; i++) {
      final angle = (i * pi / 6);
      final maxLength = 80 * animationValue;
      final startX = center.dx + 20 * cos(angle);
      final startY = center.dy + 20 * sin(angle);
      final endX = center.dx + maxLength * cos(angle);
      final endY = center.dy + maxLength * sin(angle);
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      
      // Add glow to crack tips
      if (animationValue > 0.7) {
        final tipPaint = Paint()
          ..color = SoloLevelingColors.amberGold.withOpacity(0.8 * animationValue)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(Offset(endX, endY), 5, tipPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LevelUpBackgroundPainter extends CustomPainter {
  final double animationValue;

  _LevelUpBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          SoloLevelingColors.purpleEnergy.withOpacity(0.3 * animationValue),
          SoloLevelingColors.amberGold.withOpacity(0.1 * animationValue),
          Colors.transparent,
        ],
        center: Alignment.center,
        radius: 0.8,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Add particle effects
    final particlePaint = Paint()
      ..color = SoloLevelingColors.particleCore.withOpacity(0.4 * animationValue);
    
    for (int i = 0; i < 30; i++) {
      final x = (i * 41 + animationValue * 200) % size.width;
      final y = (i * 29 + animationValue * 150) % size.height;
      canvas.drawCircle(Offset(x, y), 1 + (i % 3), particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StatIncreaseRow extends StatelessWidget {
  final String stat;
  final String increase;

  const _StatIncreaseRow({required this.stat, required this.increase});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: SoloLevelingGradients.acceptQuest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              increase,
              style: SoloLevelingTypography.systemText.copyWith(
                fontSize: 14,
                color: SoloLevelingColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}