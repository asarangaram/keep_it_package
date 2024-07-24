import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../../../internal/widgets/editor_finalizer.dart';

class VideoTrimmerView extends StatefulWidget {
  const VideoTrimmerView(
    this.file, {
    required this.onSave,
    required this.onDone,
    required this.canDuplicateMedia,
    required this.audioMuter,
    required this.onReset,
    required this.isMuted,
    super.key,
  });
  final File file;
  final Future<void> Function(String outFile, {required bool overwrite}) onSave;
  final Future<void> Function() onDone;
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

  bool get hasEditAction => _startValue != null && _endValue != null;

  Future<void> _saveVideo({bool overwrite = true}) async {
    if (!hasEditAction) {
      setState(() {
        _progressVisibility = true;
      });
      // If only the audio is muted, just save the file.
      if (widget.isMuted) {
        await widget.onSave(widget.file.path, overwrite: overwrite);
        await widget.onDone();
      }
      if (mounted) {
        setState(() {
          _progressVisibility = false;
        });
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
        debugPrint('OUTPUT PATH: $outputPath');
        await widget.onDone();
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
                      ? const Icon(
                          Icons.pause,
                          size: 80,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.play_arrow,
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
                  hasEditAction: hasEditAction || widget.isMuted,
                  onSave: _saveVideo,
                  onDiscard: ({required done}) async {
                    if (done) {
                      await widget.onDone();
                    } else {
                      widget.onReset();
                    }
                  },
                  child: Icon(
                    Icons.check,
                    size: 60,
                    color: hasEditAction || widget.isMuted
                        ? Colors.red
                        : Colors.white,
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
