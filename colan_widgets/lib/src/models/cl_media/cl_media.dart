// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import 'cl_media_type.dart';

@immutable
class CLMedia {
  CLMedia({
    required this.path,
    required this.type,
    this.ref,
    this.id,
    this.collectionId,
    this.previewWidth = 600,
  }) {
    if (!path.startsWith('/')) {
      throw Exception('CLMedia must have absolute path');
    }
  }
  final String path;
  final CLMediaType type;
  final String? ref;
  final int? id;
  final int? collectionId;
  final int previewWidth;

  CLMedia copyWith({
    String? path,
    CLMediaType? type,
    String? ref,
    int? id,
    int? collectionId,
  }) {
    return CLMedia(
      path: path ?? this.path,
      type: type ?? this.type,
      ref: ref ?? this.ref,
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
    );
  }

  @override
  bool operator ==(covariant CLMedia other) {
    if (identical(this, other)) return true;

    return other.path == path &&
        other.type == type &&
        other.ref == ref &&
        other.id == id &&
        other.collectionId == collectionId;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        type.hashCode ^
        ref.hashCode ^
        id.hashCode ^
        collectionId.hashCode;
  }

  @override
  String toString() {
    return 'CLMedia(path: $path, type: $type, ref: $ref, id: $id, '
        'collectionId: $collectionId)';
  }

  Map<String, dynamic> toMap({
    required String? pathPrefix,
  }) {
    final updatedPath =
        pathPrefix != null ? path.replaceFirst(pathPrefix, '') : path;

    return <String, dynamic>{
      'path': updatedPath,
      'type': type.name,
      'ref': ref,
      'id': id,
      'collectionId': collectionId,
      'previewWidth': previewWidth,
    };
  }

  factory CLMedia.fromMap(
    Map<String, dynamic> map, {
    required String? pathPrefix,
  }) {
    if (CLMediaType.values.asNameMap()[map['type'] as String] == null) {
      throw Exception('Incorrect type');
    }
    final prefix = pathPrefix ?? '';
    return CLMedia(
      path: "$prefix/${map['path'] as String}".replaceAll('//', '/'),
      type: CLMediaType.values.asNameMap()[map['type'] as String]!,
      ref: map['ref'] != null ? map['ref'] as String : null,
      id: map['id'] != null ? map['id'] as int : null,
      collectionId:
          map['collectionId'] != null ? map['collectionId'] as int : null,
      previewWidth: map['previewWidth'] as int,
    );
  }

  String toJson({
    required String? pathPrefix,
  }) =>
      json.encode(toMap(pathPrefix: pathPrefix));

  factory CLMedia.fromJson(
    String source, {
    required String? pathPrefix,
  }) =>
      CLMedia.fromMap(
        json.decode(source) as Map<String, dynamic>,
        pathPrefix: pathPrefix,
      );
}

class CLMediaInfoGroup {
  CLMediaInfoGroup(this.list, {this.targetID});
  final List<CLMedia> list;
  final int? targetID;

  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;

  @override
  String toString() => 'CLMediaInfoGroup(list: $list)';
}
