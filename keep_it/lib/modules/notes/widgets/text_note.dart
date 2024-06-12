import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class TextNote extends StatelessWidget {
  const TextNote({
    required this.onNewNote,
    required this.tempDir,
    super.key,
    this.note,
    this.onClose,
  });
  final CLTextNote? note;
  final Future<void> Function(CLNote note) onNewNote;
  final Directory tempDir;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        
        SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: TextNoteView(
                onNewNote: onNewNote,
                note: note,
                tempDir: tempDir,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TextNoteView extends StatefulWidget {
  const TextNoteView({
    required this.onNewNote,
    required this.tempDir,
    super.key,
    this.note,
    this.onClose,
  });
  final CLTextNote? note;
  final Future<void> Function(CLNote note) onNewNote;
  final Directory tempDir;
  final VoidCallback? onClose;

  @override
  State<TextNoteView> createState() => _TextNoteViewState();
}

class _TextNoteViewState extends State<TextNoteView> {
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
    return InputDecorator(
      decoration: isEditing
          ? FormDesign.inputDecoration(
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
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 4, bottom: 4),
          suffixIcon: isEditing
              ? CLButtonIcon.large(
                  Icons.check,
                  onTap: onEditDone,
                )
              : null,
        ),
      ),
    );
  }

  Future<void> onEditDone() async {
    if (textEditingController.text.trim().isNotEmpty &&
        textEditingController.text != widget.note?.text) {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyyMMdd_HHmmss_SSS').format(now);
      final path = '${widget.tempDir.path}/note_$formattedDate.txt';
      await File(path).writeAsString(
        textEditingController.text.trim(),
      );

      if (widget.note != null) {
        await widget.onNewNote(
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
        await widget.onNewNote(
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
