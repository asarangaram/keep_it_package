import 'package:flutter/material.dart';

import '../models/cl_menu_item.dart';
import '../widgets/cl_buttons_grid.dart';

class CLButtonsGridDemo extends StatelessWidget {
  const CLButtonsGridDemo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CLButtonsGrid(
      children2D: [
        [
          CLMenuItem('Item 1.1', Icons.menu),
          CLMenuItem('Item 1.2', Icons.new_label),
          CLMenuItem('Item 1.3', Icons.new_label),
        ],
        [
          CLMenuItem('Item 2.1', Icons.menu),
          CLMenuItem('Item 2.2', Icons.new_label),
        ],
        [
          CLMenuItem('Item 3.1', Icons.menu),
        ],
        [
          CLMenuItem('Item 4.1', Icons.menu),
          CLMenuItem('Item 4.2', Icons.new_label),
        ],
        [
          CLMenuItem('Item 5.1', Icons.menu),
          CLMenuItem('Item 5.2', Icons.new_label),
        ],
        [
          CLMenuItem('Item 6.1', Icons.menu),
          CLMenuItem('Item 6.2', Icons.new_label),
          CLMenuItem('Item 6.3', Icons.new_label),
        ],
        [
          CLMenuItem('Item 7.1', Icons.menu),
          CLMenuItem('Item 7.2', Icons.new_label),
        ],
        [
          CLMenuItem('Item 8', Icons.menu),
          CLMenuItem('Item 8', Icons.new_label),
        ],
      ],
    );
  }
}
