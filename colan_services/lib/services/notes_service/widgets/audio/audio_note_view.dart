import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class AudioNoteView extends StatefulWidget {
  const AudioNoteView(this.note, {required this.theme, super.key});

  final CLAudioNote note;
  final NotesTheme theme;

  @override
  State<AudioNoteView> createState() => _AudioNoteViewState();
}

class _AudioNoteViewState extends State<AudioNoteView> {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.theme.borderRadius),
            border: Border.all(color: widget.theme.borderColor),
            color: widget.theme.backgroundColor,
          ),
          margin: widget.theme.margin,
          padding: widget.theme.padding,
          height: constraints.maxHeight - 16,
          width: constraints.maxWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              //if (!controller.playerState.isStopped)
              IconButton(
                onPressed: () async {
                  controller.playerState.isPlaying
                      ? await controller.pausePlayer()
                      : await controller.startPlayer(
                          finishMode: FinishMode.pause,
                        );
                },
                icon: Icon(
                  controller.playerState.isPlaying
                      ? Icons.stop
                      : Icons.play_arrow,
                  color: widget.theme.foregroundColor,
                ),
              ),
              Expanded(
                child: AudioFileWaveforms(
                  size: Size(constraints.maxWidth, constraints.maxHeight - 16),
                  playerController: controller,
                  playerWaveStyle: playerWaveStyle,
                  continuousWaveform: widget.theme.continuousWaveform,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
