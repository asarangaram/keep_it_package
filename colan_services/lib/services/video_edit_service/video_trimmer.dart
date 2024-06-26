import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoEditServices extends StatefulWidget {
  const VideoEditServices(
    this.file, {
    required this.onSave,
    required this.onDone,
    super.key,
  });
  final File file;
  final Future<void> Function(String outFile, {required bool overwrite}) onSave;
  final Future<void> Function() onDone;

  @override
  State<VideoEditServices> createState() => _VideoEditServicesState();
}

class _VideoEditServicesState extends State<VideoEditServices> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0;
  double _endValue = 0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  @override
  void initState() {
    super.initState();

    _loadVideo();
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  Future<void> _saveVideo({bool overwrite = true}) async {
    setState(() {
      _progressVisibility = true;
    });
    await Future<void>.delayed(const Duration(seconds: 1));
    await _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
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
                maxVideoLength: const Duration(seconds: 10),
                editorProperties: TrimEditorProperties(
                  borderPaintColor: Colors.yellow,
                  borderWidth: 4,
                  borderRadius: 5,
                  circlePaintColor: Colors.yellow.shade800,
                ),
                areaProperties: TrimAreaProperties.edgeBlur(
                  thumbnailQuality: 10,
                ),
                onChangeStart: (value) => _startValue = value,
                onChangeEnd: (value) => _endValue = value,
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
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() => _isPlaying = playbackState);
                  },
                ),
              ),
              Expanded(
                child: PopupMenuButton<String>(
                  child: CLIcon.standard(
                    MdiIcons.check,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  onSelected: (String value) {
                    if (value == 'Save') {
                      _saveVideo();
                    } else if (value == 'Save Copy') {
                      _saveVideo(overwrite: false);
                    } else if (value == 'Discard') {
                      widget.onDone();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {'Save', 'Save Copy', 'Discard'}
                        .map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
