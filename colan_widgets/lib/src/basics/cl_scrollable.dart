/// based on
/// https://github.com/toufikzitouni/flutter-bidirectional_scrollview_plugin
library;

import 'package:flutter/material.dart';

class CLScrollable extends StatefulWidget {
  const CLScrollable({
    // this.scrollOverflow = Overflow.visible,
    required this.child,
    super.key,
    this.childWidth = 300,
    this.childHeight = 300,
    this.velocityFactor = 1.0,
    this.initialOffset = Offset.zero,
    this.scrollDirection = ScrollDirection.both,
    this.scrollListener,
  });

  final Widget child;
  final double childWidth;
  final double childHeight;
  final double velocityFactor;
  final Offset initialOffset;
  final ScrollDirection scrollDirection;
  final ValueChanged<Offset>? scrollListener;
  //final Overflow scrollOverflow;

  @override
  State<StatefulWidget> createState() => _BidirectionalScrollViewState();
}

class _BidirectionalScrollViewState extends State<CLScrollable>
    with SingleTickerProviderStateMixin {
  final GlobalKey _containerKey = GlobalKey();
  final GlobalKey _positionedKey = GlobalKey();

  double xPos = 0;
  double yPos = 0;
  double xViewPos = 0;
  double yViewPos = 0;

  late AnimationController _controller;
  late Animation<Offset> _flingAnimation;

  bool _enableFling = false;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'pos : ($xPos, $yPos), viewPos : ($xViewPos, $yViewPos)';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addListener(_handleFlingAnimation);
  }

  set offset(Offset offset) {
    setState(() {
      xViewPos = -offset.dx;
      xViewPos = -offset.dy;
    });
  }

  Offset get offset => Offset(xViewPos, xViewPos);

  double get x {
    return -xViewPos;
  }

  double get y {
    return -yViewPos;
  }

  double get height {
    final renderBox =
        _positionedKey.currentContext!.findRenderObject()! as RenderBox;
    return renderBox.size.height;
  }

  double get width {
    final renderBox =
        _positionedKey.currentContext!.findRenderObject()! as RenderBox;
    return renderBox.size.width;
  }

  double get containerHeight {
    final containerBox =
        _containerKey.currentContext!.findRenderObject()! as RenderBox;
    return containerBox.size.height;
  }

  double get containerWidth {
    final containerBox =
        _containerKey.currentContext!.findRenderObject()! as RenderBox;
    return containerBox.size.width;
  }

  void _handleFlingAnimation() {
    if (!_enableFling ||
        _flingAnimation.value.dx.isNaN ||
        _flingAnimation.value.dy.isNaN) {
      return;
    }

    var newXPosition = xPos + _flingAnimation.value.dx;
    var newYPosition = yPos + _flingAnimation.value.dy;

    if (newXPosition > widget.initialOffset.dx || width < containerWidth) {
      newXPosition = widget.initialOffset.dx;
    } else if (-newXPosition + containerWidth > width) {
      newXPosition = containerWidth - width;
    }

    if (newYPosition > widget.initialOffset.dy || height < containerHeight) {
      newYPosition = widget.initialOffset.dy;
    } else if (-newYPosition + containerHeight > height) {
      newYPosition = containerHeight - height;
    }

    setState(() {
      xViewPos = newXPosition;
      yViewPos = newYPosition;
    });

    _sendScrollValues();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final referenceBox = context.findRenderObject()! as RenderBox;
    final position = referenceBox.globalToLocal(details.globalPosition);

    var newXPosition = xViewPos + (position.dx - xPos);
    var newYPosition = yViewPos + (position.dy - yPos);

    final containerBox =
        _containerKey.currentContext!.findRenderObject()! as RenderBox;
    final containerWidth = containerBox.size.width;
    final containerHeight = containerBox.size.height;

    if (newXPosition > widget.initialOffset.dx || width < containerWidth) {
      newXPosition = widget.initialOffset.dx;
    } else if (-newXPosition + containerWidth > width) {
      newXPosition = containerWidth - width;
    }

    if (newYPosition > widget.initialOffset.dy || height < containerHeight) {
      newYPosition = widget.initialOffset.dy;
    } else if (-newYPosition + containerHeight > height) {
      newYPosition = containerHeight - height;
    }

    setState(() {
      xViewPos = newXPosition;
      yViewPos = newYPosition;
    });

    xPos = position.dx;
    yPos = position.dy;

    _sendScrollValues();
  }

  void _handlePanDown(DragDownDetails details) {
    _enableFling = false;
    final referenceBox = context.findRenderObject()! as RenderBox;
    final position = referenceBox.globalToLocal(details.globalPosition);

    xPos = position.dx;
    yPos = position.dy;
  }

  void _handlePanEnd(DragEndDetails details) {
    final magnitude = details.velocity.pixelsPerSecond.distance;
    final velocity = magnitude / 1000;

    final direction = details.velocity.pixelsPerSecond / magnitude;
    final distance = (Offset.zero & context.size!).shortestSide;

    xPos = xViewPos;
    yPos = yViewPos;

    _enableFling = true;
    _flingAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: direction * distance * widget.velocityFactor,
    ).animate(_controller);
    _controller
      ..value = 0.0
      ..fling(velocity: velocity);
  }

  void _sendScrollValues() {
    widget.scrollListener?.call(Offset(-xViewPos, -yViewPos));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scrollDirection == ScrollDirection.horizontal) {
      yViewPos = widget.initialOffset.dy;
    }

    if (widget.scrollDirection == ScrollDirection.vertical) {
      xViewPos = widget.initialOffset.dx;
    }

    return GestureDetector(
      onPanDown: _handlePanDown,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: ColoredBox(
        key: _containerKey,
        color: Colors.transparent,
        child: Stack(
          //overflow: widget.scrollOverflow,
          children: <Widget>[
            Positioned(
              key: _positionedKey,
              top: yViewPos,
              left: xViewPos,
              width: widget.childWidth,
              height: widget.childHeight,
              child: CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ScrollDirection { horizontal, vertical, both }
