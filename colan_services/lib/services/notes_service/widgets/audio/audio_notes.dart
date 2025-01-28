import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import 'audio_note.dart';
import 'audio_recorder.dart';

class AudioNotes extends ConsumerStatefulWidget {
  const AudioNotes({
    required this.media,
    required this.notes,
    super.key,
  });
  final CLMedia media;
  final List<CLMedia> notes;

  @override
  ConsumerState<AudioNotes> createState() => _AudioNotesState();
}

class _AudioNotesState extends ConsumerState<AudioNotes> {
  late bool editMode;

  @override
  void didChangeDependencies() {
    editMode = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GetStoreUpdater(
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetStoreUpdater',
      ),
      builder: (theStore) {
        final audioNotes = widget.notes.isEmpty
            ? const SizedBox.shrink()
            : SingleChildScrollView(
                child: Wrap(
                  runSpacing: 2,
                  spacing: 2,
                  children: widget.notes
                      .map(
                        (note) => GetMediaUri(
                          errorBuilder: (_, __) {
                            throw UnimplementedError('errorBuilder');
                          },
                          loadingBuilder: () => CLLoader.widget(
                            debugMessage: 'GetMediaUri',
                          ),
                          id: note.id!,
                          builder: (uri) {
                            if (uri != null && uri.scheme != 'file') {
                              throw UnimplementedError(
                                'Audio notes not implemented for server items',
                              );
                            }
                            return AudioChip(
                              uri!.path,
                              label: note.name,
                              editMode: editMode && widget.notes.isNotEmpty,
                              onEditMode: () {
                                setState(() {
                                  if (widget.notes.isNotEmpty) {
                                    editMode = true;
                                  }
                                });
                              },
                              onDeleteNote: () {
                                if (widget.notes.length == 1) {
                                  editMode = false;
                                }
                                theStore.mediaUpdater.delete(note.id!);
                              },
                            );
                          },
                        ),
                      )
                      .toList(),
                ),
              );
        if (!ColanPlatformSupport.isMobilePlatform) {
          return audioNotes;
        }

        return AudioRecorder(
          media: widget.media,
          theStore: theStore,
          editMode: editMode && widget.notes.isNotEmpty,
          onEditCancel: () => setState(() {
            editMode = false;
          }),
          child: audioNotes,
        );
      },
    );
  }
}
