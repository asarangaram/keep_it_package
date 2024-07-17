import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'edit_notes.dart';
import 'text_controls.dart';
import 'view_notes.dart';

class TextNote extends StatefulWidget {
  const TextNote({
    required this.media,
    this.note,
    super.key,
  });
  final CLMedia media;
  final CLTextNote? note;

  @override
  State<TextNote> createState() => _TextNoteState();
}

class _TextNoteState extends State<TextNote> {
  late final TextEditingController textEditingController;
  late final FocusNode focusNode;
  late bool isEditing;
  bool textModified = false;
  late String textOriginal;
  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController();
    isEditing = widget.note == null;
    focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    textOriginal = TheStore.of(context).getText(widget.note);
    textEditingController.text = textOriginal;
    isEditing = widget.note == null;
    textModified = textEditingController.text.trim().isNotEmpty &&
        textEditingController.text.trim() != textOriginal;
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
                  await TheStore.of(context).deleteNote(widget.note!);
                  textEditingController.clear();
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
                  textEditingController.text.trim() != textOriginal;
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
                    textEditingController.text = textOriginal;
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
      final String path;
      if (widget.note == null) {
        path = await TheStore.of(context).createTempFile(ext: 'txt');
        await File(path).writeAsString(textEditingController.text.trim());

        if (mounted) {
          await TheStore.of(context).upsertNote(
            path,
            CLNoteTypes.text,
            mediaMultiple: [widget.media],
            note: widget.note,
          );
        }
        textOriginal = textEditingController.text.trim();
      } else {
        path = TheStore.of(context).getNotesPath(widget.note!);
        await File(path).writeAsString(textEditingController.text.trim());
        if (mounted) {
          textOriginal = TheStore.of(context).getText(widget.note);
        }
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
