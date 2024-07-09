import 'dart:io';
import 'dart:typed_data';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';

import 'widgets/media_file_handler.dart';

class MediaEditService extends StatelessWidget {
  const MediaEditService({required this.mediaId, super.key});
  final int mediaId;

  @override
  Widget build(BuildContext context) {
    return GetAppSettings(
      builder: (appSettings) {
        return MediaFileHandler(
          mediaId: mediaId,
          builder: (
            filePath, {
            required mediaType,
            required onSave,
          }) {
            if (!File(filePath).existsSync()) {
              return const CLErrorView(errorMessage: 'Invalid Media');
            }
            switch (mediaType) {
              case CLMediaType.image:
                return ImageEditService(
                  file: File(filePath),
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
                  File(filePath),
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
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final imageFile = '${cacheDir.path}/$fileName';

    File(imageFile).createSync(recursive: true);

    await ExtProcessCLMedia.imageCropper(
      imageBytes,
      cropRect: cropRect,
      needFlip: needFlip ?? false,
      rotateAngle: rotateAngle,
      outFile: imageFile,
    );

    await onSave(imageFile, overwrite: overwrite);
  }
}
