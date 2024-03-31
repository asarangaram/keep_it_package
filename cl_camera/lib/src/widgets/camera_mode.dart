import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CameraMode extends StatelessWidget {
  const CameraMode({
    required this.menuItems,
    required this.currIndex,
    super.key,
  });
  final List<CLMenuItem> menuItems;
  final int currIndex;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          for (final (index, item) in menuItems.indexed)
            CLButtonText.standard(
              item.title,
              color: index == currIndex
                  ? Colors.yellow.shade300
                  : Colors.yellow.shade100,
              onTap: item.onTap,
            ),
        ]
            .map(
              (e) => Padding(
                padding: const EdgeInsets.all(8),
                child: e,
              ),
            )
            .toList(),
      ),
    );
  }
}
