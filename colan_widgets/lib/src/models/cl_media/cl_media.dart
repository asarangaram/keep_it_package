// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../extensions/ext_string.dart';
import '../collection.dart';
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
}

class CLMediaList {
  CLMediaList({required this.entries, this.collection});
  final List<CLMedia> entries;
  final Collection? collection;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  @override
  String toString() => 'CLMediaInfoGroup(list: $entries)';

  CLMediaList copyWith({
    List<CLMedia>? entries,
    Collection? collection,
  }) {
    return CLMediaList(
      entries: entries ?? this.entries,
      collection: collection ?? this.collection,
    );
  }

  Iterable<CLMedia> get _stored => entries.where((e) => e.id != null);
  Iterable<CLMedia> get _targetMismatch =>
      _stored.where((e) => e.collectionId != collection?.id);

  List<CLMedia> get targetMismatch => _targetMismatch.toList();
  List<CLMedia> get stored => _stored.toList();

  bool get hasTargetMismatchedItems => _targetMismatch.isNotEmpty;

  CLMediaList mergeMismatch() {
    final items = entries.map((e) => e.setCollectionId(collection?.id));
    return copyWith(entries: items.toList());
  }

  CLMediaList? removeMismatch() {
    final items = entries.where((e) => e.collectionId == collection?.id);
    if (items.isEmpty) return null;

    return copyWith(entries: items.toList());
  }

  CLMediaList? remove(CLMedia itemToRemove) {
    final items = entries.where((e) => e != itemToRemove);
    if (items.isEmpty) return null;

    return copyWith(entries: items.toList());
  }

  List<CLMedia> itemsByType(CLMediaType type) =>
      entries.where((e) => e.type == type).toList();

  List<CLMedia> get videos => itemsByType(CLMediaType.video);
  List<CLMedia> get images => itemsByType(CLMediaType.image);

  List<CLMediaType> get contentTypes =>
      Set<CLMediaType>.from(entries.map((e) => e.type)).toList();
}
