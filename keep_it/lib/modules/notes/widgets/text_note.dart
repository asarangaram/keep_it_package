import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';

class TextNote extends StatefulWidget {
  const TextNote({
    required this.onNewNote,
    required this.tempDir,
    super.key,
    this.note,
  });
  final CLTextNote? note;
  final Future<void> Function(CLNote note) onNewNote;
  final Directory tempDir;

  @override
  State<TextNote> createState() => _TextNoteState();
}

class _TextNoteState extends State<TextNote> {
  late final TextEditingController textEditingController;
  late final FocusNode focusNode;
  late bool isEditing;

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController(text: widget.note?.text);
    isEditing = widget.note == null;
    focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    textEditingController.text = widget.note?.text ?? '';
    isEditing = widget.note == null;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: () {
            setState(() {
              isEditing = !isEditing;
            });
          },
          child: AbsorbPointer(
            absorbing: !isEditing,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: InputDecorator(
                decoration: isEditing
                    ? FormDesign.inputDecoration(
                        context,
                        label: 'Add Notes',
                        hintText: 'Add Notes',
                        actionBuilder: null,
                      )
                    : const InputDecoration(border: InputBorder.none),
                child: TextField(
                  enabled: isEditing,
                  showCursor: true,
                  controller: textEditingController,
                  focusNode: focusNode,
                  maxLines: 5,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: CLScaleType.standard.fontSize),
                  decoration: InputDecoration(
                    suffixIcon: isEditing
                        ? CLButtonIcon.large(
                            Icons.check,
                            onTap: () async {
                              if (textEditingController.text
                                      .trim()
                                      .isNotEmpty &&
                                  textEditingController.text !=
                                      widget.note?.text) {}
                              isEditing = false;
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get hasTextMessage => textEditingController.text.isNotEmpty;
}
