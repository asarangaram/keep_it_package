/* import 'package:flutter/material.dart';
import '../app_logger.dart';
import '../basics/cl_text.dart';
import '../extensions/ext_list.dart';

class CLGridViewCustom extends StatelessWidget {
  const CLGridViewCustom({
    required this.children,
    super.key,
    this.maxItems = 12,
    this.showAll = false,
    this.textColor,
    this.backgroundColor,
    this.maxCrossAxisCount = 4,
  });

  final int maxItems;
  final bool showAll;
  final List<List<Widget>> children;
  final Color? textColor;
  final Color? backgroundColor;
  final int maxCrossAxisCount;

  @override
  Widget build(BuildContext context) {
    final items = showAll ? children : children.firstNItems(maxItems);
    final hCount = maxCrossAxisCount;
    /* final hCount = min(
      maxCrossAxisCount,
      //switch (items.length) { < 4 => 2, < 9 => 3, < 16 => 4, _ => 4 },
    ); */

    final items2D = items.convertTo2D(hCount);
    return Padding(
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
    );
  }
}

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
 */
