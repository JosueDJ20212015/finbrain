import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/category_expense_model.dart';
import '../utils/app_colors.dart';

class CategoryOverviewRing extends StatelessWidget {
  final List<CategoryExpenseModel> items;
  final ValueChanged<CategoryExpenseModel> onCategoryTap;

  const CategoryOverviewRing({
    super.key,
    required this.items,
    required this.onCategoryTap,
  });

  double get totalAmount {
    return items.fold<double>(0, (sum, item) => sum + item.amount);
  }

  String formatMoney(double value) {
    return 'Lps ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(8).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 360.0);
        final centerSize = size * 0.50;
        final orbitRadius = size * 0.38;
        final itemCount = visibleItems.length;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(items: visibleItems),
              ),
              Container(
                width: centerSize,
                height: centerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card.withOpacity(0.94),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 22,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Gastos',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatMoney(totalAmount),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${visibleItems.length} categorías',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.48),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ...List.generate(itemCount, (index) {
                final category = visibleItems[index];
                final angle = (-math.pi / 2) + ((2 * math.pi / itemCount) * index);
                final dx = orbitRadius * math.cos(angle);
                final dy = orbitRadius * math.sin(angle);

                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: _CategoryOrbitItem(
                    category: category,
                    onTap: () => onCategoryTap(category),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryOrbitItem extends StatelessWidget {
  final CategoryExpenseModel category;
  final VoidCallback onTap;

  const _CategoryOrbitItem({
    required this.category,
    required this.onTap,
  });

  IconData get icon {
    final name = category.name.toLowerCase();

    if (name.contains('comida') || name.contains('restaurante')) {
      return Icons.restaurant_rounded;
    }
    if (name.contains('transporte')) {
      return Icons.directions_bus_rounded;
    }
    if (name.contains('salud')) {
      return Icons.favorite_rounded;
    }
    if (name.contains('servicios')) {
      return Icons.lightbulb_rounded;
    }
    if (name.contains('educación')) {
      return Icons.school_rounded;
    }
    if (name.contains('entretenimiento')) {
      return Icons.movie_rounded;
    }
    if (name.contains('compras')) {
      return Icons.shopping_bag_rounded;
    }

    return Icons.category_rounded;
  }

  String formatMoney(double value) {
    return 'Lps ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.18),
              border: Border.all(
                color: color.withOpacity(0.28),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.20),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 88,
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 88,
            child: Text(
              formatMoney(category.amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<CategoryExpenseModel> items;

  _RingPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);
    if (items.isEmpty || total <= 0) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.24;
    const strokeWidth = 18.0;

    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, basePaint);

    double startAngle = -math.pi / 2;

    for (final item in items) {
      final sweepAngle = (item.amount / total) * (2 * math.pi);
      final paint = Paint()
        ..color = Color(item.colorValue)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}