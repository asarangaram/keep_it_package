import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'quickmenu_controller.dart';

class CLQuickMenuAnchor extends ConsumerStatefulWidget {
  const CLQuickMenuAnchor({
    required this.child,
    required this.parentKey,
    required this.menuBuilder,
    super.key,
    this.color,
    this.disabledColor,
    this.onLongPress,
  })  : isLongPress = false,
        onTap = null;
  const CLQuickMenuAnchor.longPress({
    required this.child,
    required this.parentKey,
    required this.menuBuilder,
    super.key,
    this.color,
    this.disabledColor,
    this.onTap,
  })  : isLongPress = true,
        onLongPress = null;

  final Widget child;
  final GlobalKey parentKey;
  final MenuBuilder menuBuilder;
  final bool isLongPress;
  final Color? color;
  final Color? disabledColor;
  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CLQuickMenuAnchorState();

  static void clearQuickMenu(BuildContext context, WidgetRef ref) {
    if (context.mounted) {
      ref.read(quickMenuControllerNotifierProvider.notifier).hideMenu();
    }
  }
}

class CLQuickMenuAnchorState extends ConsumerState<CLQuickMenuAnchor> {
  Size? overlaySize;
  Size? anchorSize;
  Offset? anchorOffset;
  Offset? parentOffset;
  bool canResponse = true;

  void getDetails() {
    final overLayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final parentBox =
        widget.parentKey.currentContext!.findRenderObject()! as RenderBox;
    parentOffset = parentBox.localToGlobal(Offset.zero);

    final childBox = context.findRenderObject() as RenderBox?;
    anchorSize = childBox!.size;
    anchorOffset = childBox.localToGlobal(Offset.zero);
    overlaySize = overLayBox?.size;
  }

  void showMenu() {
    if (anchorOffset != null &&
        anchorSize != null &&
        parentOffset != null &&
        overlaySize != null) {
      ref.read(quickMenuControllerNotifierProvider.notifier).showMenu(
            overlaySize: overlaySize,
            anchorSize: anchorSize!,
            anchorOffset: anchorOffset!,
            parentOffset: parentOffset!,
            menuBuilder: widget.menuBuilder,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<QuickMenuController>(quickMenuControllerNotifierProvider,
        (previous, next) {
      if (next.isMenuShowing) {
        setState(() {
          canResponse = false;
        });
      } else {
        Future<dynamic>.delayed(const Duration(milliseconds: 300)).then(
          (_) => {
            if (mounted)
              {
                setState(() {
                  canResponse = true;
                }),
              },
          },
        );
      }
    });

    final onTapDown = (!widget.isLongPress) ? (_) => getDetails() : null;
    final onLongPressDown = (widget.isLongPress) ? (_) => getDetails() : null;

    final onTap = (widget.isLongPress)
        ? widget.onTap
        : !canResponse
            ? null
            : showMenu;
    final onLongPress = (!widget.isLongPress)
        ? widget.onLongPress
        : !canResponse
            ? null
            : showMenu;

    return GestureDetector(
      onTapDown: onTapDown,
      onLongPressDown: onLongPressDown,
      onSecondaryTap: !canResponse ? null : showMenu,
      onSecondaryTapDown: onLongPressDown,
      onTap: onTap,
      onLongPress: onLongPress,
      child: widget.child,
    );
  }
}
