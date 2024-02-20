// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../extensions/ext_string.dart';
import 'cl_media_type.dart';

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
          map['collection_id'] != null ? map['collection_id'] as int : null,
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

  factory CLMedia.fromJson(
    String source, {
    required String? pathPrefix,
  }) =>
      CLMedia.fromMap(
        json.decode(source) as Map<String, dynamic>,
        pathPrefix: pathPrefix,
      );

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
    required String? pathPrefix,
  }) {
    if (md5String == null) {
      throw Exception('md5String must be determined before generating map');
    }
    final updatedPath =
        pathPrefix != null ? path.replaceFirst(pathPrefix, '') : path;

    return <String, dynamic>{
      'path': updatedPath,
      'type': type.name,
      'ref': ref,
      'id': id,
      'collection_id': collectionId,
      'previewWidth': previewWidth,
      'createdDate': createdDate,
      'updatedDate': updatedDate,
      'originalDate': originalDate,
      'md5String': md5String,
    };
  }

  String toJson({
    required String? pathPrefix,
  }) =>
      json.encode(toMap(pathPrefix: pathPrefix));
}

class CLMediaInfoGroup {
  CLMediaInfoGroup({required this.list, this.targetID});
  final List<CLMedia> list;
  final int? targetID;

  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;

  @override
  String toString() => 'CLMediaInfoGroup(list: $list)';

  CLMediaInfoGroup copyWith({
    List<CLMedia>? list,
    int? targetID,
  }) {
    return CLMediaInfoGroup(
      list: list ?? this.list,
      targetID: targetID ?? this.targetID,
    );
  }

  Iterable<CLMedia> get _stored => list.where((e) => e.id != null);
  Iterable<CLMedia> get _targetMismatch => (targetID == null)
      ? _stored
      : _stored.where((e) => (e.collectionId != targetID) && (e.id != null));
  List<CLMedia> get targetMismatch => _targetMismatch.toList();
  List<CLMedia> get stored => _stored.toList();

  bool get hasTargetMismatchedItems => _targetMismatch.isNotEmpty;

  CLMediaInfoGroup mergeMismatch() {
    final items = list.map((e) => e.copyWith(collectionId: targetID));
    return copyWith(list: items.toList());
  }

  CLMediaInfoGroup? removeMismatch() {
    final items = list.where((e) => e.collectionId == targetID);
    if (items.isEmpty) return null;

    return copyWith(list: items.toList());
  }

  CLMediaInfoGroup? remove(CLMedia itemToRemove) {
    final items = list.where((e) => e != itemToRemove);
    if (items.isEmpty) return null;

    return copyWith(list: items.toList());
  }
}
