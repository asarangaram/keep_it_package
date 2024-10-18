import 'dart:convert';
import 'dart:io';
import 'package:exif/exif.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';

import 'media_metadata.dart';

extension ExtFileAnalysis on File {
  Future<MediaMetaData?> getImageMetaData() async {
    try {
      final fileBytes = readAsBytesSync();
      final data = await readExifFromBytes(fileBytes);

      var dateTimeString = data['EXIF DateTimeOriginal']!.printable;
      final dateAndTime = dateTimeString.split(' ');
      dateTimeString =
          [dateAndTime[0].replaceAll(':', '-'), dateAndTime[1]].join(' ');

      final originalDate = DateTime.parse(dateTimeString);
      return MediaMetaData(originalDate: originalDate);
    } catch (e) {
      //ignore the error and continue without metadata
    }
    return null;
  }

  Future<MediaMetaData?> getVideoMetaData() async {
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

  String printFormattedJson(String jsonString) {
    const encoder =
        JsonEncoder.withIndent('  '); // Use two spaces for indentation
    return encoder.convert(json.decode(jsonString));
  }
}
