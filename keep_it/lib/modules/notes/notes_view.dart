import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';
import 'package:intl/intl.dart';
import 'package:keep_it/modules/notes/widgets/note_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:store/store.dart';

import 'widgets/show_notes.dart';

class NotesView extends StatefulWidget {
  const NotesView({required this.media, super.key});
  final CLMedia media;

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return GetDBManager(
      builder: (dbManager) {
        return GetNotesByMediaId(
          mediaId: widget.media.id!,
          buildOnData: (notes) {
            return Column(
              children: [
                Expanded(
                  child: ShowNotes(messages: notes),
                ),
                InputNewNote(
                  onNewNote: (CLNote note) async {
                    await dbManager.upsertNote(
                      note,
                      [widget.media],
                      onSaveNote: (note1, {required targetDir}) async {
                        return note1.moveFile(targetDir: targetDir);
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class InputNewNote extends StatefulWidget {
  const InputNewNote({required this.onNewNote, super.key});
  final Future<void> Function(CLNote note) onNewNote;

  @override
  State<InputNewNote> createState() => _InputNewNoteState();
}

class _InputNewNoteState extends State<InputNewNote> {
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

  Future<Directory> _getDir() async {
    return getApplicationCacheDirectory();
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
            AnimatedSwitcher(
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
                            Icons.send,
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
                              color: const DefaultNotesInputTheme()
                                  .foregroundColor,
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
                              onPressed: () async {
                                if (textEditingController.text
                                    .trim()
                                    .isNotEmpty) {
                                  final now = DateTime.now();
                                  final formattedDate =
                                      DateFormat('yyyyMMdd_HHmmss_SSS')
                                          .format(now);
                                  final path =
                                      '${appDirectory.path}/note_$formattedDate.txt';
                                  await File(path).writeAsString(
                                    textEditingController.text.trim(),
                                  );
                                  // Write  to file.
                                  await widget.onNewNote(
                                    CLTextNote(
                                      createdDate: DateTime.now(),
                                      path: path,
                                      id: null,
                                    ),
                                  );
                                  textEditingController.clear();
                                  setState(() {});
                                }
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

  Future<void> _sendAudio() async {
    if (hasAudioMessage) {
      await widget.onNewNote(audioMessage!);
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
