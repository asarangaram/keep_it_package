import 'package:flutter/material.dart';

import '../../basics/cl_buttons_grid.dart';
import '../../models/cl_menu_item.dart';

class CLButtonsGridDemo extends StatelessWidget {
  const CLButtonsGridDemo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const CLButtonsGrid(
      children2D: [
        [
          CLMenuItem(title: 'Item 1.1', icon: Icons.menu),
          CLMenuItem(title: 'Item 1.2', icon: Icons.new_label),
          CLMenuItem(title: 'Item 1.3', icon: Icons.new_label),
        ],
        [
          CLMenuItem(title: 'Item 2.1', icon: Icons.menu),
          CLMenuItem(title: 'Item 2.2', icon: Icons.new_label),
        ],
        [
          CLMenuItem(title: 'Item 3.1', icon: Icons.menu),
        ],
        [
          CLMenuItem(title: 'Item 4.1', icon: Icons.menu),
          CLMenuItem(title: 'Item 4.2', icon: Icons.new_label),
        ],
        [
          CLMenuItem(title: 'Item 5.1', icon: Icons.menu),
          CLMenuItem(title: 'Item 5.2', icon: Icons.new_label),
        ],
        [
          CLMenuItem(title: 'Item 6.1', icon: Icons.menu),
          CLMenuItem(title: 'Item 6.2', icon: Icons.new_label),
          CLMenuItem(title: 'Item 6.3', icon: Icons.new_label),
        ],
        [
          CLMenuItem(title: 'Item 7.1', icon: Icons.menu),
          CLMenuItem(title: 'Item 7.2', icon: Icons.new_label),
        ],
        [
          CLMenuItem(title: 'Item 8', icon: Icons.menu),
          CLMenuItem(title: 'Item 8', icon: Icons.new_label),
        ],
      ],
    );
  }
}
