import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'chat_bubble.dart';
import 'models/message.dart';
import 'widgets/show_messages.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({super.key});

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  late final RecorderController recorderController;
  late final TextEditingController textEditingController;
  late final FocusNode focusNode;

  bool isRecording = false;
  bool isRecordingCompleted = false;
  List<CLMessage> messages = [];
  CLAudioMessage? audioMessage;

  @override
  void initState() {
    super.initState();
    _initialiseControllers();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
  }

  Future<Directory> _getDir() async {
    return getApplicationDocumentsDirectory();
    /* path = '${appDirectory.path}/recording.m4a';
    setState(() {}); */
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
    return FutureBuilder(
      future: _getDir(),
      builder: (context, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final appDirectory = snapShot.data!;
        return Column(
          children: [
            Expanded(
              child:
                  ShowMessages(messages: messages, appDirectory: appDirectory),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: hasAudioMessage
                  ? Row(
                      children: [
                        WaveBubble(
                          path: (audioMessage!).path,
                          width: MediaQuery.of(context).size.width / 4,
                          //width: MediaQuery.of(context).size.width / 2,
                          appDirectory: appDirectory,
                        ),
                        IconButton(
                          onPressed: _sendAudio,
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _deleteAudioMessage,
                          icon: const Icon(Icons.delete),
                          color: Colors.white,
                          iconSize: 28,
                        ),
                      ],
                    )
                  : isRecording
                      ? Row(
                          children: [
                            Expanded(
                              child: LiveAudio(
                                recorderController: recorderController,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _startOrStopRecording(appDirectory),
                              icon: Icon(
                                isRecording ? Icons.stop : Icons.mic,
                              ),
                              color: Colors.white,
                              iconSize: 28,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: InputDecorator(
                                  decoration: FormDesign.inputDecoration(
                                    context,
                                    label: 'Add Notes',
                                    hintText: 'Add Notes',
                                    actionBuilder: null,
                                  ),
                                  child: TextField(
                                    enabled: true,
                                    showCursor: true,
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                messages.add(
                                  CLTextMessage(
                                    dateTime: DateTime.now(),
                                    text: textEditingController.text,
                                  ),
                                );
                                textEditingController.clear();
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _startOrStopRecording(appDirectory),
                              icon: Icon(
                                isRecording ? Icons.stop : Icons.mic,
                              ),
                              color: Colors.white,
                              iconSize: 28,
                            ),
                          ],
                        ),
            ),
          ],
        );
      },
    );
  }

  void _deleteAudioMessage() {
    if (hasAudioMessage) {
      File((audioMessage!).path).deleteSync();
      audioMessage = null;
      setState(() {});
    }
  }

  bool get hasAudioMessage => audioMessage != null;
  bool get hasTextMessage => textEditingController.text.isNotEmpty;
  bool get hasMessage => hasAudioMessage || hasTextMessage;

  bool get canSendMessage => !isRecording && hasMessage;

  void _sendAudio() {
    if (hasAudioMessage) {
      messages.add(audioMessage!);
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
          debugPrint(path);
          debugPrint('Recorded file size: ${File(path).lengthSync()}');
          //audioFiles.add(path);
          audioMessage = CLAudioMessage(
            dateTime: DateTime.now(),
            path: path,
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
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1E1B26),
      ),
      padding: const EdgeInsets.only(left: 18),
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
    );
  }
}
