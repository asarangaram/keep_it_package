import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'text_note.dart';

class TextNotes extends StatelessWidget {
  const TextNotes({
    required this.media,
    required this.notes,
    super.key,
  });
  final List<CLTextNote> notes;
  final CLMedia media;

  @override
  Widget build(BuildContext context) {
    return TextNote(
      media: media,
      note: notes.firstOrNull,
    );
  }
}
