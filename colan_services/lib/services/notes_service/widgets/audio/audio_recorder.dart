import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../store_service/models/store_model.dart';
import '../../../store_service/providers/store_cache.dart';
import 'decorations.dart';
import 'live_audio_view.dart';
import 'recorded_audio_view.dart';

class AudioRecorder extends ConsumerStatefulWidget {
  const AudioRecorder({
    required this.media,
    required this.theStore,
    this.child,
    super.key,
    this.editMode = false,
    this.onEditCancel,
  });
  final CLMedia media;
  final StoreCache theStore;
  final Widget? child;
  final bool editMode;
  final VoidCallback? onEditCancel;

  @override
  ConsumerState<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends ConsumerState<AudioRecorder> {
  late final RecorderController recorderController;
  late final TextEditingController textEditingController;
  late final FocusNode focusNode;
  late final StoreCache theStore;
  bool isRecording = false;
  bool isRecordingCompleted = false;

  String? audioMessage;

  @override
  void initState() {
    super.initState();
    theStore = widget.theStore;
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
          clIcons.save,
          onTap: _sendAudio,
        ),
      );
    }

    if (widget.editMode) {
      return IconButton(
        onPressed: widget.onEditCancel,
        icon: Icon(
          clIcons.doneEditMedia,
        ),
        color: Colors.white,
        iconSize: 28,
      );
    }
    return SizedBox(
      width: kMinInteractiveDimension,
      child: CLButtonIcon.small(
        isRecording ? clIcons.playerStop : clIcons.microphone,
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
      File(message2Delete!).delete();
    }
  }

  bool get hasAudioMessage => audioMessage != null;
  bool get hasTextMessage => textEditingController.text.isNotEmpty;
  bool get hasMessage => hasAudioMessage || hasTextMessage;

  bool get canSendMessage => !isRecording && hasMessage;

  Future<void> _sendAudio() async {
    if (hasAudioMessage) {
      await ref.read(storeCacheProvider.notifier).upsertMedia(
            audioMessage!,
            CLMediaType.audio,
            parents: [widget.media],
            isAux: true,
          );

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
          audioMessage = path;
          setState(() {});
        }
      } else {
        final path = await theStore.createTempFile(ext: 'aac');
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
