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
    required this.itemCount,
    this.leadingRow,
    this.trailingRow,
    super.key,
    this.controller,
    this.itemHeight,
    this.borderSide = BorderSide.none,
    this.decoration,
  });

  final Widget Function(BuildContext context, int r, int c, int l) itemBuilder;
  final Widget? leadingRow;
  final Widget? trailingRow;

  final int hCount;
  final int vCount;
  final int layers;
  final ScrollController? controller;
  final double? itemHeight;
  final BorderSide borderSide;
  final BoxDecoration? decoration;
  final int itemCount;

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
              height:
                  itemHeight ?? min((size.width / hCount) * 1.4, size.height),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var l = 0; l < layers; l++)
                    FlexibileOptional(
                      isFlexible: true,
                      flex: l == 0 ? 10 : 4,
                      child: Row(
                        crossAxisAlignment: l == 0
                            ? CrossAxisAlignment.end
                            : l == (layers - 1)
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                        children: [
                          for (var c = 0; c < hCount; c++)
                            if ((r * hCount + c) >= itemCount)
                              const Center()
                            else
                              Flexible(
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal:
                                        (borderSide != BorderSide.none ||
                                                decoration != null)
                                            ? 2
                                            : 0,
                                  ),
                                  width: size.width / hCount,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: borderSide,
                                      right: borderSide,
                                      top: (l == 0)
                                          ? borderSide
                                          : BorderSide.none,
                                      bottom: (l == (layers - 1))
                                          ? borderSide
                                          : BorderSide.none,
                                    ),
                                  ),
                                  child: DecoratedBox(
                                    decoration:
                                        decoration ?? const BoxDecoration(),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: l == 0 ? 2 : 0,
                                        left: 2,
                                        right: 2,
                                        bottom: l == (layers - 1) ? 2 : 0,
                                      ),
                                      child: itemBuilder(context, r, c, l),
                                    ),
                                  ),
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
