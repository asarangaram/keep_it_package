import 'dart:convert';
import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:crypto/crypto.dart';
import 'package:exif/exif.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class CLMediaProcess {
  static Stream<Progress> analyseMedia({
    required CLSharedMedia media,
    required Future<CLMedia?> Function(String md5) findItemByMD5,
    required void Function({
      required CLSharedMedia mg,
    }) onDone,
  }) async* {
    final candidates = <CLMedia>[];

    yield Progress(
      currentItem: path.basename(media.entries[0].path),
      fractCompleted: 0,
    );
    Future<String> getFileChecksum(File file) async {
      try {
        final stream = file.openRead();
        final hash = await md5.bind(stream).first;

        // NOTE: You might not need to convert it to base64
        return hash.toString();
      } catch (exception) {
        throw Exception('unable to determine md5');
      }
    }

    for (final (i, item) in media.entries.indexed) {
      final file = File(item.path);
      if (file.existsSync()) {
        final md5String = await getFileChecksum(file);
        final duplicate = await findItemByMD5(md5String);
        if (duplicate != null) {
          candidates.add(duplicate);
        } else {
          final CLMedia itemsToAdd;
          switch (item.type) {
            case CLMediaType.file:
              {
                itemsToAdd = CLMedia(
                  path: item.path,
                  type: switch (lookupMimeType(item.path)) {
                    (final String mime) when mime.startsWith('image') =>
                      CLMediaType.image,
                    (final String mime) when mime.startsWith('video') =>
                      CLMediaType.video,
                    _ => CLMediaType.file
                  },
                  collectionId: media.collection?.id,
                  md5String: md5String,
                );
              }
            case CLMediaType.image:
            case CLMediaType.video:
            case CLMediaType.url:
            case CLMediaType.audio:
            case CLMediaType.text:
              {
                itemsToAdd = CLMedia(
                  path: item.path,
                  type: item.type,
                  collectionId: media.collection?.id,
                  md5String: md5String,
                );
              }
          }

          candidates.add(itemsToAdd);
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
}

extension ExtProcess on CLMedia {
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
          final jsonString = jsonEncode(properties);
          printFormattedJson(jsonString);
          _infoLogger(
            getAllValuesForKey(properties, 'creation_time').toString(),
          );
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
}

List<dynamic> getAllValuesForKey(Map<dynamic, dynamic> map, String targetKey) {
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

void printFormattedJson(String jsonString) {
  const encoder =
      JsonEncoder.withIndent('  '); // Use two spaces for indentation
  final prettyPrintedJson = encoder.convert(json.decode(jsonString));
  print(prettyPrintedJson);
}

const _filePrefix = 'Media Processing: ';
bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
