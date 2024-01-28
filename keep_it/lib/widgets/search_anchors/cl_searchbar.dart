import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CLSearchBarWrap extends StatefulWidget {
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
  State<CLSearchBarWrap> createState() => _CLSearchBarWrapState();
}

class _CLSearchBarWrapState extends State<CLSearchBarWrap> {
  @override
  void initState() {
    widget.focusNode?.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode?.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      focusNode: widget.focusNode,
      controller: widget.controller,
      padding: const MaterialStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: 16),
      ),
      onTap: widget.controller.openView,
      onChanged: (_) {
        widget.controller.openView();
      },
      onSubmitted: (val) {
        if (val.isNotEmpty) {
          widget.focusNode?.unfocus();
          widget.onDone(val);
        }
      },
      leading: const CLIcon.small(Icons.search),
      hintText: 'Collection Name',
    );
  }
}
