import 'package:flutter/material.dart';
import 'dart:math';

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40; // 도넛 차트의 두께

    // 각 섹션별 데이터와 색상
    final sections = [
      PieChartSection(percentage: 25, color: Colors.red),
      PieChartSection(percentage: 30, color: Colors.green),
      PieChartSection(percentage: 15, color: Colors.blue),
      PieChartSection(percentage: 30, color: Colors.orange),
    ];

    double startRadian = -pi / 2;
    for (var section in sections) {
      final sweepRadian = (section.percentage / 100) * 2 * pi;
      paint.color = section.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startRadian,
        sweepRadian,
        false,
        paint,
      );

      startRadian += sweepRadian;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class PieChartSection {
  final double percentage;
  final Color color;

  PieChartSection({required this.percentage, required this.color});
}
