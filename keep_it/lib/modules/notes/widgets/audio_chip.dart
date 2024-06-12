// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AudioChip extends StatefulWidget {
  const AudioChip(
    this.note, {
    required this.theme,
    required this.onDeleteNote,
    super.key,
    this.editMode = true,
    this.onEditMode,
  });

  final CLAudioNote note;
  final NotesTheme theme;
  final bool editMode;
  final VoidCallback? onEditMode;
  final VoidCallback onDeleteNote;

  @override
  State<AudioChip> createState() => _AudioChipState();
}

class _AudioChipState extends State<AudioChip> {
  late PlayerController controller;
  late StreamSubscription<PlayerState>? playerStateSubscription;
  late bool validAudio;

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    if (File(widget.note.path).existsSync()) {
      _preparePlayer();
      playerStateSubscription = controller.onPlayerStateChanged.listen((_) {
        setState(() {});
      });
      validAudio = true;
    } else {
      validAudio = false;
    }
  }

  Future<void> _preparePlayer() async =>
      controller.preparePlayer(path: widget.note.path, noOfSamples: 200);

  @override
  void dispose() {
    playerStateSubscription?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerWaveStyle = widget.theme.playerWaveStyle;
    return GestureDetector(
      onTap: () async {
        if (widget.editMode) {
          widget.onDeleteNote();
        } else {
          controller.playerState.isPlaying && validAudio
              ? await controller.pausePlayer()
              : await controller.startPlayer(
                  finishMode: FinishMode.pause,
                );
        }
      },
      onLongPress: widget.onEditMode,
      child: AbsorbPointer(
        child: Chip(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
          labelPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          backgroundColor:
              const Color.fromARGB(255, 197, 195, 195).withAlpha(128),
          avatar: validAudio
              ? CLIcon.tiny(
                  widget.editMode
                      ? Icons.delete
                      : controller.playerState.isPlaying
                          ? Icons.stop
                          : Icons.play_arrow,
                  color: widget.editMode
                      ? Colors.red
                      : widget.theme.foregroundColor,
                )
              : null,
          label: Padding(
            padding: const EdgeInsets.all(2),
            child: controller.playerState.isPlaying
                ? AudioFileWaveforms(
                    size: const Size(100, 20),
                    playerController: controller,
                    playerWaveStyle: playerWaveStyle,
                    continuousWaveform: widget.theme.continuousWaveform,
                  )
                : SizedBox.fromSize(
                    size: const Size(100, 20),
                    child: FittedBox(
                      child: CLText.standard(
                        DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(widget.note.createdDate),
                        textAlign: TextAlign.start,
                        color: validAudio ? null : Colors.red,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
