import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:exif/exif.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:mime/mime.dart';

import '../models/cl_media_type.dart';
import '../models/media_metadata.dart';

extension ExtFile on File {
  Future<void> deleteIfExists() async {
    if (await exists()) {
      await delete();
    }
  }

  Future<String> get checksum async {
    try {
      final stream = openRead();
      final hash = await md5.bind(stream).first;

      // NOTE: You might not need to convert it to base64
      return hash.toString();
    } catch (exception) {
      throw Exception('unable to determine md5');
    }
  }

  Future<MediaMetaData?> getImageMetaData({bool? regenerate}) async {
    try {
      if (regenerate != null && regenerate == true) {
        final fileBytes = readAsBytesSync();
        final data = await readExifFromBytes(fileBytes);

        var dateTimeString = data['EXIF DateTimeOriginal']!.printable;
        final dateAndTime = dateTimeString.split(' ');
        dateTimeString =
            [dateAndTime[0].replaceAll(':', '-'), dateAndTime[1]].join(' ');

        final originalDate = DateTime.parse(dateTimeString);
        return MediaMetaData(originalDate: originalDate);
      }
    } catch (e) {
      //ignore the error and continue without metadata
    }
    return null;
  }

  Future<MediaMetaData?> getVideoMetaData({bool? regenerate}) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final properties = session.getMediaInformation()?.getAllProperties();
    if (properties != null) {
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
          return MediaMetaData(originalDate: originalDate);
        }
      } catch (e) {
        //ignore the error and continue without metadata
      }
    }
    return null;
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

  Future<CLMediaType> identifyMediaType() async {
    final mimeType = switch (lookupMimeType(path)) {
      (final String mime) when mime.startsWith('image') => CLMediaType.image,
      (final String mime) when mime.startsWith('video') => CLMediaType.video,
      _ => CLMediaType.file
    };

    return mimeType;
  }

  Future<DateTime?> get originalDate async {
    final type = await identifyMediaType();
    return switch (type) {
      CLMediaType.image => await getImageMetaData(regenerate: true),
      CLMediaType.video => await getVideoMetaData(regenerate: true),
      _ => null
    }
        ?.originalDate;
  }
}
