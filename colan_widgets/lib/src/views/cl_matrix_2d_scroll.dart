import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/flexibile_optional.dart';
import 'compute_size_and_build.dart';

class CLMatrix2DScrollable extends StatelessWidget {
  const CLMatrix2DScrollable({
    required this.itemBuilder,
    required this.hCount,
    required this.vCount,
    required this.layers,
    this.leadingRow,
    this.trailingRow,
    super.key,
  });

  final Widget Function(BuildContext context, int r, int c, int l) itemBuilder;
  final Widget? leadingRow;
  final Widget? trailingRow;

  final int hCount;
  final int vCount;
  final int layers;

  @override
  Widget build(BuildContext context) {
    return ComputeSizeAndBuild(
      builder: (context, size) {
        /* print(
          ' Available Size $size, hCount = $hCount, vCount = $vCount, '
          'lCount= $lCount',
        ); */
        return ListView.builder(
          itemCount: vCount,
          /* prototypeItem: SizedBox(
            height: min((size.width / hCount) * 1.4, size.height),
          ), */
          itemBuilder: (context, r) {
            return SizedBox(
              height: min((size.width / hCount) * 1.4, size.height),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var l = 0; l < layers; l++)
                    FlexibileOptional(
                      isFlexible: l == 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var c = 0; c < hCount; c++)
                            Flexible(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: size.width / hCount,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: itemBuilder(context, r, c, l),
                                    ),
                                  ),
                                ],
                              ),
                            ), //
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
