// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:colan_services/services/store_service/widgets/get_media_uri.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class AudioNote extends ConsumerWidget {
  const AudioNote(
    this.note, {
    required this.onDeleteNote,
    super.key,
    this.editMode = true,
    this.onEditMode,
  });

  final CLMedia note;
  final bool editMode;
  final VoidCallback? onEditMode;
  final VoidCallback onDeleteNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMediaUri(
      note,
      builder: (uri) {
        return AudioNote1(
          note,
          notePath: uri.path,
          onDeleteNote: onDeleteNote,
          editMode: editMode,
          onEditMode: onEditMode,
        );
      },
    );
  }
}

class AudioNote1 extends StatefulWidget {
  const AudioNote1(
    this.note, {
    required this.notePath,
    required this.onDeleteNote,
    super.key,
    this.editMode = true,
    this.onEditMode,
  });

  final CLMedia note;
  final bool editMode;
  final VoidCallback? onEditMode;
  final VoidCallback onDeleteNote;
  final String notePath;

  @override
  State<AudioNote1> createState() => _AudioNote1State();
}

class _AudioNote1State extends State<AudioNote1> {
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
    notePath = widget.notePath;
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

    final label =
        widget.note.createdDate?.millisecondsSinceEpoch.toString() ?? 'No Date';
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
