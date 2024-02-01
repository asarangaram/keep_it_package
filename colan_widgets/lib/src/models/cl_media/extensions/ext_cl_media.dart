import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:share_handler/share_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../app_logger.dart';
import '../../../extensions/ext_io_file.dart';
import '../../../extensions/ext_string.dart';
import '../cl_media.dart';
import '../cl_media_type.dart';
import 'file_handler.dart';
import 'url_handler.dart';

extension ExtCLMediaFile on CLMedia {
  void deleteFile() {
    File(previewFileName).deleteIfExists();
    File(path).deleteIfExists();
  }

  Future<CLMedia> move({required String toDir}) async {
    final String newPath;
    if (File(previewFileName).existsSync()) {
      await FileHandler.move(previewFileName, toSubFolder: toDir);
    }
    if (File(path).existsSync()) {
      newPath = await FileHandler.move(path, toSubFolder: toDir);
    } else {
      newPath = path;
    }
    return copyWith(path: newPath);
  }

  Future<CLMedia> copy({required String toDir}) async {
    final String newPath;
    if (File(previewFileName).existsSync()) {
      await FileHandler.copy(previewFileName, toSubFolder: toDir);
    }
    if (File(path).existsSync()) {
      newPath = await FileHandler.copy(path, toSubFolder: toDir);
    } else {
      newPath = path;
    }
    return copyWith(path: newPath /* , previewPath: newPreviewPath */);
  }

  Future<bool> generatePreview({
    bool regenerate = false,
  }) async {
    final previewFile = File(previewFileName);

    if (previewFile.existsSync() && !regenerate) {
      return true;
    }
    return switch (type) {
      CLMediaType.image => await generateImagePreview(regenerate: regenerate),
      CLMediaType.video => await generateVideoPreview(regenerate: regenerate),
      _ => true // Ignore request
    };
  }

  String get previewFileName => '$path.jpg';
  bool get hasPreview => File(previewFileName).existsSync();

  String? get previewPath {
    if (hasPreview) return previewFileName;
    if (type == CLMediaType.image) return path;
    return null;
  }

  Future<bool> generateImagePreview({
    bool regenerate = false,
  }) async {
    try {
      final previewFile = File(previewFileName);
      final inputFile = File(path);
      if (!inputFile.existsSync()) {
        throw PathAccessException(path, const OSError('Not Found'));
      }
      final List<int> bytes = inputFile.readAsBytesSync();

      final image = decodeImage(Uint8List.fromList(bytes));
      if (image == null) {
        throw ImageException('Unable to decode $path');
      }
      final aspectRatio = image.width / image.height;

      final thumbnailWidth = previewWidth ?? 600;
      final thumbnailHeight = thumbnailWidth ~/ aspectRatio;
      final thumbnail =
          copyResize(image, width: thumbnailWidth, height: thumbnailHeight);
      previewFile.writeAsBytesSync(encodeJpg(thumbnail));

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> generateVideoPreview({
    bool regenerate = false,
  }) async {
    try {
      final previewFile = File(previewFileName);

      final thumbnail = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: previewWidth ?? 256,
        quality: 25,
      );

      if (thumbnail == null) {
        throw ImageException('Unable to generate video preview for $path');
      }

      previewFile
        ..createSync(recursive: true)
        ..writeAsBytesSync(
          thumbnail.buffer
              .asUint8List(thumbnail.offsetInBytes, thumbnail.lengthInBytes),
        );
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<CLMedia> clMediaWithPreview({
    required String path,
    required CLMediaType type,
    String? ref,
    int? id,
    int? collectionId,
  }) async {
    final m = CLMedia(
      path: path,
      type: type,
      ref: ref,
      id: id,
      collectionId: collectionId,
    );
    await m.generatePreview();
    return m;
  }
}

extension ExtCLMediaInfoGroupNullable on CLMediaInfoGroup? {
  List<CLMediaInfoGroup> toList() {
    if (this == null) {
      return [];
    } else {
      return [this!];
    }
  }
}

extension ExtCLMediaInfoGroup on CLMediaInfoGroup {
  static CLMediaType toCLMediaType(SharedAttachmentType type) {
    return switch (type) {
      SharedAttachmentType.image => CLMediaType.image,
      SharedAttachmentType.video => CLMediaType.video,
      SharedAttachmentType.audio => CLMediaType.audio,
      SharedAttachmentType.file => CLMediaType.file,
    };
  }

  static Future<CLMediaInfoGroup?> fromSharedMedia(
    SharedMedia? sharedMedia, {
    String folderName = 'incoming',
  }) async {
    _infoLogger('Start loading');
    final stopwatch = Stopwatch()..start();
    if (sharedMedia == null) {
      return null;
    }
    final newMedia = <CLMedia>[];
    if (sharedMedia.content?.isNotEmpty ?? false) {
      final text = sharedMedia.content!;
      if (text.isURL()) {
        final mimeType = await URLHandler.getMimeType(text);

        final r = switch (mimeType) {
          CLMediaType.image ||
          CLMediaType.audio ||
          CLMediaType.video ||
          CLMediaType.file =>
            await URLHandler.downloadAndSaveImage(text),
          _ => null
        };

        newMedia.add(
          await ExtCLMediaFile.clMediaWithPreview(
            path: text,
            type: (r != null) ? mimeType! : CLMediaType.url,
          ),
        );
      }
    }
    if (sharedMedia.imageFilePath != null) {
      if (!File(sharedMedia.imageFilePath!).existsSync()) {
        _infoLogger("File ${sharedMedia.imageFilePath!} doesn't exists!");
      } else {
        newMedia.add(
          await ExtCLMediaFile.clMediaWithPreview(
            path: await FileHandler.move(
              sharedMedia.imageFilePath!,
              toSubFolder: folderName,
            ),
            type: CLMediaType.image,
          ),
        );
      }
    }
    if (sharedMedia.attachments?.isNotEmpty ?? false) {
      for (final e in sharedMedia.attachments!) {
        if (e != null) {
          if (!File(e.path).existsSync()) {
            _infoLogger("File ${e.path} doesn't exists!");
          } else {
            newMedia.add(
              await ExtCLMediaFile.clMediaWithPreview(
                path: e.path,
                type: toCLMediaType(e.type),
              ),
            );
          }
        }
      }
    }
    stopwatch.stop();

    _infoLogger(
      'Elapsed time: ${stopwatch.elapsedMilliseconds} milliseconds'
      ' [${stopwatch.elapsed}]',
    );
    if (newMedia.isEmpty) return null;
    return CLMediaInfoGroup(newMedia)..toString() /* .printString() */;
  }
}

bool _disableInfoLogger = false;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
