import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'audio/audio_note_view.dart';

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      AudioNoteView(
                        audioMessage!,
                        theme: const DefaultNotesInputTheme().copyWith(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                      Positioned(
                        bottom: 4 + 8,
                        right: 4,
                        child: CLButtonIcon.small(
                          Icons.delete,
                          onTap: _deleteAudioMessage,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: kMinInteractiveDimension,
                  child: CLButtonIcon.small(
                    Icons.save,
                    onTap: _sendAudio,
                  ),
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
                  SizedBox(
                    width: kMinInteractiveDimension,
                    child: CLButtonIcon.small(
                      isRecording ? Icons.stop : Icons.mic,
                      onTap: () => _startOrStopRecording(widget.tempDir),
                    ),
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
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.red)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: AudioWaveforms(
              enableGesture: true,
              size: Size(constraints.maxWidth, constraints.maxHeight - 16),
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
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
            ),
          );
        },
      ),
    );
  }
}
