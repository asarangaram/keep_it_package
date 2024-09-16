// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class AudioChip extends StatelessWidget {
  const AudioChip(
    this.audioFilePath, {
    required this.label,
    required this.onDeleteNote,
    super.key,
    this.editMode = true,
    this.onEditMode,
  });

  final String label;
  final String audioFilePath;
  final bool editMode;
  final VoidCallback? onEditMode;
  final VoidCallback onDeleteNote;

  @override
  Widget build(BuildContext context) {
    if (editMode) {
      return AudioFileChip(
        audioFilePath,
        label: label,
        onDeleteNote: onDeleteNote,
      );
    }
    return AudioPlayerChip(
      audioFilePath,
      label: label,
      onLongPress: onEditMode,
    );
  }
}

class AudioPlayerChip extends StatefulWidget {
  const AudioPlayerChip(
    this.audioFilePath, {
    required this.label,
    super.key,
    this.onLongPress,
  });

  final String label;
  final String audioFilePath;

  final VoidCallback? onLongPress;

  @override
  State<AudioPlayerChip> createState() => _AudioPlayerChipState();
}

class _AudioPlayerChipState extends State<AudioPlayerChip> {
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
    notePath = widget.audioFilePath;
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

    final label = widget.label;
    return CLCustomChip(
      avatar: validAudio
          ? CLIcon.tiny(
              controller.playerState.isPlaying
                  ? clIcons.playerPause
                  : clIcons.playerPlay,
              color: theme.foregroundColor,
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
        if (validAudio) {
          controller.playerState.isPlaying
              ? await controller.pausePlayer()
              : await controller.startPlayer(
                  finishMode: FinishMode.pause,
                );
        }
      },
      onLongPress: widget.onLongPress,
    );
  }
}

class AudioFileChip extends StatelessWidget {
  const AudioFileChip(
    this.audioFilePath, {
    required this.label,
    required this.onDeleteNote,
    super.key,
    this.editMode = true,
    this.onEditMode,
  });

  final String label;
  final String audioFilePath;
  final bool editMode;
  final VoidCallback? onEditMode;
  final VoidCallback onDeleteNote;

  @override
  Widget build(BuildContext context) {
    return CLCustomChip(
      avatar: CLIcon.tiny(
        clIcons.deleteNote,
        color: Colors.red,
      ),
      label: SizedBox.fromSize(
        size: const Size(100, 20),
        child: FittedBox(
          child: CLText.standard(
            label,
            textAlign: TextAlign.start,
          ),
        ),
      ),
      onTap: onDeleteNote,
      onLongPress: null,
    );
  }
}
