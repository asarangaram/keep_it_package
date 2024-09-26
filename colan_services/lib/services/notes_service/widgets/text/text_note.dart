/* import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../../../basic_page_service/dialogs.dart';
import '../../../store_service/models/store_model.dart';
import '../../../store_service/providers/media.dart';
import '../../../store_service/providers/store_cache.dart';
import 'edit_notes.dart';
import 'text_controls.dart';
import 'view_notes.dart';

class TextNote extends ConsumerStatefulWidget {
  const TextNote({
    required this.media,
    required this.noteInfo,
    super.key,
  });
  final CLMedia media;
  final MediaInfo? noteInfo;

  @override
  ConsumerState<TextNote> createState() => _TextNoteState();
}

class _TextNoteState extends ConsumerState<TextNote> {
  late final TextEditingController textEditingController;
  late final FocusNode focusNode;
  late bool isEditing;
  bool textModified = false;
  late String textOriginal;
  late final MediaInfo noteInfo;
  @override
  void initState() {
    super.initState();
    noteInfo = widget.noteInfo;

    textEditingController = TextEditingController();
    isEditing = widget.note == null;
    focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    textOriginal = noteInfo.getText();
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
                        .read(storeCacheProvider.notifier)
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
      path = await noteInfo.createTempFile(ext: 'txt');
      await File(path).writeAsString(textEditingController.text.trim());
      await ref.read(storeCacheProvider.notifier).upsertMedia(
            path,
            CLMediaType.text,
            parents: [widget.media],
            id: widget.note?.id,
            isAux: true,
          );

      if (mounted) {
        textOriginal = noteInfo.getText();
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
 */
