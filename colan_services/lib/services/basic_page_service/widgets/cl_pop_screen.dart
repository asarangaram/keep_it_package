import 'package:colan_services/services/basic_page_service/widgets/page_manager.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';

enum CLScreenPopGesture { swipeLeft, onTap }

class CLPopScreen extends StatelessWidget {
  const CLPopScreen._({
    required this.child,
    required this.popGesture,
    required this.result,
    super.key,
  });

  factory CLPopScreen.onSwipe({
    required Widget child,
    Key? key,
    bool? result,
  }) {
    return CLPopScreen._(
      popGesture: CLScreenPopGesture.swipeLeft,
      key: key,
      result: result,
      child: child,
    );
  }
  factory CLPopScreen.onTap({
    required Widget child,
    Key? key,
    bool? result,
  }) {
    return CLPopScreen._(
      popGesture: CLScreenPopGesture.onTap,
      key: key,
      result: result,
      child: child,
    );
  }

  final Widget? child;
  final CLScreenPopGesture popGesture;
  final bool? result;

  @override
  Widget build(BuildContext context) {
    return CLKeyListener(
      onEsc: (popGesture == CLScreenPopGesture.swipeLeft) &&
              !ColanPlatformSupport.isMobilePlatform
          ? () => PageManager.of(context).pop(result)
          : null,
      child: GestureDetector(
        onTap: popGesture == CLScreenPopGesture.onTap
            ? () => PageManager.of(context).pop
            : null,
        onHorizontalDragEnd: popGesture == CLScreenPopGesture.swipeLeft
            ? (DragEndDetails details) {
                if (details.primaryVelocity == null) return;
                // pop on Swipe
                if (details.primaryVelocity! > 0) {
                  PageManager.of(context).pop(result);
                }
              }
            : null,
        child: child,
      ),
    );
  }
}
