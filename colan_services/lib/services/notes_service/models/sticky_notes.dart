// ignore_for_file: cascade_invocations

import 'dart:math' as math;

import 'package:flutter/material.dart';

class StickyNote extends StatelessWidget {
  const StickyNote({
    super.key,
    this.child,
    this.color = const Color(0xffffff00),
  });
  final Widget? child;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.01 * math.pi,
      child: CustomPaint(
        painter: StickyNotePainter(
          color: color,
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}

class StickyNotePainter extends CustomPainter {
  StickyNotePainter({required this.color});

  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Create a path
    final path = Path(); // Move to the top-left corner
    // Draw a line to the bottom-right corner

    final gradientPaint = _createGradientPaint(size);

    path.lineTo(0, 0);
    path.cubicTo(
      0,
      0,
      size.width * 0.01,
      size.height * 0.44,
      size.width * 0.01,
      size.height * 0.44,
    );
    path.cubicTo(
      size.width * 0.01,
      size.height * 0.44,
      size.width * 0.01,
      size.height * 0.56,
      size.width * 0.02,
      size.height * 0.64,
    );
    path.cubicTo(
      size.width * 0.03,
      size.height * 0.72,
      size.width * 0.03,
      size.height * 0.82,
      size.width * 0.06,
      size.height * 0.88,
    );
    path.cubicTo(
      size.width * 0.08,
      size.height * 0.95,
      size.width * 0.09,
      size.height * 0.96,
      size.width * 0.14,
      size.height * 0.97,
    );
    path.cubicTo(
      size.width * 0.51,
      size.height,
      size.width,
      size.height,
      size.width,
      size.height,
    );
    path.cubicTo(size.width, size.height, size.width, 0, size.width, 0);
    path.cubicTo(size.width, 0, 0, 0, 0, 0);
    canvas.drawPath(path, gradientPaint);

    // Draw the path on the canvas
    canvas.drawPath(path, paint);
    _drawShadow(size, canvas);
  }

  Paint _createGradientPaint(Size size) {
    final paint = Paint();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const gradient = RadialGradient(
      colors: [Color(0xffffff00), Color(0xffeeee00)],
      radius: 1,
      stops: [0.5, 1.0],
      center: Alignment.bottomLeft,
    );
    paint.shader = gradient.createShader(rect);
    return paint;
  }

  void _drawShadow(Size size, Canvas canvas) {
    final shadowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..color = Colors.black.withOpacity(0.16);
    final shadowPath = Path();
    shadowPath.moveTo(0, 24);
    shadowPath.lineTo(size.width, 0);
    shadowPath.lineTo(size.width, size.height);
    shadowPath.lineTo(size.width / 6, size.height);
    shadowPath.quadraticBezierTo(
      -2,
      size.height + 2,
      0,
      size.height - (size.width / 6),
    );
    shadowPath.lineTo(0, 0);
    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
