import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/solo_leveling_theme.dart';
import '../utils/hunter_stats_calculator.dart';

class PenaltyZoneOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onExitPenalty;

  const PenaltyZoneOverlay({
    Key? key,
    required this.child,
    this.onExitPenalty,
  }) : super(key: key);

  @override
  State<PenaltyZoneOverlay> createState() => _PenaltyZoneOverlayState();
}

class _PenaltyZoneOverlayState extends State<PenaltyZoneOverlay>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late AnimationController _veilController;
  late Animation<double> _heartbeatAnimation;
  late Animation<double> _veilOpacityAnimation;
  late Animation<Color?> _veilColorAnimation;
  
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    
    // Heartbeat animation controller
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Veil transition controller
    _veilController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Heartbeat pulse animation
    _heartbeatAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _heartbeatController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Veil opacity animation
    _veilOpacityAnimation = Tween<double>(begin: 0.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _veilController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Veil color transition
    _veilColorAnimation = ColorTween(
      begin: SoloLevelingColors.absoluteBlack.withOpacity(0),
      end: const Color(0xFF1A0000), // Deep crimson veil
    ).animate(
      CurvedAnimation(
        parent: _veilController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start animations
    _startPenaltyAnimations();
  }

  void _startPenaltyAnimations() {
    // Start veil fade in
    _veilController.forward();
    
    // Start continuous heartbeat
    _startHeartbeat();
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (mounted) {
        _heartbeatController
          ..reset()
          ..forward();
      } else {
        timer.cancel();
      }
    });
    
    // Initial heartbeat
    _heartbeatController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content with penalty effects
        AnimatedBuilder(
          animation: Listenable.merge([
            _heartbeatController,
            _veilController,
          ]),
          builder: (context, child) {
            return ColorFiltered(
              colorFilter: ColorFilter.mode(
                _veilColorAnimation.value ?? Colors.transparent,
                BlendMode.modulate,
              ),
              child: Transform.scale(
                scale: _heartbeatAnimation.value,
                child: widget.child,
              ),
            );
          },
        ),
        
        // Penalty Veil Overlay
        _buildPenaltyVeil(),
        
        // Warning Elements
        _buildWarningElements(),
        
        // Atmospheric Particles
        _buildAtmosphericEffects(),
      ],
    );
  }

  Widget _buildPenaltyVeil() {
    return AnimatedBuilder(
      animation: _veilOpacityAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.transparent,
                SoloLevelingColors.crimsonRed.withOpacity(_veilOpacityAnimation.value * 0.3),
                const Color(0xFF2D0000).withOpacity(_veilOpacityAnimation.value * 0.7),
              ],
              center: const Alignment(0.0, -0.3),
              radius: 1.2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWarningElements() {
    return Positioned(
      top: 100,
      left: 20,
      child: AnimatedBuilder(
        animation: _heartbeatController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_heartbeatController.value * 0.1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: SoloLevelingColors.crimsonRed.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: SoloLevelingColors.dangerFlash,
                  width: 2,
                ),
                boxShadow: SoloLevelingShadows.auraEffect(
                  SoloLevelingColors.crimsonRed,
                  intensity: 0.8 + (_heartbeatController.value * 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: SoloLevelingColors.textPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PENALTY ZONE',
                    style: SoloLevelingTypography.systemText.copyWith(
                      color: SoloLevelingColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAtmosphericEffects() {
    return AnimatedBuilder(
      animation: _veilController,
      builder: (context, child) {
        return CustomPaint(
          painter: _PenaltyAtmospherePainter(
            veilIntensity: _veilController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _heartbeatController.dispose();
    _veilController.dispose();
    super.dispose();
  }
}

class _PenaltyAtmospherePainter extends CustomPainter {
  final double veilIntensity;

  _PenaltyAtmospherePainter({required this.veilIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    if (veilIntensity <= 0) return;

    // Draw blood-like particles
    final particlePaint = Paint()
      ..color = SoloLevelingColors.crimsonRed.withOpacity(0.3 * veilIntensity);
    
    for (int i = 0; i < (20 * veilIntensity).toInt(); i++) {
      final x = (i * 37.0) % size.width;
      final y = (i * 23.0 + DateTime.now().millisecondsSinceEpoch * 0.01) % size.height;
      
      // Vary particle sizes
      final radius = 1 + (i % 4);
      canvas.drawCircle(Offset(x, y), radius as double, particlePaint);
    }

    // Draw crack effects
    final crackPaint = Paint()
      ..color = SoloLevelingColors.dangerFlash.withOpacity(0.4 * veilIntensity)
      ..strokeWidth = 1;
    
    for (int i = 0; i < (8 * veilIntensity).toInt(); i++) {
      final startX = (i * 53.0) % size.width;
      final startY = (i * 41.0) % size.height;
      final endX = startX + 30 + (i % 20);
      final endY = startY + 20 - (i % 15);
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), crackPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PenaltyActivationDialog extends StatefulWidget {
  final String reason;
  final int requiredTasks;
  final VoidCallback onAcknowledge;

  const PenaltyActivationDialog({
    Key? key,
    required this.reason,
    required this.requiredTasks,
    required this.onAcknowledge,
  }) : super(key: key);

  @override
  State<PenaltyActivationDialog> createState() => _PenaltyActivationDialogState();
}

class _PenaltyActivationDialogState extends State<PenaltyActivationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: SoloLevelingGradients.penaltyVeil,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: SoloLevelingColors.crimsonRed,
                    width: 3,
                  ),
                  boxShadow: SoloLevelingShadows.auraEffect(
                    SoloLevelingColors.crimsonRed,
                    intensity: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: SoloLevelingColors.crimsonRed.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SoloLevelingColors.dangerFlash,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.warning_amber,
                        size: 50,
                        color: SoloLevelingColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      'PENALTY ZONE ACTIVATED',
                      style: SoloLevelingTypography.systemTitle.copyWith(
                        fontSize: 20,
                        color: SoloLevelingColors.dangerFlash,
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Reason
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SoloLevelingColors.cardSurface.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: SoloLevelingColors.panelBorder.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        widget.reason,
                        style: SoloLevelingTypography.systemText.copyWith(
                          fontSize: 16,
                          color: SoloLevelingColors.textPrimary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Requirements
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            SoloLevelingColors.dangerFlash.withOpacity(0.2),
                            SoloLevelingColors.crimsonRed.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: SoloLevelingColors.dangerFlash.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'ESCAPE CONDITIONS:',
                            style: SoloLevelingTypography.systemText.copyWith(
                              fontSize: 12,
                              color: SoloLevelingColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete ${widget.requiredTasks} additional missions',
                            style: SoloLevelingTypography.systemText.copyWith(
                              fontSize: 16,
                              color: SoloLevelingColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Acknowledge Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onAcknowledge();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SoloLevelingColors.dangerFlash,
                        foregroundColor: SoloLevelingColors.textPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('ACKNOWLEDGE'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class PenaltyExitAnimation extends StatefulWidget {
  final VoidCallback onCompleted;

  const PenaltyExitAnimation({Key? key, required this.onCompleted})
      : super(key: key);

  @override
  State<PenaltyExitAnimation> createState() => _PenaltyExitAnimationState();
}

class _PenaltyExitAnimationState extends State<PenaltyExitAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _veilOpacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _veilOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    _startExitSequence();
  }

  void _startExitSequence() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      await _controller.forward();
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Dissolving veil
              Opacity(
                opacity: _veilOpacityAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: SoloLevelingGradients.penaltyVeil,
                  ),
                ),
              ),
              
              // Center message
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 80,
                        color: SoloLevelingColors.successGlow.withOpacity(
                          1.0 - _controller.value,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'PENALTY ZONE CLEARED',
                        style: SoloLevelingTypography.systemTitle.copyWith(
                          fontSize: 24,
                          color: SoloLevelingColors.successGlow.withOpacity(
                            1.0 - _controller.value,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Discipline restored',
                        style: SoloLevelingTypography.systemText.copyWith(
                          fontSize: 16,
                          color: SoloLevelingColors.textSecondary.withOpacity(
                            1.0 - _controller.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}