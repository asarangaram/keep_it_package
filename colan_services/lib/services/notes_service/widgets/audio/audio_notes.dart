import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import 'audio_note.dart';
import 'audio_recorder.dart';

class AudioNotes extends StatefulWidget {
  const AudioNotes({
    required this.media,
    required this.notes,
    super.key,
  });
  final CLMedia media;
  final List<CLMedia> notes;

  @override
  State<AudioNotes> createState() => _AudioNotesState();
}

class _AudioNotesState extends State<AudioNotes> {
  late bool editMode;

  @override
  void didChangeDependencies() {
    editMode = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final audioNotes = widget.notes.isEmpty
        ? const SizedBox.shrink()
        : GetStoreManager(
            builder: (theStore) {
              return SingleChildScrollView(
                child: Wrap(
                  runSpacing: 2,
                  spacing: 2,
                  children: widget.notes
                      .map(
                        (note) => AudioChip(
                          theStore.getValidMediaPath(note).path,
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
                            theStore.deleteMedia(note);
                          },
                        ),
                      )
                      .toList(),
                ),
              );
            },
          );
    if (!ColanPlatformSupport.isMobilePlatform) {
      return audioNotes;
    }
    return GetStoreManager(
      builder: (theStore) {
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
