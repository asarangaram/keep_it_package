import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'audio/audio_notes.dart';
import 'text/text_notes.dart';

class NotesView extends StatefulWidget {
  const NotesView({
    required this.media,
    required this.notes,
    required this.onClose,
    required this.onUpsertNote,
    required this.onDeleteNote,
    required this.onCreateNewFile,
    super.key,
  });
  final CLMedia media;
  final List<CLNote> notes;
  final Future<void> Function(
    String path,
    CLNoteTypes type, {
    required List<CLMedia> media,
    CLNote? note,
  }) onUpsertNote;
  final Future<void> Function(
    CLNote note, {
    required bool? confirmed,
  }) onDeleteNote;
  final Future<String> Function({required String ext}) onCreateNewFile;
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
                  onCreateNewAudioFile: () =>
                      widget.onCreateNewFile(ext: 'aac'),
                  media: widget.media,
                  notes: audioNotes,
                  onUpsertNote: widget.onUpsertNote,
                  onDeleteNote: widget.onDeleteNote,
                ),
              ),
            ),
            SizedBox(
              height: kMinInteractiveDimension * 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TextNotes(
                  onCreateNewTextFile: () => widget.onCreateNewFile(ext: 'txt'),
                  notes: textNotes,
                  onUpsertNote: (path, type, {note}) async {
                    await widget.onUpsertNote(
                      path,
                      type,
                      note: note,
                      media: [widget.media],
                    );
                  },
                  onDeleteNote: widget.onDeleteNote,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
