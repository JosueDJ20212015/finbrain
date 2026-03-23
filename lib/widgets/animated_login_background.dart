import 'package:flutter/material.dart';

class AnimatedLoginBackground extends StatelessWidget {
  final double glowStrength;
  final double dotScale;

  const AnimatedLoginBackground({
    super.key,
    required this.glowStrength,
    required this.dotScale,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF131A24),
                Color(0xFF101722),
                Color(0xFF0E141D),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: CustomPaint(
            size: Size(screenWidth, screenHeight * 0.28),
            painter: BottomIslandPainter(
              glowStrength: glowStrength,
            ),
          ),
        ),
        Positioned(
          right: 32,
          bottom: screenHeight * 0.23,
          child: Transform.scale(
            scale: dotScale,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8FE9DD),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF2DD4BF,
                    ).withOpacity(0.25 + (0.35 * glowStrength)),
                    blurRadius: 10 + (10 * glowStrength),
                    spreadRadius: 1 + (2 * glowStrength),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BottomIslandPainter extends CustomPainter {
  final double glowStrength;

  BottomIslandPainter({
    required this.glowStrength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPath = Path();

    fillPath.moveTo(0, size.height * 0.55);

    fillPath.quadraticBezierTo(
      size.width * 0.12,
      size.height * 0.50,
      size.width * 0.22,
      size.height * 0.62,
    );

    fillPath.cubicTo(
      size.width * 0.38,
      size.height * 0.82,
      size.width * 0.45,
      size.height * 0.18,
      size.width * 0.72,
      size.height * 0.16,
    );

    fillPath.quadraticBezierTo(
      size.width * 0.90,
      size.height * 0.14,
      size.width,
      size.height * 0.14,
    );

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2BA99B),
          Color(0xFF1F7E78),
          Color(0xFF123C42),
        ],
      ).createShader(rect);

    canvas.drawPath(fillPath, fillPaint);

    final strokePath = Path();

    strokePath.moveTo(0, size.height * 0.55);

    strokePath.quadraticBezierTo(
      size.width * 0.12,
      size.height * 0.50,
      size.width * 0.22,
      size.height * 0.62,
    );

    strokePath.cubicTo(
      size.width * 0.38,
      size.height * 0.82,
      size.width * 0.45,
      size.height * 0.18,
      size.width * 0.72,
      size.height * 0.16,
    );

    strokePath.quadraticBezierTo(
      size.width * 0.90,
      size.height * 0.14,
      size.width,
      size.height * 0.14,
    );

    final glowPaint = Paint()
      ..color = const Color(0xFF38E0D0).withOpacity(0.18 * glowStrength)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final strokePaint = Paint()
      ..color =
          Color.lerp(
            const Color(0xFF2CCFC0),
            const Color(0xFF7CF7EC),
            glowStrength,
          ) ??
          const Color(0xFF38E0D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(strokePath, glowPaint);
    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant BottomIslandPainter oldDelegate) {
    return oldDelegate.glowStrength != glowStrength;
  }
}