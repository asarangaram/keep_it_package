// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

import 'cl_media_base.dart';
import 'cl_media_type.dart';

@immutable
class CLMedia extends CLMediaBase {
  const CLMedia({
    required super.name,
    required super.type,
    required super.fExt,
    required super.collectionId,
    required this.isPreviewCached,
    required this.isMediaCached,
    required this.isMediaOriginal,
    required this.isEdited,
    required this.previewLog,
    required this.mediaLog,
    required this.serverUID,
    required this.haveItOffline,
    required this.mustDownloadOriginal,
    super.ref,
    super.originalDate,
    super.createdDate,
    super.updatedDate,
    super.md5String,
    super.isDeleted,
    super.isHidden,
    super.pin,
    super.isAux,
    this.id,
  });

  factory CLMedia.fromMap(Map<String, dynamic> map) {
    return CLMedia(
      name: map['name'] as String,
      type: CLMediaType.values.asNameMap()[map['type'] as String]!,
      fExt: map['fExt'] as String,
      ref: map['ref'] != null ? map['ref'] as String : null,
      originalDate: map['originalDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['originalDate'] as int)
          : null,
      createdDate: map['createdDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int)
          : null,
      updatedDate: map['updatedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int)
          : null,
      md5String: map['md5String'] != null ? map['md5String'] as String : null,
      isDeleted: (map['isDeleted'] as int) != 0,
      isHidden: (map['isHidden'] as int? ?? 0) != 0,
      pin: map['pin'] != null ? map['pin'] as String : null,
      collectionId:
          map['collectionId'] != null ? map['collectionId'] as int : null,
      isAux: (map['isAux'] as int? ?? 0) != 0,
      id: map['id'] != null ? map['id'] as int : null,
      isPreviewCached: (map['isPreviewCached'] as int) != 0,
      isMediaCached: (map['isMediaCached'] as int) != 0,
      previewLog:
          map['previewLog'] != null ? map['previewLog'] as String : null,
      mediaLog: map['mediaLog'] != null ? map['mediaLog'] as String : null,
      isMediaOriginal: (map['isMediaOriginal'] as int) != 0,
      serverUID: map['serverUID'] != null ? map['serverUID'] as int : null,
      isEdited: (map['isEdited'] as int) != 0,
      haveItOffline: (map['haveItOffline'] as int) != 0,
      mustDownloadOriginal: (map['mustDownloadOriginal'] as int) != 0,
    );
  }

  factory CLMedia.fromJson(String source) => CLMedia.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  final int? id;
  final bool isPreviewCached;
  final bool isMediaCached;
  final String? previewLog;
  final String? mediaLog;
  final bool isMediaOriginal;
  final int? serverUID;
  final bool isEdited;
  final bool haveItOffline;
  final bool mustDownloadOriginal;

  @override
  CLMedia copyWith({
    String? name,
    CLMediaType? type,
    String? fExt,
    String? ref,
    DateTime? originalDate,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? md5String,
    bool? isDeleted,
    bool? isHidden,
    String? pin,
    int? collectionId,
    bool? isAux,
    int? id,
    bool? isPreviewCached,
    bool? isMediaCached,
    String? previewLog,
    String? mediaLog,
    bool? isMediaOriginal,
    int? serverUID,
    bool? isEdited,
    bool? haveItOffline,
    bool? mustDownloadOriginal,
  }) {
    return CLMedia(
      name: name ?? this.name,
      type: type ?? this.type,
      fExt: fExt ?? this.fExt,
      ref: ref ?? this.ref,
      originalDate: originalDate ?? this.originalDate,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      md5String: md5String ?? this.md5String,
      isDeleted: isDeleted ?? this.isDeleted,
      isHidden: isHidden ?? this.isHidden,
      pin: pin ?? this.pin,
      collectionId: collectionId ?? this.collectionId,
      isAux: isAux ?? this.isAux,
      id: id ?? this.id,
      isPreviewCached: isPreviewCached ?? this.isPreviewCached,
      isMediaCached: isMediaCached ?? this.isMediaCached,
      previewLog: previewLog ?? this.previewLog,
      mediaLog: mediaLog ?? this.mediaLog,
      isMediaOriginal: isMediaOriginal ?? this.isMediaOriginal,
      serverUID: serverUID ?? this.serverUID,
      isEdited: isEdited ?? this.isEdited,
      haveItOffline: haveItOffline ?? this.haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal ?? this.mustDownloadOriginal,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'CLMediaBase(id: $id, name: $name, type: $type, fExt: $fExt, ref: $ref, originalDate: $originalDate, createdDate: $createdDate, updatedDate: $updatedDate, md5String: $md5String, isDeleted: $isDeleted, isHidden: $isHidden, pin: $pin, collectionId: $collectionId, isAux: $isAux, isPreviewCached: $isPreviewCached, isMediaCached: $isMediaCached, previewLog: $previewLog, mediaLog: $mediaLog, isMediaOriginal: $isMediaOriginal, serverUID: $serverUID, isEdited: $isEdited, haveItOffline: $haveItOffline, mustDownloadOriginal: $mustDownloadOriginal)';
  }

  @override
  bool operator ==(covariant CLMedia other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.type == type &&
        other.fExt == fExt &&
        other.ref == ref &&
        other.originalDate == originalDate &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate &&
        other.md5String == md5String &&
        other.isDeleted == isDeleted &&
        other.isHidden == isHidden &&
        other.pin == pin &&
        other.collectionId == collectionId &&
        other.isAux == isAux &&
        other.id == id &&
        other.isPreviewCached == isPreviewCached &&
        other.isMediaCached == isMediaCached &&
        other.previewLog == previewLog &&
        other.mediaLog == mediaLog &&
        other.isMediaOriginal == isMediaOriginal &&
        other.serverUID == serverUID &&
        other.isEdited == isEdited &&
        other.haveItOffline == haveItOffline &&
        other.mustDownloadOriginal == mustDownloadOriginal;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        type.hashCode ^
        fExt.hashCode ^
        ref.hashCode ^
        originalDate.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode ^
        md5String.hashCode ^
        isDeleted.hashCode ^
        isHidden.hashCode ^
        pin.hashCode ^
        collectionId.hashCode ^
        isAux.hashCode ^
        id.hashCode ^
        isPreviewCached.hashCode ^
        isMediaCached.hashCode ^
        previewLog.hashCode ^
        mediaLog.hashCode ^
        isMediaOriginal.hashCode ^
        serverUID.hashCode ^
        isEdited.hashCode ^
        haveItOffline.hashCode ^
        mustDownloadOriginal.hashCode;
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'type': type.name,
      'fExt': fExt,
      'ref': ref,
      'originalDate': originalDate?.millisecondsSinceEpoch,
      'createdDate': createdDate?.millisecondsSinceEpoch,
      'updatedDate': updatedDate?.millisecondsSinceEpoch,
      'md5String': md5String,
      'isDeleted': (isDeleted ?? false) ? 1 : 0,
      'isHidden': (isHidden ?? false) ? 1 : 0,
      'pin': pin,
      'collectionId': collectionId,
      'isAux': isAux,
      'id': id,
      'isPreviewCached': isPreviewCached ? 1 : 0,
      'isMediaCached': isMediaCached ? 1 : 0,
      'previewLog': previewLog,
      'mediaLog': mediaLog,
      'isMediaOriginal': isMediaOriginal ? 1 : 0,
      'serverUID': serverUID,
      'isEdited': isEdited ? 1 : 0,
      'haveItOffline': haveItOffline ? 1 : 0,
      'mustDownloadOriginal': mustDownloadOriginal ? 1 : 0,
    };
  }

  @override
  String toJson() => json.encode(toMap());

  CLMedia removePin() {
    return CLMedia(
      name: name,
      type: type,
      fExt: fExt,
      ref: ref,
      id: id,
      collectionId: collectionId,
      originalDate: originalDate,
      createdDate: createdDate,
      updatedDate: updatedDate,
      md5String: md5String,
      isDeleted: isDeleted,
      isHidden: isHidden,
      isAux: isAux,
      isPreviewCached: isPreviewCached,
      isMediaCached: isMediaCached,
      isMediaOriginal: isMediaOriginal,
      isEdited: isEdited,
      previewLog: previewLog,
      mediaLog: mediaLog,
      serverUID: serverUID,
      haveItOffline: haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal,
    );
  }

  CLMedia removeId() {
    return CLMedia(
      name: name,
      type: type,
      fExt: fExt,
      ref: ref,
      collectionId: collectionId,
      originalDate: originalDate,
      createdDate: createdDate,
      updatedDate: updatedDate,
      md5String: md5String,
      isDeleted: isDeleted,
      isHidden: isHidden,
      pin: pin,
      isAux: isAux,
      isPreviewCached: isPreviewCached,
      isMediaCached: isMediaCached,
      isMediaOriginal: isMediaOriginal,
      isEdited: isEdited,
      previewLog: previewLog,
      mediaLog: mediaLog,
      serverUID: serverUID,
      haveItOffline: haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal,
    );
  }

  CLMedia setCollectionId(int? newCollectionId) {
    return CLMedia(
      name: name,
      type: type,
      fExt: fExt,
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
      isAux: isAux,
      isPreviewCached: isPreviewCached,
      isMediaCached: isMediaCached,
      isMediaOriginal: isMediaOriginal,
      isEdited: isEdited,
      previewLog: previewLog,
      mediaLog: mediaLog,
      serverUID: serverUID,
      haveItOffline: haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal,
    );
  }

  bool get isMediaWaitingForDownload =>
      !isMediaCached && mediaLog == null && haveItOffline;

  bool get isPreviewWaitingForDownload =>
      !isPreviewCached && previewLog == null;
}
