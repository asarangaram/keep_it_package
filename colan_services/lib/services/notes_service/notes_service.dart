import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../media_view_service/providers/show_controls.dart';
import 'widgets/notes_view.dart';

class NotesService extends ConsumerWidget {
  const NotesService({
    required this.media,
    super.key,
  });
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotesView(
      media: media,
      onClose: () {
        ref.read(showControlsProvider.notifier).hideNotes();
      },
    );
  }
}
