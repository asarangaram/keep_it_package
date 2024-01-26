import 'package:flutter/material.dart';

import '../utils/media/cl_media.dart';
import 'cl_matrix_2d_fixed.dart';
import 'cl_media_view.dart';

class CLMediaGridViewFixed extends StatelessWidget {
  const CLMediaGridViewFixed({
    required this.mediaList,
    required this.hCount,
    this.vCount,
    this.keepAspectRatio = true,
    super.key,
  });
  final List<CLMedia> mediaList;
  final int hCount;
  final int? vCount;
  final bool keepAspectRatio;
  @override
  Widget build(BuildContext context) {
    if (vCount == null) {
      return Matrix2DNew.scrollable(
        itemCount: mediaList.length,
        hCount: hCount,
        itemBuilder: (context, index) => CLGridItemSquare(
          borderRadius: keepAspectRatio ? BorderRadius.circular(0) : null,
          child: CLMediaView(
            media: mediaList[index],
            keepAspectRatio: keepAspectRatio,
          ),
        ),
      );
    }
    return CLGridItemSquare(
      borderRadius: keepAspectRatio ? BorderRadius.circular(0) : null,
      child: Matrix2DNew(
        itemBuilder: (BuildContext context, int index) {
          return CLGridItemSquare(
            borderRadius: BorderRadius.circular(0),
            child: CLMediaView(
              media: mediaList[index],
              keepAspectRatio: keepAspectRatio,
            ),
          );
        },
        hCount: hCount,
        vCount: vCount!,
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
    this.borderRadius,
  });

  final Widget? child;
  final bool hasBorder;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: hasBorder ? Border.all() : null,
            borderRadius:
                borderRadius ?? const BorderRadius.all(Radius.circular(12)),
          ),
          child: ClipRRect(
            borderRadius:
                borderRadius ?? const BorderRadius.all(Radius.circular(12)),
            child: child,
          ),
        ),
      ),
    );
  }
}
