/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../store_service/providers/media.dart';
import '../../../store_service/widgets/builders.dart';
import 'text_note.dart';

class TextNotes extends ConsumerWidget {
  const TextNotes({
    required this.media,
    required this.notes,
    super.key,
  });
  final List<CLMedia> notes;
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = notes.firstOrNull?.id;
    if(id ==null)
    {
      return TextNote(
          media: media,

    }
    final noteInfo = ref.watch(mediaProvider(id));
    return GetStore(
      builder: (theStore) {
        return TextNote(
          media: media,
          noteInfo: theStore,
          note: notes.firstOrNull,
        );
      },
    );
  }
}
 */
