import 'dart:io';

import 'package:colan_services/services/store_service/widgets/get_media_uri.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import '../../../backup_service/dialogs.dart';
import 'edit_notes.dart';
import 'text_controls.dart';
import 'view_notes.dart';

class TextNote extends ConsumerWidget {
  const TextNote({
    required this.media,
    this.note,
    super.key,
  });
  final CLMedia media;
  final CLMedia? note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (note == null) {
      return TextNote1(
        media: media,
        note: note,
      );
    }
    return GetMediaUri(
      note!,
      builder: (uri) {
        return TextNote1(
          media: media,
          note: note,
          notePath: uri.path,
        );
      },
    );
  }
}

class TextNote1 extends StatefulWidget {
  const TextNote1({
    required this.media,
    this.note,
    this.notePath,
    super.key,
  });
  final CLMedia media;
  final CLMedia? note;
  final String? notePath;

  @override
  State<TextNote1> createState() => _TextNote1State();
}

class _TextNote1State extends State<TextNote1> {
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
                  final confirmed = await ConfirmAction.deleteNote(
                        context,
                        note: widget.note!,
                      ) ??
                      false;
                  if (!confirmed) return;
                  if (context.mounted) {
                    await TheStore.of(context)
                        .deleteNote(context, widget.note!);
                    textEditingController.clear();
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
            CLMediaType.text,
            mediaMultiple: [widget.media],
            note: widget.note,
          );
        }
        textOriginal = textEditingController.text.trim();
      } else {
        path = widget.notePath!;
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
