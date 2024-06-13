import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'text_note.dart';

class TextNotes extends StatelessWidget {
  const TextNotes({
    required this.notes,
    required this.onUpsertNote,
    required this.onDeleteNote,
    required this.tempDir,
    super.key,
  });
  final List<CLTextNote> notes;
  final Future<void> Function(CLNote note) onUpsertNote;
  final Directory tempDir;
  final Future<void> Function(CLNote note) onDeleteNote;

  @override
  Widget build(BuildContext context) {
    return TextNote(
      note: notes.firstOrNull,
      onUpsertNote: onUpsertNote,
      onDeleteNote: onDeleteNote,
      tempDir: tempDir,
    );
  }
}
