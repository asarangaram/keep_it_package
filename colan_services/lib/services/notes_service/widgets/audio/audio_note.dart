// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class AudioNote extends StatefulWidget {
  const AudioNote(
    this.note, {
    required this.onDeleteNote,
    super.key,
    this.editMode = true,
    this.onEditMode,
  });

  final CLAudioNote note;
  final bool editMode;
  final VoidCallback? onEditMode;
  final VoidCallback onDeleteNote;

  @override
  State<AudioNote> createState() => _AudioNoteState();
}

class _AudioNoteState extends State<AudioNote> {
  late PlayerController controller;
  late StreamSubscription<PlayerState>? playerStateSubscription;
  late bool validAudio;
  late String notePath;

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
  }

  @override
  void didChangeDependencies() {
    notePath = TheStore.of(context).getNotesPath(widget.note);
    if (File(notePath).existsSync()) {
      validAudio = true;
      _preparePlayer();
    } else {
      validAudio = false;
    }
    super.didChangeDependencies();
  }

  Future<void> _preparePlayer() async {
    await controller.preparePlayer(path: notePath, noOfSamples: 200);
    playerStateSubscription = controller.onPlayerStateChanged.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    playerStateSubscription?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context).noteTheme;
    final playerWaveStyle = theme.playerWaveStyle;

    final label = widget.note.createdDate.toSQL() ?? 'No Date';
    return CLCustomChip(
      avatar: validAudio
          ? CLIcon.tiny(
              widget.editMode
                  ? Icons.delete
                  : controller.playerState.isPlaying
                      ? Icons.stop
                      : Icons.play_arrow,
              color: widget.editMode ? Colors.red : theme.foregroundColor,
            )
          : null,
      label: controller.playerState.isPlaying
          ? AudioFileWaveforms(
              size: const Size(100, 20),
              playerController: controller,
              playerWaveStyle: playerWaveStyle,
              continuousWaveform: theme.continuousWaveform,
            )
          : SizedBox.fromSize(
              size: const Size(100, 20),
              child: FittedBox(
                child: CLText.standard(
                  label,
                  textAlign: TextAlign.start,
                  color: validAudio ? null : Colors.red,
                ),
              ),
            ),
      onTap: () async {
        if (widget.editMode) {
          widget.onDeleteNote();
        } else if (validAudio) {
          controller.playerState.isPlaying
              ? await controller.pausePlayer()
              : await controller.startPlayer(
                  finishMode: FinishMode.pause,
                );
        }
      },
      onLongPress: widget.onEditMode,
    );
  }
}
