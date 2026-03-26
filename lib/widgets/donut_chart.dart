import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/category_expense_model.dart';
import '../utils/app_colors.dart';

class DonutChart extends StatelessWidget {
  final List<CategoryExpenseModel> items;

  const DonutChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: CustomPaint(
        painter: DonutChartPainter(items: items),
        child: const Center(
          child: Text(
            'Gastos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<CategoryExpenseModel> items;

  DonutChartPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 16.0;

    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - (strokeWidth / 2), basePaint);

    if (total <= 0) {
      return;
    }

    double startAngle = -math.pi / 2;

    for (final item in items) {
      final sweepAngle = (item.amount / total) * (2 * math.pi);
      final paint = Paint()
        ..color = Color(item.colorValue)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}
