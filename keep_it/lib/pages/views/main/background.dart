import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CLBackground extends StatelessWidget {
  const CLBackground({
    required this.child,
    super.key,
    this.brighnessFactor = 0,
    this.hasBackground = true,
  });
  final Widget child;
  final double brighnessFactor;
  final bool hasBackground;

  @override
  Widget build(BuildContext context) {
    if (!hasBackground) return child;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
              ]
                  .map(
                    (e) => brighnessFactor < 0
                        ? e.reduceBrightness(-brighnessFactor)
                        : e.increaseBrightness(brighnessFactor),
                  )
                  .toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
