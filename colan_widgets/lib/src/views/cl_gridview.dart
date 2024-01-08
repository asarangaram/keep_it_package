import 'dart:math';

import 'package:flutter/material.dart';
import '../basics/cl_text.dart';
import '../extensions/ext_list.dart';

class CLGridViewCustom extends StatelessWidget {
  const CLGridViewCustom({
    super.key,
    this.maxItems = 12,
    this.showAll = false,
    required this.children,
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
    final hCount = min(
        maxCrossAxisCount,
        switch (items.length) {
          1 => 1,
          < 4 => 2,
          < 9 => 3,
          < 16 => 4,
          _ => 4
        });

    final items2D = items.convertTo2D(hCount);
    return SingleChildScrollView(
      physics: showAll ? null : const NeverScrollableScrollPhysics(),
      child: DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (var r in items2D) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < r.length; index++)
                      Flexible(
                          child: Container(
                        margin: EdgeInsets.only(
                          top: 1.0,
                          bottom: 1.0,
                          left: (index == 0) ? 1.0 : 8.0,
                          right: 1.0,
                        ),
                        child: r[index][0],
                      )),
                    for (var index = r.length; index < hCount; index++)
                      Flexible(child: Container())
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < r.length; index++)
                      if (r[index].length > 1)
                        Flexible(
                            child: Container(
                          margin: EdgeInsets.only(
                            top: 1.0,
                            bottom: 1.0,
                            left: (index == 0) ? 1.0 : 8.0,
                            right: 1.0,
                          ),
                          child: r[index][1],
                        ))
                      else
                        Flexible(child: Container()),
                    for (var index = r.length; index < hCount; index++)
                      Flexible(child: Container())
                  ],
                ),
              ],
              if (!showAll && children.length > maxItems)
                CLText.small(
                  " + ${children.length - maxItems} items",
                  color: textColor ?? Theme.of(context).colorScheme.onPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
