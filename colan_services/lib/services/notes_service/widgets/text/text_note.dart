import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'edit_notes.dart';
import 'text_controls.dart';
import 'view_notes.dart';

class TextNote extends StatefulWidget {
  const TextNote({
    required this.onUpsertNote,
    required this.onDeleteNote,
    required this.onCreateNewTextFile,
    super.key,
    this.note,
  });
  final CLTextNote? note;
  final Future<String> Function() onCreateNewTextFile;
  final Future<void> Function(
    String path,
    CLNoteTypes type, {
    CLNote? note,
  }) onUpsertNote;

  final Future<void> Function(
    CLNote note, {
    required bool? confirmed,
  }) onDeleteNote;

  @override
  State<TextNote> createState() => _TextNoteState();
}

class _TextNoteState extends State<TextNote> {
  late final TextEditingController textEditingController;
  late final FocusNode focusNode;
  late bool isEditing;
  bool textModified = false;

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
    textModified = textEditingController.text.trim().isNotEmpty &&
        textEditingController.text.trim() != widget.note?.text;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void enableEdit() {
    isEditing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!isEditing && widget.note != null) {
      return Row(
        children: [
          Expanded(
            child: ViewNotes(
              note: widget.note!,
              onTap: () => setState(enableEdit),
            ),
          ),
          TextControls(
            controls: [
              Container(),
              CLButtonIcon.small(
                MdiIcons.delete,
                onTap: () async {
                  await ConfirmAction.deleteNote(
                    context,
                    note: widget.note!,
                    onConfirm: () async {
                      await widget.onDeleteNote(widget.note!, confirmed: true);
                      textEditingController.clear();
                      return true;
                    },
                  );
                },
              ),
            ],
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: EditNotes(
            controller: textEditingController,
            focusNode: focusNode,
            note: widget.note,
            onTap: () {
              textModified = textEditingController.text.trim().isNotEmpty &&
                  textEditingController.text.trim() != widget.note?.text;
              setState(() {});
            },
          ),
        ),
        TextControls(
          controls: [
            if (textModified) ...[
              CLButtonIcon.small(
                MdiIcons.undoVariant,
                onTap: () {
                  if (widget.note != null) {
                    textEditingController.text = widget.note!.text;
                  } else {
                    textEditingController.clear();
                  }
                  textModified = false;
                  setState(() {});
                },
              ),
              CLButtonIcon.small(MdiIcons.contentSave, onTap: onEditDone),
            ] else if (widget.note != null) ...[
              Container(),
              CLButtonIcon.small(MdiIcons.close, onTap: onEditDone),
            ] else if (focusNode.hasFocus) ...[
              Container(),
              CLButtonIcon.small(
                MdiIcons.keyboardClose,
                onTap: () {
                  focusNode.unfocus();
                },
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> onEditDone() async {
    if (textModified) {
      final path = await widget.onCreateNewTextFile();
      await File(path).writeAsString(
        textEditingController.text.trim(),
      );

      if (widget.note != null) {
        await widget.onUpsertNote(path, CLNoteTypes.text);
      } else {
        // Write  to file.
        await widget.onUpsertNote(
          path,
          CLNoteTypes.text,
          note: widget.note,
        );
      }

      isEditing = false;
      setState(() {});
    } else if (widget.note != null) {
      isEditing = false;
      setState(() {});
    }
  }

  bool get hasTextMessage => textEditingController.text.isNotEmpty;
}
