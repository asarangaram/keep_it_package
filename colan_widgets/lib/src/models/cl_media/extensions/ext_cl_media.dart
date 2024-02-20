import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'package:path/path.dart' as path_handler;
import 'package:share_handler/share_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../app_logger.dart';
import '../../../extensions/ext_io_file.dart';
import '../cl_media.dart';
import '../cl_media_type.dart';

extension ExtCLMediaFile on CLMedia {
  String get previewFileName => '$path.jpg';
  //bool get hasPreview => File(previewFileName).existsSync();

  void deleteFile() {
    File(previewFileName).deleteIfExists();
    File(path).deleteIfExists();
  }

  String generateFileName(http.Response response) {
    String? filename;
    // Check if we get file name
    if (response.headers.containsKey('content-disposition')) {
      final contentDispositionHeader = response.headers['content-disposition'];
      final match = RegExp('filename=(?:"([^"]+)"|(.*))')
          .firstMatch(contentDispositionHeader!);

      filename = match?[1] ?? match?[2];
    }
    filename = filename ?? 'unnamedfile';
    /* if (path_handler.extension(filename).isEmpty) {
          // If no extension found, add extension if possible
          // Parse the Content-Type header to determine the file extension
          final mediaType =
              MediaType.parse(response.headers['content-type'] ?? '');

          final fileExtension = mediaType.subtype;
          filename = '$filename.$fileExtension';
        } */

    return '${DateTime.now().millisecondsSinceEpoch}_filename';
  }

  Future<CLMedia> download(
    String url,
    CLMediaType type, {
    required String targetDir,
  }) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return this;

    final targetFile = path_handler.join(targetDir, generateFileName(response));
    File(targetFile)
      ..createSync(recursive: true)
      ..writeAsBytesSync(response.bodyBytes);
    return copyWith(path: targetFile, type: type);
  }

  Future<CLMedia> copyFile({required String pathPrefix}) async {
    if (collectionId == null) {
      throw Exception("Item can't be stored without collectionId");
    }
    final targetDir = path_handler.join(
      pathPrefix,
      'keep_it',
      'cluster_${collectionId!}',
    );
    switch (type) {
      case CLMediaType.image:
      case CLMediaType.video:
      case CLMediaType.audio:
      case CLMediaType.file:
        if (!File(path).existsSync()) {
          throw Exception('Incoming file not found!');
        }

        final targetFile =
            path_handler.join(targetDir, path_handler.basename(path));
        File(targetFile).createSync(recursive: true);
        File(path).copySync(targetFile);
        if (File(previewFileName).existsSync()) {
          {
            final targetFile = path_handler.join(
              targetDir,
              path_handler.basename(previewFileName),
            );
            File(previewFileName).copySync(targetFile);
          }
        }

        return copyWith(path: targetFile);

      case CLMediaType.url:
      case CLMediaType.text:
        return this;
    }
  }

  /*  /**
   * 
   
   */

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
  } */

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

  /* String? get previewPath {
    if (hasPreview) return previewFileName;

    return null;
  } */

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
        maxWidth: previewWidth ?? 640,
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

  /* static Future<CLMedia> clMediaWithPreview({
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
  } */
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

  /* static Future<CLMediaInfoGroup?> fromSharedMedia(
    SharedMedia? sharedMedia, {
    String folderName = 'incoming',
  }) async {
    _infoLogger('Start loading');

    if (sharedMedia == null) {
      return null;
    }
    final stopwatch = Stopwatch()..start();
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
  } */
}

bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
