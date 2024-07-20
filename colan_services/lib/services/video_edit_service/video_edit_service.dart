import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart';

import 'widgets/video_trimmer.dart';

class VideoEditServices extends StatefulWidget {
  const VideoEditServices(
    this.file, {
    required this.onSave,
    required this.onDone,
    required this.canDuplicateMedia,
    super.key,
  });
  final File file;
  final Future<void> Function(String outFile, {required bool overwrite}) onSave;
  final Future<void> Function() onDone;
  final bool canDuplicateMedia;

  static bool get isSupported => ColanPlatformSupport.isMobilePlatform;

  @override
  State<VideoEditServices> createState() => _VideoEditServicesState();
}

class _VideoEditServicesState extends State<VideoEditServices> {
  String? audioRemovedFile;

  @override
  Widget build(BuildContext context) {
    final currFile = audioRemovedFile ?? widget.file.path;

    return VideoTrimmerView(
      File(currFile),
      key: ValueKey(audioRemovedFile != null),
      onSave: widget.onSave,
      onDone: widget.onDone,
      canDuplicateMedia: widget.canDuplicateMedia,
      isMuted: audioRemovedFile != null,
      audioMuter: AudioMuter(
        widget.file.path,
        onDone: (file) {
          setState(() {
            audioRemovedFile = file;
          });
        },
        isMuted: audioRemovedFile != null,
      ),
    );
  }
}

class AudioMuter extends StatefulWidget {
  const AudioMuter(
    this.inFile, {
    required this.onDone,
    required this.isMuted,
    super.key,
  });
  final void Function(String? filePath) onDone;
  final bool isMuted;
  final String inFile;
  @override
  State<AudioMuter> createState() => _AudioMuterState();
}

class _AudioMuterState extends State<AudioMuter> {
  bool isMuting = false;
  String? outFile;

  @override
  Widget build(BuildContext context) {
    if (isMuting) {}
    return TextButton(
      onPressed: isMuting
          ? null
          : () async {
              if (widget.isMuted) {
                // Unmute by sending null
                widget.onDone(null);
              } else {
                setState(() {
                  isMuting = true;
                });

                if (outFile == null) {
                  final videoWithoutAudio = await TheScreenHandler.of(context)
                      .createTempFile(ext: extension(widget.inFile));
                  await File(videoWithoutAudio).deleteIfExists();
                  final session = await FFmpegKit.execute(
                    '-i ${widget.inFile} '
                    '-vcodec copy -an '
                    '-f mp4 $videoWithoutAudio',
                  );
                  final returnCode = await session.getReturnCode();
                  if (ReturnCode.isSuccess(returnCode)) {
                    widget.onDone(videoWithoutAudio);
                  }
                  /* {
                    final output = await session.getOutput();
                    print(output);
                    final logs = await session.getLogs();
                    for (final log in logs) {
                      print(log.getMessage());
                    }

                    
                  } */
                }

                if (mounted) {
                  setState(() {
                    isMuting = false;
                  });
                }
              }
            },
      child: isMuting
          ? const CircularProgressIndicator()
          : widget.isMuted
              ? Icon(
                  MdiIcons.volumeOff,
                  size: 60,
                  color: Colors.white,
                )
              : Icon(
                  MdiIcons.volumeHigh,
                  size: 60,
                  color: Colors.white,
                ),
    );
  }
}

/*
() async {
        if (useVideoWithoutAudio) {
          if (audioRemovedFile == null) {
            final videoWithoutAudio = await TheStore.of(context)
                .createTempFile(ext: extension(widget.file.path));
            final session = await FFmpegKit.execute(
              '-i ${widget.file.path} -vcodec copy -an $videoWithoutAudio',
            );
            final returnCode = await session.getReturnCode();
            if (ReturnCode.isSuccess(returnCode)) {
              useVideoWithoutAudio = true;
            }
          }
        } else {
          useVideoWithoutAudio = false;
        }
      }*/
