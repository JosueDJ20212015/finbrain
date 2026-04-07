import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class AnalyticsLineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const AnalyticsLineChart({
    super.key,
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _AnalyticsLineChartPainter(values: values),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(labels.length, (index) {
              return Expanded(
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsLineChartPainter extends CustomPainter {
  final List<double> values;

  _AnalyticsLineChartPainter({
    required this.values,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = (maxValue - minValue).abs() < 1
        ? 1.0
        : (maxValue - minValue);

    final chartHeight = size.height - 8;
    final stepX = values.length == 1 ? 0.0 : size.width / (values.length - 1);

    final points = <Offset>[];

    for (var index = 0; index < values.length; index++) {
      final normalized = (values[index] - minValue) / range;
      final x = stepX * index;
      final y = chartHeight - (normalized * chartHeight);
      points.add(Offset(x, y));
    }

    final baselinePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;

    final middleY = size.height / 2;
    canvas.drawLine(
      Offset(0, middleY),
      Offset(size.width, middleY),
      baselinePaint,
    );

    final glowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.20)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.yellow,
          AppColors.cyan,
          AppColors.primary,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final current = points[index];
      final controlX = (previous.dx + current.dx) / 2;

      linePath.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    canvas.drawPath(linePath, glowPaint);
    canvas.drawPath(linePath, linePaint);

    for (final point in points) {
      final dotGlow = Paint()
        ..color = AppColors.primary.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final dotPaint = Paint()..color = AppColors.primarySoft;

      canvas.drawCircle(point, 5, dotGlow);
      canvas.drawCircle(point, 2.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnalyticsLineChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}