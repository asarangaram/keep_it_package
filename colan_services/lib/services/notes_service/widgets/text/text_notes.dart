import 'package:flutter/material.dart';
import 'package:store/store.dart';

import 'text_note.dart';

class TextNotes extends StatelessWidget {
  const TextNotes({
    required this.media,
    required this.notes,
    super.key,
  });
  final List<CLNote> notes;
  final CLMedia media;

  @override
  Widget build(BuildContext context) {
    return TextNote(
      media: media,
      note: notes.firstOrNull,
    );
  }
}
