import 'package:flutter/material.dart';

class ScrollBarThumb extends StatelessWidget {
  const ScrollBarThumb(
    this.backgroundColor,
    this.drawColor,
    this.height,
    this.title,
    this.labelAnimation,
    this.thumbAnimation,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd, {
    super.key,
  });
  final Color backgroundColor;
  final Color drawColor;
  final double height;
  final String title;
  final Animation<dynamic>? labelAnimation;
  final Animation<dynamic>? thumbAnimation;
  final void Function(DragStartDetails details) onDragStart;
  final void Function(DragUpdateDetails details) onDragUpdate;
  final void Function(DragEndDetails details) onDragEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IgnorePointer(
          child: FadeTransition(
            opacity: labelAnimation! as Animation<double>,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: backgroundColor,
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: drawColor,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.transparent,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(12),
        ),
        GestureDetector(
          onVerticalDragStart: onDragStart,
          onVerticalDragUpdate: onDragUpdate,
          onVerticalDragEnd: onDragEnd,
          child: SlideFadeTransition(
            animation: thumbAnimation as Animation<double>?,
            child: CustomPaint(
              foregroundPainter: _ArrowCustomPainter(drawColor),
              child: Material(
                elevation: 4,
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(height),
                  bottomLeft: Radius.circular(height),
                  topRight: const Radius.circular(4),
                  bottomRight: const Radius.circular(4),
                ),
                child: Container(
                  constraints: BoxConstraints.tight(Size(height * 0.6, height)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowCustomPainter extends CustomPainter {
  _ArrowCustomPainter(this.drawColor);
  final Color drawColor;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = drawColor;
    const width = 10.0;
    const height = 8.0;
    final baseX = size.width / 2;
    final baseY = size.height / 2;

    canvas
      ..drawPath(
        trianglePath(Offset(baseX - 2.0, baseY - 2.0), width, height, true),
        paint,
      )
      ..drawPath(
        trianglePath(Offset(baseX - 2.0, baseY + 2.0), width, height, false),
        paint,
      );
  }

  static Path trianglePath(
    Offset offset,
    double width,
    double height,
    // ignore: avoid_positional_boolean_parameters
    bool isUp,
  ) {
    return Path()
      ..moveTo(offset.dx, offset.dy)
      ..lineTo(offset.dx + width, offset.dy)
      ..lineTo(
        offset.dx + (width / 2),
        isUp ? offset.dy - height : offset.dy + height,
      )
      ..close();
  }
}

class SlideFadeTransition extends StatelessWidget {
  const SlideFadeTransition({
    required this.animation,
    required this.child,
    super.key,
  });
  final Animation<double>? animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation!,
      builder: (context, child) =>
          animation!.value == 0.0 ? const SizedBox.shrink() : child!,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(animation!),
        child: FadeTransition(
          opacity: animation!,
          child: child,
        ),
      ),
    );
  }
}
