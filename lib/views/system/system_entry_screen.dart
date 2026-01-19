import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/theme/solo_leveling_theme.dart';
import '../auth/auth_wrapper.dart';

class SystemEntryScreen extends StatefulWidget {
  const SystemEntryScreen({super.key});

  @override
  State<SystemEntryScreen> createState() => _SystemEntryScreenState();
}

class _SystemEntryScreenState extends State<SystemEntryScreen> 
    with TickerProviderStateMixin {
  late AnimationController _glitchController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  
  final List<String> _systemMessages = [
    "System Initializing...",
    "Neural Network Online",
    "Identity Verification",
    "Hunter Authentication Complete",
    "Access Granted",
    "Welcome to the System"
  ];
  
  int _currentMessageIndex = 0;
  String _displayText = "";
  bool _isTyping = true;

  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Setup animations
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.elasticOut),
    );
    
    // Start the sequence
    _startInitializationSequence();
  }
  
  void _startInitializationSequence() async {
    // Start glitch effect
    _startGlitchEffect();
    
    // Begin text sequence
    await Future.delayed(const Duration(milliseconds: 500));
    _startTextSequence();
  }
  
  void _startGlitchEffect() {
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      _glitchController.forward().then((_) {
        _glitchController.reset();
      });
    });
  }
  
  void _startTextSequence() async {
    for (int i = 0; i < _systemMessages.length; i++) {
      setState(() {
        _currentMessageIndex = i;
        _isTyping = true;
        _displayText = "";
      });
      
      // Typewriter effect
      await _typeWriterEffect(_systemMessages[i]);
      
      // Pause between messages
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Brief pause on final message
      if (i == _systemMessages.length - 1) {
        await Future.delayed(const Duration(milliseconds: 1500));
        _navigateToMainApp();
      }
    }
  }
  
  Future<void> _typeWriterEffect(String message) async {
    for (int i = 0; i <= message.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _displayText = message.substring(0, i);
      });
      
      await Future.delayed(const Duration(milliseconds: 30));
    }
    
    setState(() {
      _isTyping = false;
    });
  }
  
  void _navigateToMainApp() {
    // Fade out animation
    _textController.reverse().then((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return const AuthWrapper();
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoloLevelingColors.absoluteBlack,
      body: Stack(
        children: [
          // Particle Background
          _buildParticleBackground(),
          
          // Glitch Overlay
          _buildGlitchOverlay(),
          
          // Main Content
          Center(
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // System Logo/Icon
                    _buildSystemLogo(),
                    
                    const SizedBox(height: 40),
                    
                    // Text Display
                    _buildTextDisplay(),
                    
                    const SizedBox(height: 30),
                    
                    // Progress Indicator
                    _buildProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildParticleBackground() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            animationValue: _particleController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
  
  Widget _buildGlitchOverlay() {
    return AnimatedBuilder(
      animation: _glitchController,
      builder: (context, child) {
        if (_glitchController.value > 0.5) {
          return Container(
            color: SoloLevelingColors.crimsonRed.withOpacity(0.1),
            child: Transform.translate(
              offset: Offset(
                5 * (_glitchController.value - 0.5) * 2,
                0,
              ),
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      Colors.transparent,
                      SoloLevelingColors.electricBlue.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ).createShader(bounds);
                },
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
  
  Widget _buildSystemLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SoloLevelingGradients.powerField,
        boxShadow: SoloLevelingShadows.auraEffect(SoloLevelingColors.electricBlue),
      ),
      child: Center(
        child: Icon(
          Icons.circle_outlined,
          size: 60,
          color: SoloLevelingColors.textPrimary,
        ),
      ),
    );
  }
  
  Widget _buildTextDisplay() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SoloLevelingColors.cardSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SoloLevelingColors.panelBorder.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            _displayText,
            style: SoloLevelingTypography.systemText.copyWith(
              fontSize: 18,
              color: _getCurrentTextColor(),
            ),
          ),
          if (_isTyping)
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 8,
              height: 16,
              decoration: BoxDecoration(
                color: SoloLevelingColors.neonCyan,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
  
  Color _getCurrentTextColor() {
    if (_currentMessageIndex < 2) return SoloLevelingColors.textSecondary;
    if (_currentMessageIndex < 4) return SoloLevelingColors.electricBlue;
    return SoloLevelingColors.successGlow;
  }
  
  Widget _buildProgressIndicator() {
    double progress = (_currentMessageIndex + 1) / _systemMessages.length;
    
    return Container(
      width: 200,
      height: 4,
      decoration: BoxDecoration(
        color: SoloLevelingColors.panelBorder,
        borderRadius: BorderRadius.circular(2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: constraints.maxWidth * progress,
            decoration: BoxDecoration(
              gradient: SoloLevelingGradients.acceptQuest,
              borderRadius: BorderRadius.circular(2),
              boxShadow: SoloLevelingShadows.cardGlow(SoloLevelingColors.electricBlue, blur: 8),
            ),
          );
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _glitchController.dispose();
    _textController.dispose();
    _particleController.dispose();

    super.dispose();
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;
  
  ParticlePainter({required this.animationValue});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SoloLevelingColors.particleCore.withOpacity(0.3)
      ..strokeWidth = 1;
    
    // Draw floating particles
    for (int i = 0; i < 20; i++) {
      double x = (i * 37.0 + animationValue * 100) % size.width;
      double y = (i * 23.0 + animationValue * 80) % size.height;
      
      canvas.drawCircle(Offset(x, y), 1 + (i % 3), paint);
      
      // Add glow effect to some particles
      if (i % 5 == 0) {
        final glowPaint = Paint()
          ..color = SoloLevelingColors.particleTrail.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(x, y), 3, glowPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}