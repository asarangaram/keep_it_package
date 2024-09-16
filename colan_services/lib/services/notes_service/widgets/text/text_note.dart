import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../../../basic_page_service/dialogs.dart';
import '../../../store_service/models/store_model.dart';
import '../../../store_service/providers/store.dart';
import 'edit_notes.dart';
import 'text_controls.dart';
import 'view_notes.dart';

class TextNote extends ConsumerStatefulWidget {
  const TextNote({
    required this.media,
    required this.theStore,
    this.note,
    super.key,
  });
  final CLMedia media;
  final CLMedia? note;
  final StoreCache theStore;

  @override
  ConsumerState<TextNote> createState() => _TextNoteState();
}

class _TextNoteState extends ConsumerState<TextNote> {
  late final TextEditingController textEditingController;
  late final FocusNode focusNode;
  late bool isEditing;
  bool textModified = false;
  late String textOriginal;
  late final StoreCache theStore;
  @override
  void initState() {
    super.initState();
    theStore = widget.theStore;

    textEditingController = TextEditingController();
    isEditing = widget.note == null;
    focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    textOriginal = theStore.getText(widget.note);
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
                clIcons.deleteNote,
                onTap: () async {
                  final confirmed = await ConfirmAction.deleteNote(
                        context,
                        note: widget.note!,
                      ) ??
                      false;
                  if (!confirmed) return;
                  if (context.mounted) {
                    await ref
                        .read(storeProvider.notifier)
                        .permanentlyDeleteMediaMultiple({widget.note!.id!});
                    textEditingController.clear();
                    textOriginal = '';
                  }
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
                clIcons.undoNote,
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
              CLButtonIcon.small(clIcons.save, onTap: onEditDone),
            ] else if (widget.note != null) ...[
              Container(),
              CLButtonIcon.small(clIcons.discardChangeNote, onTap: onEditDone),
            ] else if (focusNode.hasFocus) ...[
              Container(),
              CLButtonIcon.small(
                clIcons.hideKeyboard,
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
      path = await theStore.createTempFile(ext: 'txt');
      await File(path).writeAsString(textEditingController.text.trim());
      await ref.read(storeProvider.notifier).upsertMedia(
            path,
            CLMediaType.text,
            parents: [widget.media],
            id: widget.note?.id,
            isAux: true,
          );

      if (mounted) {
        textOriginal = theStore.getText(widget.note);
      }

      isEditing = false;
      if (mounted) {
        setState(() {});
      }
    } else if (widget.note != null) {
      isEditing = false;
      setState(() {});
    }
  }

  bool get hasTextMessage => textEditingController.text.isNotEmpty;
}
