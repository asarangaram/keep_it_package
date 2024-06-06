import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  const CircularButton({
    required this.icon,
    super.key,
    this.size = 34,
    this.onPressed,
    this.hasDecoration = true,
    this.isOpaque = false,
    this.foregroundColor,
    this.backgroundColor,
    this.waiting = false,
    this.hasShadow = false,
    this.quarterTurns = 0,
  });
  final VoidCallback? onPressed;
  final double size;
  final IconData icon;
  final bool hasDecoration;
  final bool isOpaque;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final bool waiting;
  final bool hasShadow;
  final int quarterTurns;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.all(hasDecoration ? 8 : 4),
        child: Container(
          decoration: hasDecoration
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOpaque
                      ? backgroundColor ?? Theme.of(context).colorScheme.surface
                      : (backgroundColor ??
                              Theme.of(context).colorScheme.surface)
                          .withAlpha(128),
                  boxShadow: hasShadow
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                )
              : null,
          padding: EdgeInsets.all(hasDecoration ? 16 : 4),
          child: waiting
              ? const CircularProgressIndicator()
              : RotatedBox(
                  quarterTurns: quarterTurns,
                  child: Icon(
                    icon,
                    size: size,
                    color: foregroundColor ??
                        (hasDecoration
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.surface),
                  ),
                ),
        ),
      ),
    );
  }
}
