import 'dart:io';
import 'dart:typed_data';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../modules/shared_media/cl_media_process.dart';
import '../widgets/media_file_handler.dart';

class MediaEditorPage extends StatelessWidget {
  const MediaEditorPage({
    required this.mediaId,
    super.key,
  });
  final int? mediaId;

  @override
  Widget build(BuildContext context) {
    if (mediaId == null) {
      return const CLErrorView(errorMessage: 'No Media Provided');
    }
    return MediaFileHandler(
      mediaId: mediaId,
      errorBuilder: (errorMessage) => CLErrorView(errorMessage: errorMessage),
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
            return FullscreenLayout(
              useSafeArea: false,
              hasBackground: false,
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              child: ImageEditService(
                file: File(filePath),
                onDone: () async {
                  if (context.mounted) {
                    if (context.canPop()) {
                      context.pop();
                    }
                  }
                },
                onEditAndSave: (
                  Uint8List imageBytes, {
                  required bool overwrite,
                  Rect? cropRect,
                  bool? needFlip,
                  double? rotateAngle,
                }) async {
                  await editAndSave(
                    imageBytes,
                    onSave: onSave,
                    overwrite: overwrite,
                    cropRect: cropRect,
                    needFlip: needFlip,
                    rotateAngle: rotateAngle,
                  );
                },
              ),
            );
          case CLMediaType.video:
            return FullscreenLayout(
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              hasBackground: false,
              child: VideoEditServices(
                File(filePath),
                onSave: onSave,
                onDone: () async {
                  if (context.mounted) {
                    if (context.canPop()) {
                      context.pop();
                    }
                  }
                },
              ),
            );
          case CLMediaType.text:
          case CLMediaType.url:
          case CLMediaType.audio:
          case CLMediaType.file:
            return const CLErrorView(errorMessage: 'Not supported yet');
        }
      },
    );
  }

  Future<void> editAndSave(
    Uint8List imageBytes, {
    required bool overwrite,
    required Rect? cropRect,
    required bool? needFlip,
    required double? rotateAngle,
    required Future<void> Function(String, {required bool overwrite}) onSave,
  }) async {
    final cacheDir = await getTemporaryDirectory();
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final imageFile = '${cacheDir.path}/$fileName';

    File(imageFile).createSync(recursive: true);

    await ExtProcess.imageCropper(
      imageBytes,
      cropRect: cropRect,
      needFlip: needFlip ?? false,
      rotateAngle: rotateAngle,
      outFile: imageFile,
    );

    await onSave(imageFile, overwrite: overwrite);
  }
}
