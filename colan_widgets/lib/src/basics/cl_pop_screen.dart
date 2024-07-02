import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum CLScreenPopGesture { swipeLeft, onTap }

class CLPopScreen extends StatelessWidget {
  const CLPopScreen._({
    required this.child,
    required this.popGesture,
    super.key,
  });

  factory CLPopScreen.onSwipe({
    required Widget child,
    Key? key,
  }) {
    return CLPopScreen._(
      popGesture: CLScreenPopGesture.swipeLeft,
      key: key,
      child: child,
    );
  }
  factory CLPopScreen.onTap({
    required Widget child,
    Key? key,
  }) {
    return CLPopScreen._(
      popGesture: CLScreenPopGesture.onTap,
      key: key,
      child: child,
    );
  }

  final Widget? child;
  final CLScreenPopGesture popGesture;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          popGesture == CLScreenPopGesture.onTap ? () => onPop(context) : null,
      onHorizontalDragEnd: popGesture == CLScreenPopGesture.swipeLeft
          ? (DragEndDetails details) {
              if (details.primaryVelocity == null) return;
              // pop on Swipe
              if (details.primaryVelocity! > 0) {
                onPop(context);
              }
            }
          : null,
      child: child,
    );
  }

  static Future<void> onPop(BuildContext context) async {
    if (context.mounted && context.canPop()) {
      context.pop();
    }
  }
}
