import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keep_it/modules/notes/widgets/note_view.dart';
import 'package:store/store.dart';

import 'audio_chip.dart';

class AudioNotes extends StatefulWidget {
  const AudioNotes({
    required this.media,
    required this.audioNotes,
    super.key,
  });
  final CLMedia media;
  final List<CLAudioNote> audioNotes;

  @override
  State<AudioNotes> createState() => _AudioNotesState();
}

class _AudioNotesState extends State<AudioNotes> {
  late bool editMode;

  @override
  void didChangeDependencies() {
    editMode = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GetAppSettings(
        builder: (appSettings) {
          return GetDBManager(
            builder: (dbManager) {
              return AudioRecorder(
                tempDir: appSettings.directories.cacheDir,
                onNewNote: (CLNote note) async {
                  await dbManager.upsertNote(
                    note,
                    [widget.media],
                    onSaveNote: (note1, {required targetDir}) async {
                      return note1.moveFile(targetDir: targetDir);
                    },
                  );
                },
                editMode: editMode && widget.audioNotes.isNotEmpty,
                onEditCancel: () {
                  setState(() {
                    editMode = false;
                  });
                },
                child: widget.audioNotes.isEmpty
                    ? null
                    : SingleChildScrollView(
                        child: Wrap(
                          runSpacing: 2,
                          spacing: 2,
                          children: widget.audioNotes
                              .map(
                                (audioNote) => AudioChip(
                                  audioNote,
                                  editMode:
                                      editMode && widget.audioNotes.isNotEmpty,
                                  onEditMode: () {
                                    setState(() {
                                      if (widget.audioNotes.isNotEmpty) {
                                        editMode = true;
                                      }
                                    });
                                  },
                                  theme: CLTheme.of(context).noteTheme,
                                  onDeleteNote: () async {
                                    await dbManager.deleteNote(
                                      audioNote,
                                      onDeleteFile: (file) async {
                                        await file.deleteIfExists();
                                      },
                                    );
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({
    required this.onNewNote,
    required this.tempDir,
    this.child,
    super.key,
    this.editMode = false,
    this.onEditCancel,
  });
  final Future<void> Function(CLNote note) onNewNote;
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
                else
                  Expanded(child: widget.child ?? const Spacer()),
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
                  IconButton(
                    onPressed: () => _startOrStopRecording(widget.tempDir),
                    icon: Icon(
                      isRecording ? Icons.stop : Icons.mic,
                    ),
                    color: Colors.white,
                    iconSize: 28,
                  ),
              ],
            ),
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
