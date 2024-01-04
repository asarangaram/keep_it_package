import 'package:flutter/material.dart';
import '../basics/cl_text.dart';
import '../extensions/ext_list.dart';

class CLGridViewCustom extends StatelessWidget {
  const CLGridViewCustom({
    super.key,
    required this.maxItems,
    required this.showAll,
    required this.children,
    this.textColor,
  });

  final int maxItems;
  final bool showAll;
  final List<Widget> children;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final items = showAll ? children : children.firstNItems(maxItems);
    final hCount =
        switch (items.length) { 1 => 1, < 4 => 2, < 9 => 3, < 16 => 4, _ => 4 };

    final items2D = items.convertTo2D(hCount);
    return SingleChildScrollView(
      physics: showAll ? null : const NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var r in items2D)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < r.length; index++)
                  Flexible(
                      child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: r[index],
                  )),
                for (var index = r.length; index < hCount; index++)
                  Flexible(child: Container())
              ],
            ),
          if (!showAll && children.length > maxItems)
            CLText.small(
              " + ${children.length - maxItems} items",
              color: textColor ?? Theme.of(context).colorScheme.onPrimary,
            )
        ],
      ),
    );
  }
}
