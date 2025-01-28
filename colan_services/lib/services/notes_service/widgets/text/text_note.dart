import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../../../basic_page_service/widgets/dialogs.dart';
import 'edit_notes.dart';
import 'text_controls.dart';
import 'view_notes.dart';

class TextNote extends ConsumerWidget {
  const TextNote({
    required this.media,
    required this.theStore,
    this.note,
    super.key,
  });
  final CLMedia media;
  final CLMedia? note;
  final StoreUpdater theStore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (note == null) {
      return TextNote0(
        media: media,
        theStore: theStore,
        note: note,
        textOriginal: '',
      );
    }
    return GetMediaText(
      id: note!.id!,
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetMediaText',
      ),
      builder: (text) {
        return TextNote0(
          media: media,
          theStore: theStore,
          note: note,
          textOriginal: text,
        );
      },
    );
  }
}

class TextNote0 extends ConsumerStatefulWidget {
  const TextNote0({
    required this.media,
    required this.theStore,
    required this.textOriginal,
    this.note,
    super.key,
  });
  final CLMedia media;
  final CLMedia? note;
  final StoreUpdater theStore;
  final String textOriginal;

  @override
  ConsumerState<TextNote0> createState() => _TextNote0State();
}

class _TextNote0State extends ConsumerState<TextNote0> {
  late final TextEditingController textEditingController;
  late final FocusNode focusNode;
  late bool isEditing;
  bool textModified = false;

  late final StoreUpdater theStore;
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
    textEditingController.text = widget.textOriginal;
    isEditing = widget.note == null;
    textModified = textEditingController.text.trim().isNotEmpty &&
        textEditingController.text.trim() != widget.textOriginal;
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
                  final confirmed = await DialogService.deleteNote(
                        context,
                        note: widget.note!,
                      ) ??
                      false;
                  if (!confirmed) return;
                  if (context.mounted) {
                    await theStore.mediaUpdater.deletePermanently(
                      widget.note!.id!,
                    );
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
                  textEditingController.text.trim() != widget.textOriginal;
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
                    textEditingController.text = widget.textOriginal;
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
      path = theStore.createTempFile(ext: 'txt');
      await File(path).writeAsString(textEditingController.text.trim());
      if (widget.note == null) {
        await theStore.mediaUpdater.create(
          path,
          type: CLMediaType.text,
          parents: [widget.media],
          isAux: () => true,
        );
      } else {
        await theStore.mediaUpdater.replaceContent(path, media: widget.note!);
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
