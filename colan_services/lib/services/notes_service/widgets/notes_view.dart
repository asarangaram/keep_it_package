import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import 'audio/audio_notes.dart';
import 'text/text_notes.dart';

class NotesView extends StatefulWidget {
  const NotesView({
    required this.media,
    required this.onClose,
    super.key,
  });
  final CLMedia media;

  final VoidCallback onClose;

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 2,
                  color: Colors.grey,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: CLText.large('Notes'),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CLButtonText.small(
                    'Hide',
                    color: Colors.blue,
                    onTap: widget.onClose,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: kMinInteractiveDimension * 5,
              child: GetNotesByMediaId(
                errorBuilder: (_, __) {
                  throw UnimplementedError('errorBuilder');
                },
                loadingBuilder: () => CLLoader.widget(
                  debugMessage: 'GetNotesByMediaId',
                ),
                mediaId: widget.media.id!,
                builder: (notes) {
                  final textNotes = notes.where(
                    (e) {
                      return e.type == CLMediaType.text;
                    },
                  ).toList();
                  final audioNotes = notes.where(
                    (e) {
                      return e.type == CLMediaType.audio;
                    },
                  ).toList();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ColanPlatformSupport.isMobilePlatform ||
                          audioNotes.isNotEmpty)
                        SizedBox(
                          height: kMinInteractiveDimension * 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: AudioNotes(
                              media: widget.media,
                              notes: audioNotes,
                            ),
                          ),
                        ),
                      SizedBox(
                        height: kMinInteractiveDimension * 3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: TextNotes(
                            media: widget.media,
                            notes: textNotes,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
