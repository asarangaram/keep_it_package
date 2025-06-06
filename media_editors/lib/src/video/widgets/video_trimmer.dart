import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:media_editors/src/editor_finalizer.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoTrimmerView extends StatefulWidget {
  const VideoTrimmerView(
    this.file, {
    required this.onSave,
    required this.onCancel,
    required this.canDuplicateMedia,
    required this.audioMuter,
    required this.onReset,
    required this.isMuted,
    super.key,
  });
  final File file;
  final Future<void> Function(String outFile, {required bool overwrite}) onSave;
  final Future<void> Function() onCancel;
  final bool canDuplicateMedia;
  final Widget audioMuter;
  final bool isMuted;
  final void Function() onReset;

  @override
  State<VideoTrimmerView> createState() => _VideoTrimmerViewState();
}

class _VideoTrimmerViewState extends State<VideoTrimmerView> {
  final Trimmer _trimmer = Trimmer();

  double? _startValue;
  double? _endValue;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _loadVideo();
    super.didChangeDependencies();
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  bool get trimmerUpdated => _startValue != null && _endValue != null;
  bool get hasEditAction => trimmerUpdated || widget.isMuted;

  Future<void> _saveVideo({bool overwrite = true}) async {
    if (!trimmerUpdated) {
      // If only the audio is muted, just save the file.
      if (widget.isMuted) {
        setState(() {
          _progressVisibility = true;
        });
        await widget.onSave(widget.file.path, overwrite: overwrite);

        if (mounted) {
          setState(() {
            _progressVisibility = false;
          });
        }
      }

      return;
    }
    setState(() {
      _progressVisibility = true;
    });

    await Future<void>.delayed(const Duration(seconds: 1));
    await _trimmer.saveTrimmedVideo(
      startValue: _startValue!,
      endValue: _endValue!,
      storageDir: StorageDir.temporaryDirectory,
      onSave: (outputPath) async {
        if (outputPath != null) {
          await widget.onSave(outputPath, overwrite: overwrite);
        } else {
          // Error Handle
        }
        if (mounted) {
          setState(() {
            _progressVisibility = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Visibility(
            visible: _progressVisibility,
            child: const LinearProgressIndicator(
              backgroundColor: Colors.red,
            ),
          ),
          Expanded(
            child: VideoViewer(trimmer: _trimmer),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TrimViewer(
                trimmer: _trimmer,
                viewerWidth: MediaQuery.of(context).size.width,
                durationStyle: DurationStyle.FORMAT_MM_SS,
                editorProperties: TrimEditorProperties(
                  borderPaintColor: Colors.yellow,
                  borderWidth: 4,
                  borderRadius: 5,
                  circlePaintColor: Colors.yellow.shade800,
                ),
                areaProperties: TrimAreaProperties.edgeBlur(
                  thumbnailQuality: 10,
                ),
                onChangeStart: (value) {
                  _startValue = value;
                  _endValue ??= _trimmer
                      .videoPlayerController?.value.duration.inMilliseconds
                      .toDouble();
                  setState(() {});
                },
                onChangeEnd: (value) {
                  if (value !=
                      _trimmer.videoPlayerController?.value.duration
                          .inMilliseconds) {
                    _endValue = value;
                    _startValue ??= 0;
                  }

                  setState(() {});
                },
                onChangePlaybackState: (value) =>
                    setState(() => _isPlaying = value),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  child: _isPlaying
                      ? Icon(
                          clIcons.playerPause,
                          size: 80,
                          color: Colors.white,
                        )
                      : Icon(
                          clIcons.playerPlay,
                          size: 80,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    final playbackState = await _trimmer.videoPlaybackControl(
                      startValue: _startValue ?? 0,
                      endValue: _endValue ?? 0,
                    );
                    setState(() => _isPlaying = playbackState);
                  },
                ),
              ),
              Container(
                child: _isPlaying ? null : widget.audioMuter,
              ),
              Expanded(
                child: EditorFinalizer(
                  canDuplicateMedia: widget.canDuplicateMedia,
                  hasEditAction: hasEditAction,
                  onSave: _saveVideo,
                  onDiscard: ({required done}) async {
                    if (done) {
                      await widget.onCancel();
                    } else {
                      widget.onReset();
                    }
                  },
                  child: Icon(
                    hasEditAction
                        ? clIcons.doneEditMedia
                        : clIcons.closeFullscreen,
                    size: 60,
                    color: hasEditAction ? Colors.red : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
