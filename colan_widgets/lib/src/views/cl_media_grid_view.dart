import 'package:flutter/material.dart';

import '../utils/media/cl_media.dart';
import 'cl_matrix_2d_fixed.dart';
import 'cl_media_view.dart';

class CLMediaGridViewFixed extends StatelessWidget {
  const CLMediaGridViewFixed({
    required this.mediaList,
    required this.hCount,
    required this.vCount,
    this.keepAspectRatio = true,
    super.key,
  });
  final List<CLMedia> mediaList;
  final int hCount;
  final int vCount;
  final bool keepAspectRatio;
  @override
  Widget build(BuildContext context) {
    return CLGridItemSquare(
      child: Matrix2DFixed(
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(1),
            child: CLMediaView(media: mediaList[index]),
          );
        },
        hCount: hCount,
        vCount: vCount,
        itemCount: mediaList.length,
      ),
    );
  }
}

class CLGridItemSquare extends StatelessWidget {
  const CLGridItemSquare({
    super.key,
    this.child,
    this.hasBorder = false,
  });

  final Widget? child;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: SizedBox.square(
        dimension: 128,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: hasBorder ? Border.all() : null,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
