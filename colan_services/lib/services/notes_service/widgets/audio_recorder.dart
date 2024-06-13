import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({
    required this.onUpsertNote,
    required this.tempDir,
    this.child,
    super.key,
    this.editMode = false,
    this.onEditCancel,
  });
  final Future<void> Function(CLNote note) onUpsertNote;
  final Directory tempDir;
  final Widget? child;
  final bool editMode;
  final VoidCallback? onEditCancel;

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  late final RecorderController recorderController;
  late final TextEditingController textEditingController;
  late final FocusNode focusNode;

  bool isRecording = false;
  bool isRecordingCompleted = false;

  CLAudioNote? audioMessage;

  @override
  void initState() {
    super.initState();
    _initialiseControllers();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  @override
  void dispose() {
    recorderController.dispose();

    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: hasAudioMessage
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: AudioNoteView(
                    audioMessage!,
                    theme: const DefaultNotesInputTheme().copyWith(
                      margin: const EdgeInsets.only(left: 8),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendAudio,
                  icon: const Icon(
                    Icons.save,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: _deleteAudioMessage,
                  icon: const Icon(Icons.delete),
                  color: Colors.white,
                  iconSize: 28,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRecording)
                  Expanded(
                    child: LiveAudio(
                      recorderController: recorderController,
                    ),
                  )
                else if (widget.child != null)
                  Expanded(child: widget.child!)
                else
                  const Spacer(),
                if (widget.editMode)
                  IconButton(
                    onPressed: widget.onEditCancel,
                    icon: const Icon(
                      Icons.check,
                    ),
                    color: Colors.white,
                    iconSize: 28,
                  )
                else
                  CLButtonIcon.small(
                    isRecording ? Icons.stop : Icons.mic,
                    onTap: () => _startOrStopRecording(widget.tempDir),
                  ),
              ],
            ),
    );
  }

  void _deleteAudioMessage() {
    if (hasAudioMessage) {
      final message2Delete = audioMessage;
      audioMessage = null;
      setState(() {});
      File((message2Delete!).path).delete();
    }
  }

  bool get hasAudioMessage => audioMessage != null;
  bool get hasTextMessage => textEditingController.text.isNotEmpty;
  bool get hasMessage => hasAudioMessage || hasTextMessage;

  bool get canSendMessage => !isRecording && hasMessage;

  Future<void> _sendAudio() async {
    if (hasAudioMessage) {
      await widget.onUpsertNote(audioMessage!);
      audioMessage = null;
      setState(() {});
    }
  }

  Future<void> _startOrStopRecording(Directory appDirectory) async {
    try {
      if (isRecording) {
        recorderController.reset();

        final path = await recorderController.stop(false);

        if (path != null) {
          isRecordingCompleted = true;

          debugPrint('Recorded file size: ${File(path).lengthSync()}');
          //audioFiles.add(path);
          audioMessage = CLAudioNote(
            createdDate: DateTime.now(),
            path: path,
            id: null,
          );
          setState(() {});
        }
      } else {
        final now = DateTime.now();
        final formattedDate = DateFormat('yyyyMMdd_HHmmss_SSS').format(now);
        final path = '${appDirectory.path}/audio_$formattedDate.aac';

        await recorderController.record(path: path); // Path is optional
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isRecording = !isRecording;
      });
    }
  }
}

class LiveAudio extends StatelessWidget {
  const LiveAudio({
    required this.recorderController,
    super.key,
  });

  final RecorderController recorderController;

  @override
  Widget build(BuildContext context) {
    return AudioWaveforms(
      enableGesture: true,
      size: Size(
        MediaQuery.of(context).size.width / 2,
        50,
      ),
      recorderController: recorderController,
      waveStyle: const WaveStyle(
        waveColor: Colors.white,
        extendWaveform: true,
        showMiddleLine: false,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1E1B26),
      ),
      padding: const EdgeInsets.only(left: 18),
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
    );
  }
}

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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.theme.borderRadius),
        border: Border.all(color: widget.theme.borderColor),
        color: widget.theme.backgroundColor,
      ),
      margin: widget.theme.margin,
      padding: widget.theme.padding,
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
              controller.playerState.isPlaying ? Icons.stop : Icons.play_arrow,
              color: widget.theme.foregroundColor,
            ),
          ),
          Expanded(
            child: AudioFileWaveforms(
              size: Size(MediaQuery.of(context).size.width * 3 / 4, 70),
              playerController: controller,
              playerWaveStyle: playerWaveStyle,
              continuousWaveform: widget.theme.continuousWaveform,
            ),
          ),
        ],
      ),
    );
  }
}
