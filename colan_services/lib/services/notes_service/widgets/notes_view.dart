import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import 'audio_notes.dart';
import 'text_notes.dart';

class NotesView extends StatefulWidget {
  const NotesView({
    required this.media,
    required this.notes,
    required this.appSettings,
    required this.dbManager,
    required this.onClose,
    super.key,
  });
  final CLMedia media;
  final List<CLNote> notes;
  final AppSettings appSettings;
  final DBManager dbManager;
  final VoidCallback onClose;

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    final textNotes = widget.notes
        .where(
          (e) {
            return e.type == CLNoteTypes.text;
          },
        )
        .map((e) => e as CLTextNote)
        .toList();
    final audioNotes = widget.notes
        .where(
          (e) {
            return e.type == CLNoteTypes.audio;
          },
        )
        .map((e) => e as CLAudioNote)
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 2,
                  color: Colors.grey,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: CLText.large('Notes'),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CLButtonText.small(
                    'Hide',
                    color: Colors.blue,
                    onTap: widget.onClose,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: kMinInteractiveDimension * 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: AudioNotes(
                  tempDir: widget.appSettings.directories.tempNotes.path,
                  media: widget.media,
                  notes: audioNotes,
                  onUpsertNote: onUpsertNote,
                  onDeleteNote: onDeleteNote,
                ),
              ),
            ),
            SizedBox(
              height: kMinInteractiveDimension * 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TextNotes(
                  tempDir: widget.appSettings.directories.tempNotes.path,
                  notes: textNotes,
                  onUpsertNote: onUpsertNote,
                  onDeleteNote: onDeleteNote,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onUpsertNote(CLNote note) async {
    await widget.dbManager.upsertNote(
      note,
      [widget.media],
      onSaveNote: (note1, {required targetDir}) async {
        return note1.moveFile(targetDir: targetDir);
      },
    );
  }

  Future<void> onDeleteNote(CLNote note) async {
    if (note.id == null) return;
    await widget.dbManager.deleteNote(
      note,
      onDeleteFile: (file) async {
        await file.deleteIfExists();
      },
    );
  }
}
