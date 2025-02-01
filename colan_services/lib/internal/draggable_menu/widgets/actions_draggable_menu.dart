import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'draggable_menu.dart';
import 'menu.dart';

class ActionsDraggableMenu<T> extends StatelessWidget {
  const ActionsDraggableMenu({
    required this.tagPrefix,
    required this.parentKey,
    required this.menuItems,
    super.key,
  });
  final String tagPrefix;
  final GlobalKey parentKey;

  final List<CLMenuItem> menuItems;

  @override
  Widget build(BuildContext context) {
    return DraggableMenu(
      key: ValueKey('$tagPrefix DraggableMenu'),
      parentKey: parentKey,
      child: Menu(
        menuItems: menuItems,
      ),
    );
  }
}
