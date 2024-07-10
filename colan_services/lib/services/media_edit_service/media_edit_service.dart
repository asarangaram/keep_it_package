import 'dart:io';
import 'dart:typed_data';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';

import '../image_edit_service/views/image_editor.dart';
import '../shared_media_service/models/on_get_media.dart';
import '../video_edit_service/video_trimmer.dart';

class MediaEditService extends StatelessWidget {
  const MediaEditService({
    required this.media,
    required this.onCreateNewFile,
    required this.onSave,
    super.key,
  });
  final CLMedia media;
  final Future<String> Function() onCreateNewFile;
  final Future<void> Function(String, {required bool overwrite}) onSave;

  @override
  Widget build(BuildContext context) {
    return GetAppSettings(
      builder: (appSettings) {
        return MediaHandlerWidget(
          builder: ({
            required action,
          }) {
            if (!File(media.path).existsSync()) {
              return const CLErrorView(errorMessage: 'Invalid Media');
            }
            switch (media.type) {
              case CLMediaType.image:
                return ImageEditService(
                  file: File(media.path),
                  onDone: () => CLPopScreen.onPop(context),
                  onEditAndSave: (
                    Uint8List imageBytes, {
                    required bool overwrite,
                    Rect? cropRect,
                    bool? needFlip,
                    double? rotateAngle,
                  }) async {
                    await editAndSave(
                      imageBytes,
                      cacheDir: appSettings.directories.downloadedMedia.path,
                      onSave: onSave,
                      overwrite: overwrite,
                      cropRect: cropRect,
                      needFlip: needFlip,
                      rotateAngle: rotateAngle,
                    );
                  },
                );
              case CLMediaType.video:
                return VideoEditServices(
                  File(media.path),
                  onSave: onSave,
                  onDone: () => CLPopScreen.onPop(context),
                );
              case CLMediaType.text:
              case CLMediaType.url:
              case CLMediaType.audio:
              case CLMediaType.file:
                return const CLErrorView(errorMessage: 'Not supported yet');
            }
          },
        );
      },
    );
  }

  Future<void> editAndSave(
    Uint8List imageBytes, {
    required Directory cacheDir,
    required bool overwrite,
    required Rect? cropRect,
    required bool? needFlip,
    required double? rotateAngle,
    required Future<void> Function(String, {required bool overwrite}) onSave,
  }) async {
    final fileName = await onCreateNewFile();

    await ExtDeviceProcessMedia.imageCropper(
      imageBytes,
      cropRect: cropRect,
      needFlip: needFlip ?? false,
      rotateAngle: rotateAngle,
      outFile: fileName,
    );

    await onSave(fileName, overwrite: overwrite);
  }
}
