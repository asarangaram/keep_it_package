import 'package:flutter/material.dart';

class CLMatrix2DScrollable extends StatelessWidget {
  const CLMatrix2DScrollable({
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
    return ListView.builder(
      itemCount: vCount,
      itemBuilder: (context, r) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var l = 0; l < lCount; l++)
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var c = 0; c < hCount; c++)
                      Flexible(child: itemBuilder(context, r, c, l)),
                  ],
                ),
              ),
          ],
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
