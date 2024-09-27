import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import 'text_note.dart';

class TextNotes extends StatelessWidget {
  const TextNotes({
    required this.media,
    required this.notes,
    super.key,
  });
  final List<CLMedia> notes;
  final CLMedia media;

  @override
  Widget build(BuildContext context) {
    return GetStoreUpdater(
      builder: (theStore) {
        return TextNote(
          media: media,
          theStore: theStore,
          note: notes.firstOrNull,
        );
      },
    );
  }
}
