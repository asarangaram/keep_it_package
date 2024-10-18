import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class RecordedAudioView extends StatefulWidget {
  const RecordedAudioView(
    this.audioPath, {
    super.key,
    this.onDeleteAudio,
  });
  final String audioPath;
  final VoidCallback? onDeleteAudio;

  @override
  State<RecordedAudioView> createState() => _RecordedAudioViewState();
}

class _RecordedAudioViewState extends State<RecordedAudioView> {
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
      controller.preparePlayer(path: widget.audioPath, noOfSamples: 200);

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerWaveStyle = const DefaultNotesInputTheme().playerWaveStyle;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox.fromSize(
          size: Size(constraints.maxWidth, constraints.maxHeight - 16),
          child: Row(
            children: [
              CLButtonIcon.standard(
                controller.playerState.isPlaying
                    ? clIcons.playerPause
                    : clIcons.playerPlay,
                color: const DefaultNotesInputTheme().foregroundColor,
                onTap: () async {
                  controller.playerState.isPlaying
                      ? await controller.pausePlayer()
                      : await controller.startPlayer(
                          finishMode: FinishMode.pause,
                        );
                },
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AudioFileWaveforms(
                        size: Size(
                          constraints.maxWidth,
                          constraints.maxHeight - 16,
                        ),
                        playerController: controller,
                        playerWaveStyle: playerWaveStyle,
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                      ),
                    ),
                    if (widget.onDeleteAudio != null)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: CLButtonIcon.tiny(
                          clIcons.deleteNote,
                          onTap: widget.onDeleteAudio,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
