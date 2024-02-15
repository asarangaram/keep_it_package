import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../basics/cl_scrollable.dart';



/// If OnTap is provided, onZoom is assigned to onDoubleTap
class CLImageViewer extends StatefulWidget {
  const CLImageViewer({
    required this.image,
    super.key,
    this.allowZoom = true,
    this.isFullScreen = false,
    this.onTap,
    this.overlayWidget,
  });
  final ui.Image image;
  final bool allowZoom;
  final bool isFullScreen;
  final void Function()? onTap;
  final Widget? overlayWidget;

  @override
  State<CLImageViewer> createState() => _CLImageViewerState();
}

class _CLImageViewerState extends State<CLImageViewer> {
  late bool fullscreen;
  late void Function()? onTap;
  late void Function()? onDoubleTap;
  late void Function()? onZoom;

  @override
  void initState() {
    fullscreen = widget.isFullScreen;

    onZoom = widget.allowZoom
        ? () => setState(() {
              fullscreen = !fullscreen;
            })
        : null;
    onTap = widget.onTap ?? onZoom;
    onDoubleTap = widget.onTap != null ? onZoom : null;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (fullscreen) {
            return CLScrollable(
              childHeight: widget.image.height.toDouble(),
              childWidth: widget.image.width.toDouble(),
              child: RawImage(
                image: widget.image,
              ),
            );
          } else {
            return Stack(
              children: [
                Center(
                  child: RawImage(
                    image: widget.image,
                  ),
                ),
                if (widget.overlayWidget != null)
                  Positioned.fill(
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.4,
                        heightFactor: 0.4,
                        child: FittedBox(child: widget.overlayWidget),
                      ),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}
