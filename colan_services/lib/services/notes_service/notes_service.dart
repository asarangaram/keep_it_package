import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/notes_view.dart';

class NotesService extends ConsumerWidget {
  const NotesService({
    required this.media,
    required this.notes,
    required this.onCreateNewFile,
    required this.onUpsertNote,
    required this.onDeleteNote,
    super.key,
  });
  final CLMedia media;
  final List<CLNote> notes;
  final Future<String> Function({required String ext}) onCreateNewFile;
  final Future<void> Function(CLMedia media, CLNote note) onUpsertNote;
  final Future<void> Function(CLNote note) onDeleteNote;
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
