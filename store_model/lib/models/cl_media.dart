// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store_model/extensions/ext_file.dart';

import '../extensions/ext_datetime.dart';
import 'cl_media_type.dart';

@immutable
class CLMedia {
  const CLMedia({
    required this.path,
    required this.type,
    required this.ref,
    required this.id,
    required this.collectionId,
    required this.originalDate,
    required this.createdDate,
    required this.updatedDate,
    required this.md5String,
    required this.isDeleted,
    required this.isHidden,
    required this.pin,
  });

  factory CLMedia.fromJson(String source) =>
      CLMedia.fromMap(json.decode(source) as Map<String, dynamic>);

  factory CLMedia.fromMap(Map<String, dynamic> map) {
    return CLMedia(
      path: map['path'] as String,
      type: CLMediaType.fromMap(map['type'] as Map<String, dynamic>),
      ref: map['ref'] != null ? map['ref'] as String : null,
      id: map['id'] != null ? map['id'] as int : null,
      collectionId:
          map['collectionId'] != null ? map['collectionId'] as int : null,
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'] as String)
          : DateTime.now(),
      updatedDate: map['updatedDate'] != null
          ? DateTime.parse(map['updatedDate'] as String)
          : null,
      originalDate: map['originalDate'] != null
          ? DateTime.parse(map['originalDate'] as String)
          : map['createdDate'] != null
              ? DateTime.parse(map['createdDate'] as String)
              : DateTime.now(),
      md5String: map['md5String'] as String,
      isDeleted: map['isDeleted'] != null ? map['isDeleted'] as bool : null,
      isHidden: map['isHidden'] != null ? map['isHidden'] as bool : null,
      pin: map['pin'] != null ? map['pin'] as String : null,
    );
  }
  final String path;
  final CLMediaType type;
  final String? ref;
  final int? id;
  final int? collectionId;
  final DateTime? originalDate;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String md5String;
  final bool? isDeleted;
  final bool? isHidden;
  final String? pin;

  CLMedia copyWith({
    String? path,
    CLMediaType? type,
    String? ref,
    int? id,
    int? collectionId,
    DateTime? originalDate,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? md5String,
    bool? isDeleted,
    bool? isHidden,
    String? pin,
  }) {
    return CLMedia(
      path: path ?? this.path,
      type: type ?? this.type,
      ref: ref ?? this.ref,
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      originalDate: originalDate ?? this.originalDate,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      md5String: md5String ?? this.md5String,
      isDeleted: isDeleted ?? this.isDeleted,
      isHidden: isHidden ?? this.isHidden,
      pin: pin ?? this.pin,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'path': path,
      'type': type.name,
      'ref': ref,
      'id': id,
      'collectionId': collectionId,
      'originalDate': originalDate?.toSQL(),
      'md5String': md5String,
      'isDeleted': (isDeleted ?? false) ? 1 : 0,
      'isHidden': (isHidden ?? false) ? 1 : 0,
      'pin': pin,
    };
  }

  String toJson() => json.encode(toMap());

  CLMedia removePin() {
    return CLMedia(
      path: path,
      type: type,
      ref: ref,
      id: id,
      collectionId: collectionId,
      originalDate: originalDate,
      createdDate: createdDate,
      updatedDate: updatedDate,
      md5String: md5String,
      isDeleted: isDeleted,
      isHidden: isHidden,
      pin: null,
    );
  }

