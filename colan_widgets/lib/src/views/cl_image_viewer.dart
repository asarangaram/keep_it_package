import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// If OnTap is provided, onZoom is assigned to onDoubleTap
class CLImageViewer extends StatefulWidget {
  const CLImageViewer({
    super.key,
    required this.image,
    this.allowZoom = true,
    this.isFullScreen = false,
    this.onTap,
  });
  final ui.Image image;
  final bool allowZoom;
  final bool isFullScreen;
  final Function()? onTap;

  @override
  State<CLImageViewer> createState() => _CLImageViewerState();
}

class _CLImageViewerState extends State<CLImageViewer> {
  late bool fullscreen;
  late Function()? onTap;
  late Function()? onDoubleTap;
  late Function()? onZoom;

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
      child: LayoutBuilder(builder: ((context, constraints) {
        if (fullscreen) {
          return CLScrollable(
              childHeight: widget.image.height.toDouble(),
              childWidth: widget.image.width.toDouble(),
              child: RawImage(
                image: widget.image,
              ));
        } else {
          return Center(
              child: RawImage(
            image: widget.image,
          ));
        }
      })),
    );
  }
}
