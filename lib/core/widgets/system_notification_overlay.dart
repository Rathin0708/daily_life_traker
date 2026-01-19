import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SystemNotificationOverlay extends StatefulWidget {
  final String message;
  final String type; // 'info', 'warning', 'success', 'danger'
  final Duration duration;
  final bool showTypewriterEffect;

  const SystemNotificationOverlay({
    Key? key,
    required this.message,
    this.type = 'info',
    this.duration = const Duration(seconds: 4),
    this.showTypewriterEffect = true,
  }) : super(key: key);

  @override
  _SystemNotificationOverlayState createState() => _SystemNotificationOverlayState();
}

class _SystemNotificationOverlayState extends State<SystemNotificationOverlay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late String _displayedMessage;
  late bool _isAnimating;

  @override
  void initState() {
    super.initState();
    _displayedMessage = '';
    _isAnimating = widget.showTypewriterEffect;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Handle typewriter effect
    if (widget.showTypewriterEffect) {
      _startTypewriterEffect();
    } else {
      _displayedMessage = widget.message;
    }

    // Auto-dismiss
    Future.delayed(widget.duration).then((_) {
      if (mounted) {
        _animationController.reverse().then((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  void _startTypewriterEffect() {
    int charIndex = 0;
    const delay = Duration(milliseconds: 30);

    Timer.periodic(delay, (timer) {
      if (charIndex < widget.message.length) {
        setState(() {
          _displayedMessage = widget.message.substring(0, charIndex + 1);
        });
        charIndex++;
      } else {
        timer.cancel();
        _isAnimating = false;
      }
    });
  }

  Color _getBorderColor() {
    switch (widget.type) {
      case 'success': return Colors.green.shade400;
      case 'warning': return Colors.orange.shade400;
      case 'danger': return Colors.red.shade400;
      default: return Colors.blue.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        alignment: Alignment.topCenter,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.only(top: 100),
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: AppColors.cardBg.withOpacity(0.95),
              border: Border.all(
                color: _getBorderColor(),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _getBorderColor().withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getBorderColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '[SYSTEM]',
                    style: TextStyle(
                      color: _getBorderColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _displayedMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'monospace',
                  ),
                ),
                if (_isAnimating)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// Global function to show system notifications
void showSystemNotification(BuildContext context, String message, 
    {String type = 'info', Duration duration = const Duration(seconds: 4)}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return SystemNotificationOverlay(
        message: message,
        type: type,
        duration: duration,
      );
    },
  );
}