import 'package:colan_widgets/src/widgets/flexibile_optional.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'cl_matrix_2d_scroll.dart';
import 'compute_size_and_build.dart';

class CLMatrix2D extends StatelessWidget {
  const CLMatrix2D({
    required this.itemBuilder,
    required this.itemCount,
    this.rows,
    this.columns = 3,
    this.excessViewBuilder,
    super.key,
    this.layers = 1,
    this.controller,
    this.itemHeight,
    this.borderSide = BorderSide.none,
    this.decoration,
  });

  final int? rows;
  final int columns;
  final int itemCount;
  final int layers;
  final Widget Function(BuildContext context, int index, int layer) itemBuilder;
  final Widget Function(BuildContext context, int excessCount)?
      excessViewBuilder;
  final AutoScrollController? controller;
  final double? itemHeight;
  final BorderSide borderSide;
  final BoxDecoration? decoration;
  @override
  Widget build(
    BuildContext context,
  ) {
    final showAll = rows == null;
    if (columns <= 0) {
      throw Exception('Atleast one column must present');
    }
    if (showAll && itemCount > 1) {
      return CLMatrix2DScrollable(
        hCount: columns,
        vCount: (itemCount + columns - 1) ~/ columns,
        itemBuilder: builder,
        layers: layers,
        controller: controller,
        itemHeight: itemHeight,
        borderSide: borderSide,
        decoration: decoration,
        itemCount: itemCount,
      );
    }
    if (itemCount == 1) {
      return Column(
        children: [
          for (var l = 0; l < layers; l++) builder(context, 0, 0, l),
        ],
      );
    }

    final excess = itemCount - (rows ?? itemCount) * columns;

    return CLMatrix2DNonScrollable(
      hCount: columns,
      vCount: rows ?? itemCount,
      trailingRow:
          (excess <= 0) ? null : excessViewBuilder?.call(context, excess),
      itemBuilder: builder,
      layers: layers,
    );
  }

  Widget builder(BuildContext context, int r, int c, int l) {
    if ((r * columns + c) >= itemCount) {
      return const Center();
    }
    if (controller == null) {
      return itemBuilder(context, r * columns + c, l);
    }

    return AutoScrollTag(
      key: ValueKey(' $r $c $l'),
      controller: controller!,
      index: r * layers + l,
      highlightColor: Colors.black.withOpacity(0.1),
      child: itemBuilder(context, r * columns + c, l),
    );
  }
}

class CLMatrix2DNonScrollable extends StatelessWidget {
  const CLMatrix2DNonScrollable({
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
        return SizedBox.fromSize(
          size: size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (leadingRow != null) Flexible(child: leadingRow!),
              for (var r = 0; r < vCount; r++)
                for (var l = 0; l < layers; l++)
                  FlexibileOptional(
                    isFlexible: l == 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var c = 0; c < hCount; c++)
                          SizedBox(
                            width: size.width / hCount,
                            child: itemBuilder(context, r, c, l),
                          ),
                      ],
                    ),
                  ),
              if (trailingRow != null)
                Flexible(
                  child: trailingRow!,
                ),
            ],
          ),
        );
      },
    );

    /* return Padding(
      padding: const EdgeInsets.all(2),
      child: ListView.builder(
        physics: showAll ? null : const NeverScrollableScrollPhysics(),
        itemCount:
            items2D.length + ((!showAll && items2D.length > maxItems) ? 1 : 0),
        itemBuilder: (context, index) {
          _infoLogger('itemBuilder: index:$index');
          if (index == items2D.length) {
            if (!showAll && children.length > maxItems) {
              CLText.small(
                ' + ${children.length - maxItems} items',
                color: textColor ?? Theme.of(context).colorScheme.onPrimary,
              );
            }
          }

          final r = items2D[index];
          return AspectRatio(
            aspectRatio: 1.4,
            child: Column(
              children: [
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var index = 0; index < r.length; index++)
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 1,
                              bottom: 1,
                              left: (index == 0) ? 1.0 : 8.0,
                              right: 1,
                            ),
                            child: r[index][0],
                          ),
                        ),
                      for (var index = r.length; index < hCount; index++)
                        Flexible(child: Container()),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var index = 0; index < r.length; index++)
                        if (r[index].length > 1)
                          Flexible(
                            child: Container(
                              margin: EdgeInsets.only(
                                top: 1,
                                bottom: 1,
                                left: (index == 0) ? 1.0 : 8.0,
                                right: 1,
                              ),
                              child: r[index][1],
                            ),
                          )
                        else
                          Flexible(child: Container()),
                      for (var index = r.length; index < hCount; index++)
                        Flexible(child: Container()),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ); */
  }
}
