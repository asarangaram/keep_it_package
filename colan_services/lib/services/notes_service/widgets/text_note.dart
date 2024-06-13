import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../models/input_decoration.dart';

class TextNote extends StatefulWidget {
  const TextNote({
    required this.onUpsertNote,
    required this.onDeleteNote,
    required this.tempDir,
    super.key,
    this.note,
  });
  final CLTextNote? note;
  final Future<void> Function(CLNote note) onUpsertNote;
  final Directory tempDir;
  final Future<void> Function(CLNote note) onDeleteNote;

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
    if (!isEditing) {
      return GestureDetector(
        onTap: () {
          setState(() {
            isEditing = !isEditing;
          });
        },
        child: SingleChildScrollView(
          child: Text(
            widget.note!.text,
            textAlign: TextAlign.justify,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontSize: CLScaleType.standard.fontSize),
          ),
        ),
      );
    }
    return Row(
      children: [
        Flexible(
          child: InputDecorator(
            decoration: isEditing
                ? NotesTextFieldDecoration.inputDecoration(
                    context,
                    label: 'Add Notes',
                    hintText: 'Add Notes',
                    actionBuilder: null,
                  )
                : const InputDecoration(border: InputBorder.none),
            child: TextField(
              scrollPhysics: const AlwaysScrollableScrollPhysics(),
              showCursor: true,
              controller: textEditingController,
              focusNode: focusNode,
              maxLines: 5,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontSize: CLScaleType.standard.fontSize),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 4, bottom: 4),
              ),
            ),
          ),
        ),
        if (isEditing)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CLButtonIcon.large(
                  MdiIcons.undoVariant,
                  onTap: () {
                    if (textModified) {
                      if (widget.note != null) {
                        textEditingController.text = widget.note!.text;
                      } else {
                        textEditingController.clear();
                      }
                    }
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                CLButtonIcon.large(
                  Icons.save,
                  onTap: onEditDone,
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool get textModified =>
      textEditingController.text.trim().isNotEmpty &&
      textEditingController.text != widget.note?.text;

  Future<void> onEditDone() async {
    if (textModified) {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyyMMdd_HHmmss_SSS').format(now);
      final path = '${widget.tempDir.path}/note_$formattedDate.txt';
      await File(path).writeAsString(
        textEditingController.text.trim(),
      );

      if (widget.note != null) {
        await widget.onUpsertNote(
          widget.note!.copyWith(
            createdDate: DateTime.now(),
            path: path,
          ),
        );
        // delete old Note;
        final f = File(widget.note!.path);
        await f.deleteIfExists();
      } else {
        // Write  to file.
        await widget.onUpsertNote(
          CLTextNote(
            createdDate: DateTime.now(),
            path: path,
            id: null,
          ),
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
