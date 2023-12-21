import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CLQuickMenuGrid extends StatelessWidget {
  const CLQuickMenuGrid({
    super.key,
    required this.menuItems,
    this.foregroundColor,
    this.backgroundColor,
    this.disabledColor,
  });

  final List<CLMenuItem> menuItems;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? disabledColor;
  final CLScaleType scaleType = CLScaleType.small;

  @override
  Widget build(BuildContext context) {
    const double menuItemHeight = kMinInteractiveDimension * 1.5;

    final avgLength = menuItems
            .map((e) => e.title.length)
            .reduce((value, element) => value + element) /
        menuItems.length;

    double menuItemWidth = scaleType.fontSize * avgLength * .7;

    return Container(
      padding: const EdgeInsets.all(4),
      width: menuItemWidth * (menuItems.length > 4 ? 4 : menuItems.length) + 4,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.count(
        padding: const EdgeInsets.all(0),
        crossAxisCount: menuItems.length > 4 ? 4 : menuItems.length,
        crossAxisSpacing: 8,
        mainAxisSpacing: 0,
        shrinkWrap: true,
        childAspectRatio: menuItemWidth / menuItemHeight,
        physics: const NeverScrollableScrollPhysics(),
        children: menuItems
            .map(
              (e) => Center(
                child: CLButtonIconLabelled.verySmall(
                  e.icon,
                  e.title,
                  onTap: e.onTap,
                  color: foregroundColor,
                  disabledColor: disabledColor,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
