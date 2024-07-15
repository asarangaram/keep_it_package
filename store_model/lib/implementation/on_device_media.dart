import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store_model/extensions/ext_file.dart';

import '../models/cl_media.dart';
import '../models/cl_media_type.dart';

@immutable
class OnDeviceMedia extends CLMedia {
  const OnDeviceMedia({
    required super.path,
    required super.type,
    required super.ref,
    required super.id,
    required super.collectionId,
    required super.originalDate,
    required super.createdDate,
    required super.updatedDate,
    required super.md5String,
    required super.isDeleted,
    required super.isHidden,
    required super.pin,
  });
  factory OnDeviceMedia.fromFile(
    String path, {
    required CLMediaType type,
    required String md5String,
    required DateTime? originalDate,
    required DateTime? createdDate,
    required DateTime? updatedDate,
    bool isDeleted = false,
    bool isHidden = true,
  }) {
    return OnDeviceMedia(
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

  factory OnDeviceMedia.fromJson(String source) =>
      OnDeviceMedia.fromMap(json.decode(source) as Map<String, dynamic>);

  factory OnDeviceMedia.fromMap(Map<String, dynamic> map) {
    return OnDeviceMedia(
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

    return OnDeviceMedia.fromFile(
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
      if (path.startsWith('/')) {
        sourceFile = File(path);
      } else if (collectionId != null) {
        sourceFile = File(
          path_handler.join(
            onGetLocalPathForCollectionID(collectionId!).path,
            path,
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
      return copyWith(collectionId: toCollection);
    } else {
      return copyWith(path: destFile.path).removeCollectionId();
    }
  }

  Future<void> delete() async {
    await File(path).deleteIfExists();
  }

  CLMedia removePin() {
    return OnDeviceMedia(
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
    return OnDeviceMedia(
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

  CLMedia setCollectionId(int? collectionId) {
    if (collectionId != null) return copyWith(collectionId: collectionId);
    return removeCollectionId();
  }

  OnDeviceMedia copyWith({
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
    return OnDeviceMedia(
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
}
