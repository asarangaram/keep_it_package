// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AudioChip extends StatefulWidget {
  const AudioChip(
    this.note, {
    required this.theme,
    super.key,
    this.editMode = true,
    this.onEditMode,
  });

  final CLAudioNote note;
  final NotesTheme theme;
  final bool editMode;
  final VoidCallback? onEditMode;

  @override
  State<AudioChip> createState() => _AudioChipState();
}

class _AudioChipState extends State<AudioChip> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    _preparePlayer();
    playerStateSubscription = controller.onPlayerStateChanged.listen((_) {
      setState(() {});
    });
  }

  Future<void> _preparePlayer() async =>
      controller.preparePlayer(path: widget.note.path, noOfSamples: 200);

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerWaveStyle = widget.theme.playerWaveStyle;
    return GestureDetector(
      onTap: () async {
        if (widget.editMode) {
        } else {
          controller.playerState.isPlaying
              ? await controller.pausePlayer()
              : await controller.startPlayer(
                  finishMode: FinishMode.pause,
                );
        }
      },
      onLongPress: widget.onEditMode,
      child: AbsorbPointer(
        child: Chip(
          backgroundColor:
              const Color.fromARGB(255, 197, 195, 195).withAlpha(128),
          avatar: Icon(
            widget.editMode
                ? Icons.delete
                : controller.playerState.isPlaying
                    ? Icons.stop
                    : Icons.play_arrow,
            color: widget.editMode ? Colors.red : widget.theme.foregroundColor,
          ),
          label: SizedBox.fromSize(
            size: const Size(80, 20),
            child: controller.playerState.isPlaying
                ? AudioFileWaveforms(
                    size: const Size(80, 20),
                    playerController: controller,
                    playerWaveStyle: playerWaveStyle,
                    continuousWaveform: widget.theme.continuousWaveform,
                  )
                : FittedBox(
                    child: Text(
                      DateFormat('yyyy-MM-dd HH:mm:ss')
                          .format(widget.note.createdDate),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
/**
 * 
Chip(
        
        label: AudioFileWaveforms(
          size: const Size(80, 20),
          playerController: controller,
          playerWaveStyle: playerWaveStyle,
          continuousWaveform: widget.theme.continuousWaveform,
        ),
      )
 */