  CLMedia removeCollectionId() {
    return CLMedia(
      path: path,
      type: type,
      ref: ref,
      id: id,
      collectionId: null,
      originalDate: originalDate,
      createdDate: createdDate,
      updatedDate: updatedDate,
      md5String: md5String,
      isDeleted: isDeleted,
      isHidden: isHidden,
      pin: pin,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'CLMedia(path: $path, type: $type, ref: $ref, id: $id, collectionId: $collectionId, originalDate: $originalDate, createdDate: $createdDate, updatedDate: $updatedDate, md5String: $md5String, isDeleted: $isDeleted, isHidden: $isHidden, pin: $pin)';
  }

  @override
  bool operator ==(covariant CLMedia other) {
    if (identical(this, other)) return true;

    return other.path == path &&
        other.type == type &&
        other.ref == ref &&
        other.id == id &&
        other.collectionId == collectionId &&
        other.originalDate == originalDate &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate &&
        other.md5String == md5String &&
        other.isDeleted == isDeleted &&
        other.isHidden == isHidden &&
        other.pin == pin;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        type.hashCode ^
        ref.hashCode ^
        id.hashCode ^
        collectionId.hashCode ^
        originalDate.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode ^
        md5String.hashCode ^
        isDeleted.hashCode ^
        isHidden.hashCode ^
        pin.hashCode;
  }

  factory CLMedia.fromFile(
    String path, {
    required CLMediaType type,
    required String md5String,
    required DateTime? originalDate,
    required DateTime? createdDate,
    required DateTime? updatedDate,
    bool isDeleted = false,
    bool isHidden = true,
  }) {
    return CLMedia(
      path: path,
      type: type,
      ref: null,
      id: null,
      collectionId: null,
      originalDate: originalDate,
      createdDate: createdDate,
      updatedDate: updatedDate,
      md5String: md5String,
      isDeleted: isDeleted,
      isHidden: isHidden,
      pin: null,
    );
  }
}

@immutable
class OnDeviceMedia {
  const OnDeviceMedia(this.media);

  final CLMedia media;

  String get randomString5 => getRandomString(5);

  String getRandomString(int length) {
    const characters = '0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

  String getAvailableFileName(String fileName) {
    var file = File(fileName);
    if (!file.existsSync()) {
      return fileName;
    }

    final baseName = file.uri.pathSegments.last.split('.').first;
    final extension = file.uri.pathSegments.last.split('.').last;
    final dir = file.uri.pathSegments
        .sublist(0, file.uri.pathSegments.length - 1)
        .join('/');

    while (file.existsSync()) {
      final newFileName = '$dir/${baseName}__$randomString5.$extension';
      file = File(newFileName);
    }

    return file.path;
  }

  static Future<CLMedia> create(String path) async {
    if (!path.startsWith('/')) {
      throw Exception('invalid path');
    }
    final f = File(path);
    if (!f.existsSync()) {
      throw Exception('media not found');
    }
    final type = await f.identifyMediaType();

    if (!type.isSupported) {
      throw Exception('media not supported');
    }
    final md5String = await File(path).checksum;

    return CLMedia.fromFile(
      path,
      type: type,
      md5String: md5String,
      originalDate: await f.originalDate,
      createdDate: null,
      updatedDate: null,
    );
  }

  CLMedia copyToDir(
    String toDir, {
    required Directory Function(int id) onGetLocalPathForCollectionID,
  }) =>
      _copyTo(
        onGetLocalPathForCollectionID: onGetLocalPathForCollectionID,
        toDir: toDir,
      );
  CLMedia copyToCollection(
    CLMedia media,
    int collectionId, {
    required Directory Function(int id) onGetLocalPathForCollectionID,
  }) =>
      _copyTo(
        onGetLocalPathForCollectionID: onGetLocalPathForCollectionID,
        toCollection: collectionId,
      );

  CLMedia _copyTo({
    required Directory Function(int id) onGetLocalPathForCollectionID,
    String? toDir,
    int? toCollection,
  }) {
    final File sourceFile;

    {
      if (media.path.startsWith('/')) {
        sourceFile = File(media.path);
      } else if (media.collectionId != null) {
        sourceFile = File(
          path_handler.join(
            onGetLocalPathForCollectionID(media.collectionId!).path,
            media.path,
          ),
        );
      } else {
        throw Exception(
          'Media is invalid, '
          'relative path is provided when collectionId is not provided',
        );
      }
      if (!sourceFile.existsSync()) {
        throw Exception('Media not found');
      }
    }
    final File destFile;
    {
      final Directory targetDir;
      if (toDir != null) {
        targetDir = Directory(toDir);
        if (toCollection != null) {
          throw Exception("both toDir and toCollection can't be specified");
        }
      } else if (toCollection != null) {
        targetDir = onGetLocalPathForCollectionID(toCollection);
      } else {
        throw Exception('either toDir or collection must be provided');
      }
      destFile = File(
        getAvailableFileName(
          path_handler.join(
            targetDir.path,
            path_handler.basename(sourceFile.path),
          ),
        ),
      )..createSync(recursive: true);
    }
    sourceFile.copySync(destFile.path);
    if (toCollection != null) {
      return media.copyWith(collectionId: toCollection);
    } else {
      return media.copyWith(path: destFile.path).removeCollectionId();
    }
  }

  Future<void> delete() async {
    await File(media.path).deleteIfExists();
  }
}
