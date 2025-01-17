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
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
        // ignore: dead_code
      },
      loadingBuilder: () {
        throw UnimplementedError('loadingBuilder');
        // ignore: dead_code
      },
      builder: (theStore) {
        final note = notes.firstOrNull;
        if (note == null) {
          return TextNote(
            media: media,
            theStore: theStore,
          );
        }

        return GetMediaText(
          id: note.id!,
          errorBuilder: (_, __) {
            throw UnimplementedError('errorBuilder');
            // ignore: dead_code
          },
          loadingBuilder: () {
            throw UnimplementedError('loadingBuilder');
            // ignore: dead_code
          },
          builder: (text) {
            return TextNote(
              media: media,
              theStore: theStore,
              note: notes.firstOrNull,
            );
          },
        );
      },
    );
  }
}
