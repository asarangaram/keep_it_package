import 'dart:io';

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
    required this.tempDir,
    super.key,
  });
  final CLMedia media;
  final List<CLAudioNote> notes;
  final Future<void> Function(CLNote note) onUpsertNote;
  final Future<void> Function(CLNote note) onDeleteNote;
  final Directory tempDir;
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
      tempDir: widget.tempDir,
      onUpsertNote: widget.onUpsertNote,
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
                        onDeleteNote: () => widget.onDeleteNote(note),
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}
