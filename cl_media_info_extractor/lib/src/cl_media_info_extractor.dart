// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';

import 'cl_media_info_extractor_platform_interface.dart';

@immutable
class CLMediaFile {
  final String path;
  final String md5;
  final int fileSize;
  final String mimeType;
  final String fileSuffix;
  final DateTime? createDate;
  final int? height;
  final int? width;
  final double? duration;
  const CLMediaFile({
    required this.path,
    required this.md5,
    required this.fileSize,
    required this.mimeType,
    required this.fileSuffix,
    this.createDate,
    this.height,
    this.width,
    this.duration,
  });

  static Future<CLMediaFile?> fromExifInfo(Map<String, dynamic> map) async {
    try {
      final exifmap = map['exiftool'][0];
      return CLMediaFile(
        path: exifmap['SourceFile'] as String,
        md5: await checksum(File(exifmap['SourceFile'] as String)),
        fileSize: exifmap['FileSize'] as int,
        mimeType: exifmap['MIMEType'] as String,
        fileSuffix:
            ".${(exifmap['FileTypeExtension'] as String).toLowerCase()}",
        createDate: exifmap['CreateDate'] != null
            ? DateTime.parse(exifmap['CreateDate'] as String)
            : null,
        height: exifmap['ImageHeight'] as int,
        width: exifmap['ImageWidth'] as int,
        duration: exifmap['Duration'] != null
            ? double.tryParse(exifmap['Duration'] as String)
            : null,
      );
    } catch (e) {
      debugPrint("Error parsing exif info: $e");
      return null;
    }
  }

  // TODO(anandas): : use filetype and implement specific md5 computation
  static Future<String> checksum(File file) async {
    try {
      final stream = file.openRead();
      final hash = await crypto.md5.bind(stream).first;

      // NOTE: You might not need to convert it to base64
      return hash.toString();
    } catch (exception) {
      throw Exception('unable to determine md5');
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'path': path,
      'md5': md5,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'fileSuffix': fileSuffix,
      'createDate': createDate,
      'height': height,
      'width': width,
      'duration': duration,
    };
  }

  factory CLMediaFile.fromMap(Map<String, dynamic> map) {
    return CLMediaFile(
      path: (map['path'] ?? '') as String,
      md5: (map['md5'] ?? '') as String,
      fileSize: (map['fileSize'] ?? 0) as int,
      mimeType: (map['mimeType'] ?? '') as String,
      fileSuffix: (map['fileSuffix'] ?? '') as String,
      createDate: map['createDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['createDate'] ?? 0) as int)
          : null,
      height: map['height'] != null ? map['height'] as int : null,
      width: map['width'] != null ? map['width'] as int : null,
      duration: map['duration'] != null ? map['duration'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CLMediaFile.fromJson(String source) =>
      CLMediaFile.fromMap(json.decode(source) as Map<String, dynamic>);

  static Future<CLMediaFile?> fromPath(
    String mediaPath, {
    String exiftoolPath = "/usr/local/bin/exiftool",
  }) async {
    final exifinfo = await ClMediaInfoExtractorPlatform.instance
        .getMediaInfo(exiftoolPath, mediaPath);

    return CLMediaFile.fromExifInfo(exifinfo);
  }
}
