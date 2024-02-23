import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CollectionEditor extends StatefulWidget {
  const CollectionEditor(
    this.item, {
    this.enabled = true,
    this.controller,
    this.focusNode,
    super.key,
    this.onDone,
    this.onDiscard,
  });
  final Collection item;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  final bool enabled;
  final Future<bool> Function(Collection collection)? onDone;
  final Future<bool> Function()? onDiscard;

  @override
  State<StatefulWidget> createState() => CollectionEditorState();
}

class CollectionEditorState extends State<CollectionEditor> {
  late final TextEditingController controller;
  final TextEditingController dummyController = TextEditingController();
  late final FocusNode focusNode;
  late bool enabled;
  @override
  void initState() {
    controller = widget.controller ?? TextEditingController();
    focusNode = widget.focusNode ?? FocusNode();
    enabled = widget.item.id == null && widget.enabled;
    controller.text =
        widget.item.description ?? (enabled ? '' : 'Tap to add description');

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enabled && enabled && !focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNode.requestFocus();
      });
    }

    return GestureDetector(
      onTap: enabled
          ? null
          : () {
              setState(() {
                enabled = widget.enabled;
              });
            },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: CLTextField.multiLine(
              controller,
              focusNode: focusNode,
              hint: enabled
                  ? 'What is the best thing,'
                      ' you can say about this?'
                  : 'Tap to add description',
              maxLines: 5,
              enabled: enabled,
            ),
          ),
          if (enabled && (widget.onDiscard != null || widget.onDone != null))
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CLButtonText.large(
                  'Discard',
                  onTap: () {
                    setState(() {
                      controller.text = widget.item.description ?? '';
                      enabled = false;
                    });
                    widget.onDiscard?.call();
                  },
                ),
                if (widget.onDone != null)
                  const CLButtonText.large('Update')
                else
                  Container(),
              ],
            ),
        ],
      ),
    );
  }
}
