import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../store_service/providers/store_cache.dart';
import '../../../store_service/widgets/builders.dart';
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
    return GetStore(
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
                          id: note.id!,
                          builder: (uri) {
                            return AudioChip(
                              uri.path, // FIXME won't work for http(s)
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
                                ref
                                    .read(storeCacheProvider.notifier)
                                    .deleteMediaById(theStore, note.id!);
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
