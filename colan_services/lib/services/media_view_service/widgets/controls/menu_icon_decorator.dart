import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class MenuItemView extends StatelessWidget {
  const MenuItemView(this.menuItem, {super.key});
  final CLMenuItem menuItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: menuItem.onTap,
      child: CircledIcon(
        menuItem.icon,
      ),
    );
    /* return ShadButton.ghost(
      icon: Icon(
        menuItem.icon,
      ),
      onPressed: menuItem.onTap,
    ); */
  }
}
