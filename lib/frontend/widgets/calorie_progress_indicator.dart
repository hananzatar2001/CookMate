import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants.dart';

class CalorieProgressIndicator extends StatelessWidget {
  final int consumedCalories;
  final int totalCalories;
  final Color progressColor;
  final Color backgroundColor;

  const CalorieProgressIndicator({
    super.key,
    required this.consumedCalories,
    required this.totalCalories,
    this.progressColor = const Color(0xFFF47458),
    this.backgroundColor = const Color(0xFFFDEDE9),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(220, 220),
            painter: CircularCalorieProgressPainter(
              progress:
                  totalCalories > 0 ? consumedCalories / totalCalories : 0,
              primaryColor: progressColor,
              secondaryColor: backgroundColor,
            ),
          ),

          Positioned(
            top: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 32,
                  color: progressColor,
                ),
                const SizedBox(height: 8),

                Text(
                  '$consumedCalories Kcal',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                Text(
                  'of $totalCalories kcal',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircularCalorieProgressPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  CircularCalorieProgressPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;

    const startAngle = math.pi;
    const totalAngle = math.pi;

    final backgroundPaint =
        Paint()
          ..strokeWidth = 25
          ..color = secondaryColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalAngle,
      false,
      backgroundPaint,
    );

    final progressPaint =
        Paint()
          ..strokeWidth = 25
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalAngle * progress,
      false,
      progressPaint,
    );

    if (progress > 0) {
      final angle = startAngle + (totalAngle * progress);
      final dotX = center.dx + radius * math.cos(angle);
      final dotY = center.dy + radius * math.sin(angle);

      final dotPaint =
          Paint()
            ..color = primaryColor
            ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), 12, dotPaint);

      final innerDotPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), 6, innerDotPaint);
    }
  }

  @override
  bool shouldRepaint(CircularCalorieProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
