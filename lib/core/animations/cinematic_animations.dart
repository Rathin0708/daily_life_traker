import 'package:flutter/material.dart';
import '../theme/solo_leveling_theme.dart';

class CinematicAnimations {
  // Task Completion Animation
  static Widget taskCompletionAnimation({
    required Widget child,
    required bool isCompleted,
    VoidCallback? onCompleted,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(1, 0), end: Offset.zero),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: isCompleted
          ? _TaskCompleteEffect(
              child: child,
              onCompleted: onCompleted,
            )
          : child,
    );
  }

  // XP Orb Animation
  static Widget xpOrbAnimation({
    required int xpAmount,
    required Offset fromPosition,
    required Offset toPosition,
  }) {
    return _XPOrbEffect(
      xpAmount: xpAmount,
      fromPosition: fromPosition,
      toPosition: toPosition,
    );
  }

  // Hover Glow Effect
  static Widget hoverGlowEffect({
    required Widget child,
    required Color glowColor,
    double glowSize = 15,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: AlwaysStoppedAnimation(1.0),
          curve: Curves.easeInOut,
        )),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.3),
                  blurRadius: glowSize,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          );
        },
        child: child,
      ),
    );
  }

  // Pulse Animation
  static Widget pulseAnimation({
    required Widget child,
    Color pulseColor = SoloLevelingColors.electricBlue,
    double minScale = 1.0,
    double maxScale = 1.05,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    return AnimatedBuilder(
      animation: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: AlwaysStoppedAnimation(1.0),
          curve: Curves.easeInOut,
        ),
      ),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: pulseColor.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _TaskCompleteEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onCompleted;

  const _TaskCompleteEffect({
    required this.child,
    this.onCompleted,
  });

  @override
  State<_TaskCompleteEffect> createState() => _TaskCompleteEffectState();
}

class _TaskCompleteEffectState extends State<_TaskCompleteEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _controller.forward().then((_) {
      widget.onCompleted?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
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

class _XPOrbEffect extends StatefulWidget {
  final int xpAmount;
  final Offset fromPosition;
  final Offset toPosition;

  const _XPOrbEffect({
    required this.xpAmount,
    required this.fromPosition,
    required this.toPosition,
  });

  @override
  State<_XPOrbEffect> createState() => _XPOrbEffectState();
}

class _XPOrbEffectState extends State<_XPOrbEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _positionAnimation = Tween<Offset>(
      begin: widget.fromPosition,
      end: widget.toPosition,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.scale(
            scale: 1.0 - _sizeAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SoloLevelingColors.electricBlue.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: SoloLevelingColors.electricBlue.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  '+${widget.xpAmount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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

class MicroInteractions {
  // Button Press Effect
  static Widget buttonPressEffect({
    required Widget child,
    required VoidCallback onPressed,
    Color pressColor = SoloLevelingColors.electricBlue,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        highlightColor: pressColor.withOpacity(0.2),
        splashColor: pressColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }

  // Card Hover Effect
  static Widget cardHoverEffect({
    required Widget child,
    required VoidCallback onTap,
    Color hoverColor = SoloLevelingColors.electricBlue,
    double hoverElevation = 8,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: AlwaysStoppedAnimation(1.0),
          curve: Curves.easeInOut,
        )),
        builder: (context, child) {
          return Card(
            elevation: hoverElevation,
            color: hoverColor.withOpacity(0.1),
            shadowColor: hoverColor.withOpacity(0.3),
            child: InkWell(
              onTap: onTap,
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }

  // Text Glow Effect
  static Widget textGlowEffect({
    required String text,
    required TextStyle style,
    Color glowColor = SoloLevelingColors.electricBlue,
    double glowRadius = 10,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            glowColor,
            glowColor.withOpacity(0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: Text(text, style: style),
    );
  }
}

class SystemNotification {
  static Future<void> show({
    required BuildContext context,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) async {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    
    if (renderBox == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => _SystemNotificationOverlay(
        message: message,
        type: type,
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);
    
    await Future.delayed(duration);
    
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  }
}

enum NotificationType {
  info,
  success,
  warning,
  error,
}

class _SystemNotificationOverlay extends StatefulWidget {
  final String message;
  final NotificationType type;
  final Duration duration;

  const _SystemNotificationOverlay({
    required this.message,
    required this.type,
    required this.duration,
  });

  @override
  State<_SystemNotificationOverlay> createState() =>
      _SystemNotificationOverlayState();
}

class _SystemNotificationOverlayState
    extends State<_SystemNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _controller.forward();
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case NotificationType.success:
        return SoloLevelingColors.successGlow;
      case NotificationType.warning:
        return SoloLevelingColors.warningPulse;
      case NotificationType.error:
        return SoloLevelingColors.crimsonRed;
      default:
        return SoloLevelingColors.neonCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SoloLevelingColors.cardSurface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getTypeColor().withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getTypeColor().withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getTypeColor(),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getIcon(),
                        color: _getTypeColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: SoloLevelingTypography.systemText.copyWith(
                          color: _getTypeColor(),
                          fontSize: 16,
                        ),
                      ),
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

  IconData _getIcon() {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning_amber;
      case NotificationType.error:
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AnimatedBackground {
  static Widget particleField({
    required Widget child,
    Color particleColor = SoloLevelingColors.electricBlue,
    int particleCount = 20,
  }) {
    return Stack(
      children: [
        _ParticleField(
          particleColor: particleColor,
          particleCount: particleCount,
        ),
        child,
      ],
    );
  }
}

class _ParticleField extends StatefulWidget {
  final Color particleColor;
  final int particleCount;

  const _ParticleField({
    required this.particleColor,
    required this.particleCount,
  });

  @override
  State<_ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<_ParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _floatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            floatAnimation: _floatAnimation.value,
            particleColor: widget.particleColor,
            particleCount: widget.particleCount,
          ),
          size: Size.infinite,
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

class _ParticlePainter extends CustomPainter {
  final double floatAnimation;
  final Color particleColor;
  final int particleCount;

  _ParticlePainter({
    required this.floatAnimation,
    required this.particleColor,
    required this.particleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = particleColor.withOpacity(0.3);

    for (int i = 0; i < particleCount; i++) {
      final x = (i * 47.0 + floatAnimation * 100) % size.width;
      final y = (i * 31.0 + floatAnimation * 80) % size.height;
      final radius = 1 + (i % 3);

      canvas.drawCircle(Offset(x, y), radius as double, paint);
      
      // Add glow to some particles
      if (i % 5 == 0) {
        final glowPaint = Paint()
          ..color = particleColor.withOpacity(0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(Offset(x, y), radius * 3, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}