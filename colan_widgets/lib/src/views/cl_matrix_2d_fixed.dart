import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'compute_size_and_build.dart';

class Matrix2DFixed extends StatelessWidget {
  const Matrix2DFixed({
    required this.itemBuilder,
    required this.hCount,
    required this.vCount,
    required this.itemCount,
    this.strictMartrix = true,
    super.key,
  });

  final Widget Function(BuildContext context, int index) itemBuilder;

  final int hCount;
  final int vCount;
  final int itemCount;
  final bool strictMartrix;

  @override
  Widget build(BuildContext context) {
    itemCount.toString().printString(prefix: 'itemCount = ');
    hCount.toString().printString(prefix: 'hCount = ');
    vCount.toString().printString(prefix: 'vCount = ');
    return ComputeSizeAndBuild(
      builder: (context, size) {
        final width = size.width / hCount;
        final height = size.height / vCount;
        final lastCount = (strictMartrix
            ? hCount
            : (hCount * vCount > itemCount)
                ? itemCount - hCount * (vCount - 1)
                : hCount);
        lastCount.toString().printString(prefix: 'lastCount = ');
        return Column(
          children: [
            for (var r = 0; r < vCount; r++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var c = 0;
                      c < (r == (vCount - 1) ? lastCount : hCount);
                      c++)
                    SizedBox(
                      width: width,
                      height: height,
                      child: ((r * hCount + c) >= itemCount)
                          ? strictMartrix
                              ? Container()
                              : throw Exception('Unexpected')
                          : itembuilderWrapper(context, r * hCount + c),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget itembuilderWrapper(BuildContext context, int index) {
    index.toString().printString(prefix: 'index = ');
    return itemBuilder(context, index);
  }
}
