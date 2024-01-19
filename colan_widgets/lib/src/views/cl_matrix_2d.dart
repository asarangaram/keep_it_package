import 'package:flutter/material.dart';
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
  });

  final int? rows;
  final int columns;
  final int itemCount;
  final Widget Function(BuildContext context, int index, int layer) itemBuilder;
  final Widget Function(BuildContext context, int excessCount)?
      excessViewBuilder;

  @override
  Widget build(
    BuildContext context,
  ) {
    final showAll = rows == null;
    if (columns <= 0) {
      throw Exception('Atleast one column must present');
    }
    if (showAll) {
      return CLMatrix2DScrollable(
        hCount: columns,
        vCount: (itemCount + columns - 1) ~/ columns,
        itemBuilder: builder,
      );
    }
    final excess = itemCount - rows! * columns;

    return CLMatrix2DNonScrollable(
      hCount: columns,
      vCount: rows!,
      trailingRow:
          (excess <= 0) ? null : excessViewBuilder?.call(context, excess),
      itemBuilder: builder,
    );
  }

  Widget builder(BuildContext context, int r, int c, int l) {
    if (l > 0) {
      throw Exception('has only one layer!');
    }
    if ((r * columns + c) >= itemCount) {
      return const Center();
    }

    return itemBuilder(context, r * columns + c, l);
  }
}

class CLMatrix2DNonScrollable extends StatelessWidget {
  const CLMatrix2DNonScrollable({
    required this.itemBuilder,
    required this.hCount,
    required this.vCount,
    this.leadingRow,
    this.trailingRow,
    this.lCount = 1,
    super.key,
  });

  final Widget Function(BuildContext context, int r, int c, int l) itemBuilder;
  final Widget? leadingRow;
  final Widget? trailingRow;

  final int hCount;
  final int vCount;
  final int lCount;

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
                for (var l = 0; l < lCount; l++)
                  Flexible(
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
                  child: Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: trailingRow,
                  ),
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
