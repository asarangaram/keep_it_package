import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/notes_view.dart';

class NotesService extends ConsumerWidget {
  const NotesService({
    required this.media,
    required this.notes,
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotesView(
      onCreateNewFile: onCreateNewFile,
      notes: notes,
      media: media,
      onUpsertNote: onUpsertNote,
      onDeleteNote: onDeleteNote,
      onClose: () {
        ref.read(showControlsProvider.notifier).hideNotes();
      },
    );
  }
}
