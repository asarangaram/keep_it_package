
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import 'widgets/text_note.dart';

class NotesView extends StatefulWidget {
  const NotesView({required this.media, super.key, this.onClose});
  final CLMedia media;
  final VoidCallback? onClose;

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return GetAppSettings(
      builder: (appSettings) {
        return GetDBManager(
          builder: (dbManager) {
            return GetNotesByMediaId(
              mediaId: widget.media.id!,
              buildOnData: (notes) {
                final textNote = notes.where(
                  (e) {
                    return e.type == CLNoteTypes.text;
                  },
                ).firstOrNull as CLTextNote?;

                return TextNote(
                  tempDir: appSettings.directories.cacheDir,
                  note: textNote,
                  onNewNote: (CLNote note) async {
                    await dbManager.upsertNote(
                      note,
                      [widget.media],
                      onSaveNote: (note1, {required targetDir}) async {
                        return note1.moveFile(targetDir: targetDir);
                      },
                    );
                  },
                  onClose: widget.onClose,
                );
              },
            );
          },
        );
      },
    );
  }
}

