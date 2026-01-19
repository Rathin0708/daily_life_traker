import 'dart:math' as Math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HunterProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final Color color;
  final String rank; // E/D/C/B/A/S/Monarch

  const HunterProgressRing({
    Key? key,
    required this.progress,
    this.size = 160,
    this.color = AppColors.primary,
    this.rank = 'E',
  }) : super(key: key);

  Color _getRankColor(String rank) {
    switch (rank) {
      case 'E': return Colors.grey.shade500;
      case 'D': return Colors.brown.shade400;
      case 'C': return Colors.green.shade400;
      case 'B': return Colors.blue.shade400;
      case 'A': return Colors.orange.shade400;
      case 'S': return Colors.purple.shade400;
      case 'Monarch': return Colors.yellow.shade400;
      default: return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _getRankColor(rank).withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: HunterProgressPainter(
          progress: progress,
          color: _getRankColor(rank),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                rank,
                style: TextStyle(
                  color: _getRankColor(rank),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HunterProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  HunterProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final paintBackground = Paint()
      ..color = AppColors.cardBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paintBackground);

    // Progress arc
    final paintProgress = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0.3),
          color,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final angle = 2 * Math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -Math.pi / 2, // Start from top
      angle,
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}