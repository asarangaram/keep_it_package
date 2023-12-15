import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../basics/cl_icon.dart';
import 'quickmenu_controller.dart';

class CLQuickMenuAnchor extends ConsumerStatefulWidget {
  const CLQuickMenuAnchor({
    super.key,
    this.child,
    required this.parentKey,
    required this.menuBuilder,
    required this.color,
    required this.disabledColor,
    this.onLongPress,
  })  : isLongPress = false,
        onTap = null;
  const CLQuickMenuAnchor.longPress(
      {super.key,
      this.child,
      required this.parentKey,
      required this.menuBuilder,
      required this.color,
      required this.disabledColor,
      this.onTap})
      : isLongPress = true,
        onLongPress = null;

  final Widget? child;
  final GlobalKey parentKey;
  final MenuBuilder menuBuilder;
  final bool isLongPress;
  final Color color;
  final Color disabledColor;
  final Function()? onTap;
  final Function()? onLongPress;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CLQuickMenuAnchorState();
}

class CLQuickMenuAnchorState extends ConsumerState<CLQuickMenuAnchor> {
  Size? overlaySize;
  Size? anchorSize;
  Offset? anchorOffset;
  Offset? parentOffset;
  bool canResponse = true;

  getDetails() {
    RenderBox? overLayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final RenderBox parentBox =
        widget.parentKey.currentContext?.findRenderObject() as RenderBox;
    parentOffset = parentBox.localToGlobal(const Offset(0, 0));

    RenderBox? childBox = context.findRenderObject() as RenderBox?;
    anchorSize = childBox!.size;
    anchorOffset = childBox.localToGlobal(const Offset(0, 0));
    overlaySize = overLayBox?.size;
  }

  showMenu() {
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
        Future.delayed(const Duration(milliseconds: 300)).then((_) => {
              if (mounted)
                {
                  setState(() {
                    canResponse = true;
                  })
                }
            });
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
      onTap: onTap,
      onLongPress: onLongPress,
      child: widget.child ??
          CLIcon.verySmall(Icons.more_vert,
              color: canResponse ? widget.color : widget.disabledColor),
    );
  }
}
