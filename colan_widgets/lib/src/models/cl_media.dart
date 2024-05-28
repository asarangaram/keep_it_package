// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../app_logger.dart';
import '../extensions/ext_datetime.dart';
import '../extensions/ext_string.dart';
import 'cl_media_type.dart';
import 'm1_app_settings.dart';

@immutable
class CLMedia {
  CLMedia({
    required this.path,
    required this.type,
    this.md5String,
    this.ref,
    this.id,
    this.collectionId,
    this.previewWidth,
    this.createdDate,
    this.updatedDate,
    this.originalDate,
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

  factory CLMedia.fromMap(
    Map<String, dynamic> map, {
    // ignore: avoid_unused_constructor_parameters
    required AppSettings appSettings,
  }) {
    final pathPrefix = appSettings.pathPrefix;
    if (CLMediaType.values.asNameMap()[map['type'] as String] == null) {
      throw Exception('Incorrect type');
    }
    // ignore: unnecessary_null_comparison
    final path = ((pathPrefix != null)
        ? '$pathPrefix/${map['path']}'
        : map['path'] as String)
      ..replaceAll('//', '/');
    if (appSettings.shouldValidate && !File(path).existsSync()) {
      exceptionLogger(
        'File not found',
        'CL Media file path read from database is not found',
      );
    }

    return CLMedia(
      path: path,
      type: CLMediaType.values.asNameMap()[map['type'] as String]!,
      ref: map['ref'] != null ? map['ref'] as String : null,
      id: map['id'] != null ? map['id'] as int : null,
      collectionId:
          map['collectionId'] != null ? map['collectionId'] as int : null,
      previewWidth:
          map['previewWidth'] != null ? map['previewWidth'] as int : null,
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'] as String)
          : null,
      updatedDate: map['updatedDate'] != null
          ? DateTime.parse(map['updatedDate'] as String)
          : null,
      originalDate: map['originalDate'] != null
          ? DateTime.parse(map['originalDate'] as String)
          : null,
      md5String: map['md5String'] as String,
    );
  }

  final String path;
  final CLMediaType type;
  final String? ref;
  final int? id;
  final int? collectionId;
  final int? previewWidth;
  final DateTime? originalDate;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? md5String;

  CLMedia copyWith({
    String? path,
    CLMediaType? type,
    String? ref,
    int? id,
    int? collectionId,
    int? previewWidth,
    DateTime? originalDate,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? md5String,
  }) {
    return CLMedia(
      path: path ?? this.path,
      type: type ?? this.type,
      ref: ref ?? this.ref,
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      previewWidth: previewWidth ?? this.previewWidth,
      originalDate: originalDate ?? this.originalDate,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      md5String: md5String ?? this.md5String,
    );
  }

  CLMedia setCollectionId(int? newCollectionId) {
    return CLMedia(
      path: path,
      type: type,
      ref: ref,
      id: id,
      collectionId: newCollectionId,
      previewWidth: previewWidth,
      originalDate: originalDate,
      createdDate: createdDate,
      updatedDate: updatedDate,
      md5String: md5String,
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
        other.previewWidth == previewWidth &&
        other.originalDate == originalDate &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate &&
        other.md5String == md5String;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        type.hashCode ^
        ref.hashCode ^
        id.hashCode ^
        collectionId.hashCode ^
        previewWidth.hashCode ^
        originalDate.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode ^
        md5String.hashCode;
  }

  @override
  String toString() {
    return 'CLMedia(path: $path, type: $type, ref: $ref, id: $id,'
        ' collectionId: $collectionId, previewWidth: $previewWidth,'
        ' originalDate: $originalDate, createdDate: $createdDate,'
        ' updatedDate: $updatedDate, md5String: $md5String)';
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
      'previewWidth': previewWidth,
      'originalDate': originalDate?.toSQL(),
      'md5String': md5String,
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
}
