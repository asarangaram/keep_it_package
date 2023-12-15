import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'quickmenu_controller.dart';

class CLQuickMenuScope extends ConsumerWidget {
  const CLQuickMenuScope({
    required GlobalKey key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [child, const QuickMenu()],
    );
  }
}

enum PreferredPosition {
  top,
  bottom,
}

Rect _menuRect = Rect.zero;

class QuickMenu extends ConsumerStatefulWidget {
  final bool enablePassEvent = true; // as Parameter?

  const QuickMenu({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => QuickMenuState();
}

class QuickMenuState extends ConsumerState<QuickMenu> {
  bool _canResponse = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final control = ref.watch(quickMenuControllerNotifierProvider);

    if (!control.isMenuShowing) return Container();

    final Offset anchorOffset = control.anchorOffset!;
    final Size anchorSize = control.anchorSize!;

    Widget menu = Center(
      child: CustomMultiChildLayout(
        delegate: _MenuLayoutDelegate(
          anchorSize: anchorSize,
          anchorOffset: anchorOffset,
          parentOffset: control.parentOffset!,
        ),
        children: <Widget>[
          LayoutId(
              id: _MenuLayoutId.content,
              child: LayoutBuilder(builder: (context, constraints) {
                if (control.menuBuilder == null) {
                  return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 4),
                        color: Colors.yellow,
                      ),
                      child: const Text(
                        "Your menu goes here",
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ));
                }
                return control.menuBuilder!(context, constraints, onDone: () {
                  ref
                      .read(quickMenuControllerNotifierProvider.notifier)
                      .hideMenu();
                });
              })),
        ],
      ),
    );
    return Listener(
      behavior: widget.enablePassEvent
          ? HitTestBehavior.translucent
          : HitTestBehavior.opaque,
      onPointerDown: (PointerDownEvent event) {
        Offset offset = event.localPosition;
        // If tap position in menu
        if (_menuRect.contains(
            Offset(offset.dx - control.parentOffset!.dx, offset.dy))) {
          return;
        }
        if (!_canResponse) return;
        ref.read(quickMenuControllerNotifierProvider.notifier).hideMenu();

        // When [enablePassEvent] works and we tap the [child] to [hideMenu],
        // but the passed event would trigger [showMenu] again.
        // So, we use time threshold to solve this bug.
        _canResponse = false;
        Future.delayed(const Duration(milliseconds: 300))
            .then((_) => _canResponse = true);
      },
      child: menu,
    );
  }
}

enum _MenuLayoutId { content }

class _MenuLayoutDelegate extends MultiChildLayoutDelegate {
  _MenuLayoutDelegate({
    required this.anchorSize,
    required this.anchorOffset,
    required this.parentOffset,
  });

  final Size anchorSize;
  final Offset anchorOffset;
  final Offset parentOffset;

  @override
  void performLayout(Size size) {
    // Validate if this hardcodign makes sense

    Size contentSize = Size.zero;
    if (hasChild(_MenuLayoutId.content)) {
      contentSize = layoutChild(
        _MenuLayoutId.content,
        BoxConstraints.loose(size),
      );
    }

    Offset contentOffset = Offset(
        anchorOffset.dx + (anchorSize.width * 0.5),
        anchorOffset.dy -
            parentOffset.dy +
            (anchorSize.width * 0.2) -
            contentSize.height);

    if ((contentOffset.dx + contentSize.width) > size.width) {
      contentOffset = Offset(
          anchorOffset.dx + (anchorSize.width * 0.5) - (contentSize.width),
          contentOffset.dy);
    }

    if (contentOffset.dy < 0 || contentOffset.dy + contentSize.height < 0) {
      // Move to down.
      contentOffset = Offset(contentOffset.dx,
          anchorOffset.dy - parentOffset.dy + anchorSize.height - 2);
    }

    if (hasChild(_MenuLayoutId.content)) {
      positionChild(_MenuLayoutId.content, contentOffset);
    }

    _menuRect = Rect.fromLTWH(
      contentOffset.dx,
      contentOffset.dy,
      contentSize.width,
      contentSize.height,
    );
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}
