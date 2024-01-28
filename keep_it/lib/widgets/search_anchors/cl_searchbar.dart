import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CLSearchBarWrap extends StatelessWidget {
  const CLSearchBarWrap({
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
    return SearchBar(
      focusNode: focusNode,
      controller: controller,
      padding: const MaterialStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: 16),
      ),
      onTap: controller.openView,
      onChanged: (_) {
        controller.openView();
      },
      onSubmitted: (val) {
        if (val.isNotEmpty) {
          focusNode?.unfocus();
          onDone(val);
        }
      },
      leading: const CLIcon.small(Icons.search),
      hintText: 'Collection Name',
    );
  }
}
