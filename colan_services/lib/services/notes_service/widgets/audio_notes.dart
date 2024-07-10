import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'audio_note.dart';
import 'audio_recorder.dart';

class AudioNotes extends StatefulWidget {
  const AudioNotes({
    required this.media,
    required this.notes,
    required this.onUpsertNote,
    required this.onDeleteNote,
    required this.onCreateNewAudioFile,
    super.key,
  });
  final CLMedia media;
  final List<CLAudioNote> notes;
  final Future<void> Function(CLMedia media, CLNote note) onUpsertNote;
  final Future<void> Function(CLNote note) onDeleteNote;
  final Future<String> Function() onCreateNewAudioFile;
  @override
  State<AudioNotes> createState() => _AudioNotesState();
}

class _AudioNotesState extends State<AudioNotes> {
  late bool editMode;

  @override
  void didChangeDependencies() {
    editMode = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AudioRecorder(
      onCreateNewAudioFile: widget.onCreateNewAudioFile,
      onUpsertNote: (note) => widget.onUpsertNote(widget.media, note),
      editMode: editMode && widget.notes.isNotEmpty,
      onEditCancel: () => setState(() {
        editMode = false;
      }),
      child: widget.notes.isEmpty
          ? null
          : SingleChildScrollView(
              child: Wrap(
                runSpacing: 2,
                spacing: 2,
                children: widget.notes
                    .map(
                      (note) => AudioNote(
                        note,
                        editMode: editMode && widget.notes.isNotEmpty,
                        onEditMode: () {
                          setState(() {
                            if (widget.notes.isNotEmpty) {
                              editMode = true;
                            }
                          });
                        },
                        onDeleteNote: () {
                          if (widget.notes.length == 1) {
                            editMode = false;
                          }
                          widget.onDeleteNote(note);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}
