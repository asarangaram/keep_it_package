import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/modules/shared_media/cl_media_process.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';
import 'package:video_trimmer/video_trimmer.dart';

class MediaEditor extends ConsumerWidget {
  const MediaEditor({
    required this.mediaId,
    super.key,
  });
  final int? mediaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('mediaId $mediaId');
    if (mediaId == null) {
      return const CLErrorView(errorMessage: 'No Media Provided');
    }
    return GetDBManager(
      builder: (dbManager) {
        return GetMedia(
          id: mediaId!,
          buildOnData: (media) {
            if (media.isValidMedia && media.type == CLMediaType.video) {
              return TrimmerView(
                File(media.path),
                onSave: (outFile, {required overwrite}) async {
                  final md5String = await File(outFile).checksum;
                  final CLMedia updatedMedia;
                  if (overwrite) {
                    updatedMedia =
                        media.copyWith(path: outFile, md5String: md5String);
                  } else {
                    updatedMedia = CLMedia(
                      path: outFile,
                      type: CLMediaType.video,
                      collectionId: media.collectionId,
                      md5String: md5String,
                      originalDate: media.originalDate,
                      createdDate: media.createdDate,
                    );
                  }
                  await dbManager.upsertMedia(
                    collectionId: media.collectionId!,
                    media: updatedMedia,
                    onPrepareMedia: (m, {required targetDir}) async {
                      final updated = (await m.moveFile(targetDir: targetDir))
                          .getMetadata();

                      return updated;
                    },
                  );
                  if (context.mounted) {
                    if (context.canPop()) {
                      context.pop();
                    }
                  }
                },
                onDiscard: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              );
            }
            return const CLErrorView(errorMessage: 'Not supported yet');
          },
        );
      },
    );
  }
}

class TrimmerView extends StatefulWidget {
  const TrimmerView(
    this.file, {
    required this.onSave,
    required this.onDiscard,
    super.key,
  });
  final File file;
  final void Function(String outFile, {required bool overwrite}) onSave;
  final void Function() onDiscard;

  @override
  State<TrimmerView> createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
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
      onSave: (outputPath) {
        if (outputPath != null) {
          widget.onSave(outputPath, overwrite: overwrite);
        } else {
          // Error Handle
        }

        setState(() {
          _progressVisibility = false;
        });
        debugPrint('OUTPUT PATH: $outputPath');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('trim: _startValue: $_startValue _endValue:$_endValue');
    return FullscreenLayout(
      child: Center(
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
                    ),
                    onSelected: (String value) {
                      // Handle your action on selection here
                      print('Selected: $value');
                      if (value == 'Save') {
                        _saveVideo();
                      } else if (value == 'Save Copy') {
                        _saveVideo(overwrite: false);
                      } else if (value == 'Discard') {
                        widget.onDiscard();
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
      ),
    );
  }
}
