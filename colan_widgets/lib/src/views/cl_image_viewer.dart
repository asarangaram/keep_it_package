import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CLImageViewer extends StatefulWidget {
  const CLImageViewer({
    super.key,
    required this.image,
  });
  final ui.Image image;

  @override
  State<CLImageViewer> createState() => _CLImageViewerState();
}

class _CLImageViewerState extends State<CLImageViewer> {
  bool fullscreen = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        fullscreen = !fullscreen;
      }),
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
