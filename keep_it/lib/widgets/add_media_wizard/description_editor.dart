import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:store/store.dart';

class DescriptionEditor extends StatefulWidget {
  const DescriptionEditor(
    this.item, {
    required this.controller,
    required this.focusNode,
    required this.enabled,
    super.key,
  });
  final CollectionBase item;
  final TextEditingController controller;
  final FocusNode focusNode;

  final bool enabled;

  @override
  State<StatefulWidget> createState() => _DescriptionEditorState();
}

class _DescriptionEditorState extends State<DescriptionEditor> {
  late bool enabled;
  @override
  void initState() {
    enabled = widget.controller.text.isEmpty && widget.enabled;
    if (enabled) {
      widget.focusNode.requestFocus();
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enabled && enabled && !widget.focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.focusNode.requestFocus();
      });
    }
    return GestureDetector(
      onTap: widget.enabled && !enabled
          ? () async {
              setState(() {
                enabled = true;
              });
            }
          : null,
      child: CLTextField.multiLine(
        widget.controller,
        focusNode: widget.focusNode,
        hint: 'What is the best thing,'
            ' you can say about this?',
        maxLines: 5,
        enabled: enabled,
      ),
    );
  }
}
