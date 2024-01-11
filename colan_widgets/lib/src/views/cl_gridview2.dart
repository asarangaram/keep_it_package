import 'dart:math';

import 'package:flutter/material.dart';

import '../extensions/ext_list.dart';

class CLGridViewListBased extends StatelessWidget {
  const CLGridViewListBased({
    required this.children,
    super.key,
    this.maxItems = 12,
    this.textColor,
    this.backgroundColor,
    this.maxCrossAxisCount = 4,
  });

  final int maxItems;

  final List<List<Widget>> children;
  final Color? textColor;
  final Color? backgroundColor;
  final int maxCrossAxisCount;

  @override
  Widget build(BuildContext context) {
    final items = children;
    final hCount = min(
      maxCrossAxisCount,
      switch (items.length) { 1 => 1, < 4 => 2, < 9 => 3, < 16 => 4, _ => 4 },
    );

    final items2D = items.convertTo2D(hCount);

    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ListView.builder(
          itemCount: items2D.length,
          itemBuilder: (context, index) {
            final r = items2D[index];

            return ListTile(
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var index = 0; index < r.length; index++)
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(
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
                  Row(
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
                  const Divider(
                    thickness: 1,
                    height: 2,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
