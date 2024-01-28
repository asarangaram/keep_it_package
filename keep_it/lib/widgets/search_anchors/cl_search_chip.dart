import 'package:flutter/material.dart';

class SearchAnchorChip extends StatelessWidget {
  const SearchAnchorChip({
    required this.controller,
    required this.onDone,
    super.key,
    this.label,
    this.avatar,
  });

  final SearchController controller;

  final void Function(String val) onDone;
  final Icon? avatar;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: avatar,
      label: Text(label ?? 'Label'),
      onPressed: controller.openView,
    );
  }
}
