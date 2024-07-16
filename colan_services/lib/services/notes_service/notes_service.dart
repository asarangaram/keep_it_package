import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/notes_view.dart';

class NotesService extends ConsumerWidget {
  const NotesService({
    required this.media,
    required this.notes,
    super.key,
  });
  final CLMedia media;
  final List<CLNote> notes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotesView(
      notes: notes,
      media: media,
      onClose: () {
        ref.read(showControlsProvider.notifier).hideNotes();
      },
    );
  }
}
