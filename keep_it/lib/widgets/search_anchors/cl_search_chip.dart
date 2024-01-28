import 'package:flutter/material.dart';

class SearchAnchorChip extends StatelessWidget {
  const SearchAnchorChip({
    required this.controller,
    required this.onDone,
    super.key,
    this.focusNode,
  });

  final SearchController controller;
  final FocusNode? focusNode;
  final void Function(String val) onDone;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      //avatar: Icon(MdiIcons.plus),
      label: const Text('Add Tag'),
      onPressed: controller.openView,
    );
  }
}
