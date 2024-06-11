import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'note_view.dart';

class ShowNotes extends StatelessWidget {
  const ShowNotes({
    required this.messages,
    super.key,
  });

  final List<CLNote> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final m = messages[index];

        return NoteView(
          note: m,
          //   width: MediaQuery.of(context).size.width / 2,
          isMessage: true,
        );
      },
    );
  }
}
