import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

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
      return ViewNotes(
        note: widget.note!,
        onTap: () => setState(enableEdit),
        controls: [
          Container(),
          CLButtonIcon.small(
            MdiIcons.delete,
            onTap: () {
              widget.onDeleteNote(widget.note!);

              textEditingController.clear();
            },
          ),
        ],
      );
    }
    return EditNotes(
      controller: textEditingController,
      focusNode: focusNode,
      note: widget.note,
      onTap: () {
        textModified = textEditingController.text.trim().isNotEmpty &&
            textEditingController.text.trim() != widget.note?.text;
        setState(() {});
      },
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
        ] else if (widget.note != null)
          CLButtonIcon.small(MdiIcons.close, onTap: onEditDone)
        else if (focusNode.hasFocus)
          CLButtonIcon.small(
            MdiIcons.keyboardClose,
            onTap: () {
              focusNode.unfocus();
            },
          ),
      ],
    );
  }

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

class EditNotes extends StatelessWidget {
  const EditNotes({
    required this.controller,
    required this.note,
    required this.onTap,
    required this.controls,
    this.focusNode,
    super.key,
  });
  final TextEditingController controller;
  final FocusNode? focusNode;
  final CLTextNote? note;
  final VoidCallback? onTap;
  final List<Widget>? controls;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InputDecorator(
            decoration: NotesTextFieldDecoration.inputDecoration(
              context,
              label: 'Add Notes',
              hintText: 'Add Notes',
              actionBuilder: null,
            ),
            child: TextField(
              showCursor: true,
              controller: controller,
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
              onChanged: (s) => onTap?.call(),
            ),
          ),
        ),
        if (controls != null)
          SizedBox(
            height: double.infinity,
            width: kMinInteractiveDimension,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: controls!,
            ),
          ),
      ],
    );
  }
}

class ViewNotes extends StatelessWidget {
  const ViewNotes({required this.note, super.key, this.onTap, this.controls});
  final CLTextNote note;
  final VoidCallback? onTap;
  final List<Widget>? controls;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InputDecorator(
            decoration: NotesTextFieldDecoration.inputDecoration(
              context,
              hintText: 'Add Notes',
              actionBuilder: null,
              hasBorder: false,
            ),
            child: SizedBox(
              height: double.infinity,
              child: GestureDetector(
                onTap: onTap,
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Text(
                    note.text,
                    textAlign: TextAlign.start,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: CLScaleType.standard.fontSize),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (controls != null)
          SizedBox(
            height: double.infinity,
            width: kMinInteractiveDimension,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: controls!,
            ),
          ),
      ],
    );
  }
}
