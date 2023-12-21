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

  final List<List<CLMenuItem>> menuItems;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? disabledColor;
  final CLScaleType scaleType = CLScaleType.small;

  @override
  Widget build(BuildContext context) {
    const double menuItemHeight = kMinInteractiveDimension * 1.5;
    double menuItemWidth = kMinInteractiveDimension * 1.5;

    final length =
        menuItems.map((e) => e.length).reduce((a, b) => a > b ? a : b);
    return SizedBox(
      width: menuItemWidth * length,
      height: menuItemHeight * menuItems.length,
      child: CLButtonsGrid(
        clMenuItems2D: menuItems,
        scaleType: CLScaleType.veryLarge,
      ),
    );
  }
}
