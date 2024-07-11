import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'decorations.dart';
import 'live_audio_view.dart';
import 'recorded_audio_view.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({
    required this.onUpsertNote,
    required this.onCreateNewAudioFile,
    this.child,
    super.key,
    this.editMode = false,
    this.onEditCancel,
  });
  final Future<void> Function(CLNote note) onUpsertNote;
  final Future<String> Function() onCreateNewAudioFile;
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

  Widget control() {
    if (hasAudioMessage) {
      return SizedBox(
        width: kMinInteractiveDimension,
        child: CLButtonIcon.small(
          Icons.save,
          onTap: _sendAudio,
        ),
      );
    }

    if (widget.editMode) {
      return IconButton(
        onPressed: widget.onEditCancel,
        icon: const Icon(
          Icons.check,
        ),
        color: Colors.white,
        iconSize: 28,
      );
    }
    return SizedBox(
      width: kMinInteractiveDimension,
      child: CLButtonIcon.small(
        isRecording ? Icons.stop : Icons.mic,
        onTap: _startOrStopRecording,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (hasAudioMessage)
            Expanded(
              child: RecordedAudioDecoration(
                child: RecordedAudioView(
                  audioMessage!,
                  onDeleteAudio: _deleteAudioMessage,
                ),
              ),
            )
          else if (isRecording)
            Expanded(
              child: RecordedAudioDecoration(
                child: LiveAudio(
                  recorderController: recorderController,
                ),
              ),
            )
          else if (widget.child != null)
            Expanded(child: widget.child!)
          else
            const Spacer(),
          control(),
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

  Future<void> _startOrStopRecording() async {
    try {
      if (isRecording) {
        recorderController.reset();

        final path = await recorderController.stop(false);

        if (path != null) {
          isRecordingCompleted = true;

          //debugPrint('Recorded file size: ${File(path).lengthSync()}');
          //audioFiles.add(path);
          audioMessage = CLAudioNote(
            createdDate: DateTime.now(),
            path: path,
            id: null,
          );
          setState(() {});
        }
      } else {
        final path = await widget.onCreateNewAudioFile();
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
