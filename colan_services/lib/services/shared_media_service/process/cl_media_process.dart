import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:exif/exif.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:store/store.dart';

import '../models/cl_shared_media.dart';

class CLMediaProcess {
  static Stream<Progress> analyseMedia({
    required DBManager dbManager,
    required CLSharedMedia media,
    required Future<CLMedia?> Function(String md5) findItemByMD5,
    required AppSettings appSettings,
    required void Function({
      required CLSharedMedia mg,
    }) onDone,
  }) async* {
    final candidates = <CLMedia>[];

    yield Progress(
      currentItem: path.basename(media.entries[0].path),
      fractCompleted: 0,
    );

    for (final (i, item0) in media.entries.indexed) {
      final item1 = await tryDownloadMedia(item0, appSettings: appSettings);
      final item = await identifyMediaType(item1, appSettings: appSettings);
      if (!item.type.isFile) {
        // Skip for now
      }
      if (item.type.isFile) {
        final file = File(item.path);
        if (file.existsSync()) {
          final md5String = await file.checksum;
          final duplicate = await findItemByMD5(md5String);
          if (duplicate != null) {
            candidates.add(duplicate);
          } else {
            const tempCollectionName = '*** Recently Imported';
            final Collection tempCollection;
            tempCollection =
                await dbManager.getCollectionByLabel(tempCollectionName) ??
                    await dbManager.upsertCollection(
                      collection: const Collection(label: tempCollectionName),
                    );
            final newMedia = CLMedia(
              path: item.path,
              type: item.type,
              collectionId: tempCollection.id,
              md5String: md5String,
              isHidden: true,
            );
            final tempMedia = await dbManager.upsertMedia(
              collectionId: tempCollection.id!,
              media: newMedia.copyWith(isHidden: true),
              onPrepareMedia: (m, {required targetDir}) async {
                final updated =
                    (await m.moveFile(targetDir: targetDir)).getMetadata();
                return updated;
              },
            );
            if (tempMedia != null) {
              candidates.add(tempMedia);
            } else {
              /* Failed to add media, handle here */
            }
          }
        } else {
          /* Missing file? ignoring */
        }
      }

      await Future<void>.delayed(const Duration(milliseconds: 10));

      yield Progress(
        currentItem: (i + 1 == media.entries.length)
            ? ''
            : path.basename(media.entries[i + 1].path),
        fractCompleted: (i + 1) / media.entries.length,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
    onDone(
      mg: CLSharedMedia(entries: candidates, collection: media.collection),
    );
  }

  static Future<CLMedia> tryDownloadMedia(
    CLMedia item0, {
    required AppSettings appSettings,
  }) async {
    if (item0.type != CLMediaType.url) {
      return item0;
    }
    final mimeType = await URLHandler.getMimeType(item0.path);
    if (![
      CLMediaType.image,
      CLMediaType.video,
      CLMediaType.audio,
      CLMediaType.file,
    ].contains(mimeType)) {
      return item0;
    }
    final downloadedFile = await URLHandler.download(
      item0.path,
      appSettings.downloadDir,
    );
    if (downloadedFile == null) {
      return item0;
    }
    return item0.copyWith(path: downloadedFile, type: mimeType);
  }

  static Future<CLMedia> identifyMediaType(
    CLMedia item0, {
    required AppSettings appSettings,
  }) async {
    if (item0.type != CLMediaType.file) {
      return item0;
    }
    final mimeType = switch (lookupMimeType(item0.path)) {
      (final String mime) when mime.startsWith('image') => CLMediaType.image,
      (final String mime) when mime.startsWith('video') => CLMediaType.video,
      _ => CLMediaType.file
    };
    if (mimeType == CLMediaType.file) {
      return item0;
    }
    return item0.copyWith(type: mimeType);
  }
}

extension ExtProcessCLMedia on CLMedia {
  Future<CLMedia> getMetadata({bool? regenerate}) async {
    if (type == CLMediaType.image) {
      try {
        if (id == null || (regenerate != null && regenerate == true)) {
          final fileBytes = File(this.path).readAsBytesSync();
          final data = await readExifFromBytes(fileBytes);

          var dateTimeString = data['EXIF DateTimeOriginal']!.printable;
          final dateAndTime = dateTimeString.split(' ');
          dateTimeString =
              [dateAndTime[0].replaceAll(':', '-'), dateAndTime[1]].join(' ');

          final originalDate = DateTime.parse(dateTimeString);
          return copyWith(originalDate: originalDate);
        }
      } catch (e) {
        //ignore the error and continue without metadata
      }
      return this;
    } else if (type == CLMediaType.video) {
      _infoLogger('fetching media Information');
      final session = await FFprobeKit.getMediaInformation(this.path);
      final properties = session.getMediaInformation()?.getAllProperties();
      if (properties == null) {
        _infoLogger('No Information');
      } else {
        try {
          /* final jsonString = jsonEncode(properties);
          printFormattedJson(jsonString); */
          /* _infoLogger(
            getAllValuesForKey(properties, 'creation_time').toString(),
          ); */
          final creationTimeTags =
              getAllValuesForKey(properties, 'creation_time');
          if (creationTimeTags.isNotEmpty) {
            final originalDate = DateTime.parse(creationTimeTags[0] as String);
            return copyWith(originalDate: originalDate);
          }
        } catch (e) {
          //ignore the error and continue without metadata
        }
      }
      return this;
    } else {
      return this;
    }
  }

  List<dynamic> getAllValuesForKey(
    Map<dynamic, dynamic> map,
    String targetKey,
  ) {
    final values = <dynamic>[];

    for (final entry in map.entries) {
      if (entry.key == targetKey) {
        values.add(entry.value);
      } else if (entry.value is Map) {
        final nestedValues =
            getAllValuesForKey(entry.value as Map<dynamic, dynamic>, targetKey);
        values.addAll(nestedValues);
      }
    }
    return values;
  }

  String printFormattedJson(String jsonString) {
    const encoder =
        JsonEncoder.withIndent('  '); // Use two spaces for indentation
    return encoder.convert(json.decode(jsonString));
  }

  static Future<bool> imageCropper(
    Uint8List imageBytes, {
    required String outFile,
    Rect? cropRect,
    bool needFlip = false,
    double? rotateAngle,
  }) async {
    try {
      var image = img.decodeImage(imageBytes);
      if (image == null) return false;

      if (cropRect != null) {
        image = img.copyCrop(
          image,
          x: cropRect.left.ceil(),
          y: cropRect.top.ceil(),
          width: (cropRect.right - cropRect.left).ceil(),
          height: (cropRect.bottom - cropRect.top).ceil(),
        );
      }
      if (needFlip) {
        image = img.flipHorizontal(image);
      }
      if (rotateAngle != null) {
        image = img.copyRotate(image, angle: rotateAngle);
      }
      await img.encodeJpgFile(outFile, image);
      return true;
    } catch (e) {
      return false;
    }
  }
}

const _filePrefix = 'Media Processing: ';
bool _disableInfoLogger = true;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
