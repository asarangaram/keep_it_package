import 'package:flutter/material.dart';

import '../builders/get_menu_position.dart';

class DraggableMenu extends StatelessWidget {
  const DraggableMenu({
    required GlobalKey<State<StatefulWidget>> parentKey,
    required this.child,
    super.key,
  }) : _parentKey = parentKey;
  final Widget child;

  final GlobalKey<State<StatefulWidget>> _parentKey;

  @override
  Widget build(BuildContext context) {
    return GetMenuPosition(
      builder: (menuPosition, {required onUpdateMenuPosition}) {
        return _DraggableMenu(
          parentKey: _parentKey,
          offset: menuPosition,
          onUpdateOffset: onUpdateMenuPosition,
          child: child,
        );
      },
    );
  }
}

class _DraggableMenu extends StatefulWidget {
  const _DraggableMenu({
    required this.parentKey,
    required this.child,
    required this.offset,
    required this.onUpdateOffset,
  });
  final GlobalKey parentKey;
  final Widget child;
  final Offset offset;
  final void Function(Offset offset) onUpdateOffset;

  @override
  State<StatefulWidget> createState() => DraggableMenuState();
}

class DraggableMenuState extends State<_DraggableMenu> {
  final GlobalKey _key = GlobalKey();

  bool _isDragging = false;

  late Offset _minOffset;
  late Offset _maxOffset;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
  }

  void _setBoundary(Duration _) {
    final parentRenderBox =
        widget.parentKey.currentContext!.findRenderObject()! as RenderBox;
    final renderBox = _key.currentContext!.findRenderObject()! as RenderBox;

    try {
      final parentSize = parentRenderBox.size;
      final size = renderBox.size;

      setState(() {
        _minOffset = Offset.zero;
        _maxOffset = Offset(
          parentSize.width - size.width,
          parentSize.height - size.height,
        );
      });
    } on Exception {
      //print('catch: $e');
    }
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent, Offset currOffset) {
    final offset = currOffset;
    //ref.read(menuControlNotifierProvider.select((value) => value.menuPosition));
    var newOffsetX = offset.dx + pointerMoveEvent.delta.dx;
    var newOffsetY = offset.dy + pointerMoveEvent.delta.dy;

    if (newOffsetX < _minOffset.dx) {
      newOffsetX = _minOffset.dx;
    } else if (newOffsetX > _maxOffset.dx) {
      newOffsetX = _maxOffset.dx;
    }

    if (newOffsetY < _minOffset.dy) {
      newOffsetY = _minOffset.dy;
    } else if (newOffsetY > _maxOffset.dy) {
      newOffsetY = _maxOffset.dy;
    }
    widget.onUpdateOffset(Offset(newOffsetX, newOffsetY));
  }

  @override
  Widget build(BuildContext context) {
    final offset = widget.offset;

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Listener(
        onPointerMove: (PointerMoveEvent pointerMoveEvent) {
          _updatePosition(pointerMoveEvent, offset);

          setState(() {
            _isDragging = true;
          });
        },
        onPointerUp: (PointerUpEvent pointerUpEvent) {
          // print('onPointerUp');

          if (_isDragging) {
            setState(() {
              _isDragging = false;
            });
          } else {
            //widget.onPressed();
          }
        },
        child: Container(
          key: _key,
          margin: const EdgeInsets.all(4),
          child: widget.child,
        ),
      ),
    );
  }
}
