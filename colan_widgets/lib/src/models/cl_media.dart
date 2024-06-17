// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:colan_widgets/src/models/map_fixer.dart';
import 'package:flutter/material.dart';

import '../extensions/ext_datetime.dart';

@immutable
class CLMedia {
  CLMedia({
    required this.path,
    required this.type,
    this.ref,
    this.id,
    this.collectionId,
    this.originalDate,
    this.createdDate,
    this.updatedDate,
    this.md5String,
    this.isDeleted,
    this.isHidden,
    this.pin,
  }) {
    switch (type) {
      case CLMediaType.text:
        if (!path.startsWith('text:')) {
          throw Exception('text should be prefixed with text:');
        }
      case CLMediaType.url:
        if (!path.isURL()) {
          throw Exception('invalid URL');
        }
      case CLMediaType.image:
      case CLMediaType.video:
      case CLMediaType.audio:
      case CLMediaType.file:
        if (!path.startsWith('/')) {
          throw Exception('Invalid path');
        }
    }
  }

  static MapFixer incomingMapFixer(String basePath) => MapFixer(
        pathType: PathType.absolute,
        basePath: basePath,
        mandatoryKeys: const ['type', 'path', 'md5String'],
        pathKeys: const ['path'],
        removeValues: const ['null'],
      );

  static CLMedia? fromMapNullable(
    Map<String, dynamic> map1, {
    // ignore: avoid_unused_constructor_parameters
    required AppSettings appSettings,
  }) {
    final map = incomingMapFixer(appSettings.directories.media.pathString).fix(
      map1,
      /* onError: (errors) {
        if (errors.isNotEmpty) {
          logger.e(errors.join(','));
          return false;
        }
        return true;
      }, */
    );
    if (map.isEmpty) {
      return null;
    }
    return CLMedia.fromMap(map);
  }

  factory CLMedia.fromMap(Map<String, dynamic> map) {
    return CLMedia(
      path: map['path'] as String,
      type: CLMediaType.values.asNameMap()[map['type'] as String]!,
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
      isDeleted: (map['isDeleted'] as int) != 0,
      isHidden: (map['isHidden'] as int) != 0,
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
  final String? md5String;
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

  CLMedia setCollectionId(int? newCollectionId) {
    return CLMedia(
      path: path,
      type: type,
      ref: ref,
      id: id,
      collectionId: newCollectionId,
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

  @override
  String toString() {
    return 'CLMedia(path: $path, type: $type, ref: $ref, id: $id, '
        'collectionId: $collectionId, '
        'originalDate: $originalDate, createdDate: $createdDate, '
        'updatedDate: $updatedDate, md5String: $md5String, '
        'isDeleted: $isDeleted, isHidden: $isHidden, '
        ' pin: $pin)';
  }

  Map<String, dynamic> toMap({
    required bool validate,
    String? pathPrefix,
  }) {
    return <String, dynamic>{
      'path': relativePath(
        path,
        pathPrefix: pathPrefix,
        validate: validate,
      ),
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

  static String relativePath(
    String fullPath, {
    required String? pathPrefix,
    required bool validate,
  }) {
    if (validate && !File(fullPath).existsSync()) {
      throw Exception('file not found');
    }

    if (pathPrefix != null && fullPath.startsWith(pathPrefix)) {
      return fullPath.replaceFirst('$pathPrefix/', '').replaceAll('//', '/');
    }
    return fullPath;
  }

  /*  /// Not used
  factory CLMedia.fromJson(String source) => CLMedia.fromMap(
        json.decode(source) as Map<String, dynamic>,
        validate: true,
      ); */

  String toJson() => json.encode(toMap(validate: true));

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
    );
  }
}
