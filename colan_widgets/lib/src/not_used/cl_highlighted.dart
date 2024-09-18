import 'package:flutter/material.dart';

import '../basics/cl_blink.dart';

class CLHighlighted extends StatefulWidget {
  const CLHighlighted({
    required this.child,
    super.key,
    this.isHighlighed = false,
  });
  final Widget child;
  final bool isHighlighed;

  @override
  State<CLHighlighted> createState() => _CLHighlightedState();
}

class _CLHighlightedState extends State<CLHighlighted> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isHighlighed) {
      return widget.child;
    }
    return CLBlink(
      blinkDuration: const Duration(milliseconds: 500),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 2,
            color: Theme.of(context).highlightColor,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
