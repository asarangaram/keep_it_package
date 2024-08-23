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
    required super.collectionId,
    this.id,
    super.ref,
    super.originalDate,
    super.createdDate,
    super.updatedDate,
    super.md5String,
    super.isDeleted,
    super.isHidden,
    super.pin,
    this.serverUID,
    this.locallyModified = true,
    this.isAux = false,
    this.haveItOffline = true,
    this.mustDownloadOriginal = true,
    this.downloadStatus,
  });

  factory CLMedia.fromMap(Map<String, dynamic> map) {
    return CLMedia(
      name: map['name'] as String,
      type: CLMediaType.values.asNameMap()[map['type'] as String]!,
      ref: map['ref'] != null ? map['ref'] as String : null,
      id: map['id'] != null ? map['id'] as int : null,
      originalDate: map['originalDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['originalDate'] as int)
          : null,
      collectionId:
          map['collectionId'] != null ? map['collectionId'] as int : null,
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
      isAux: (map['isAux'] as int? ?? 0) != 0,
      serverUID: map['serverUID'] != null ? map['serverUID'] as int : null,
      locallyModified: (map['locallyModified'] as int? ?? 1) != 0,
      haveItOffline: (map['haveItOffline'] as int? ?? 1) != 0,
      mustDownloadOriginal: (map['mustDownloadOriginal'] as int? ?? 1) != 0,
      downloadStatus: map['alreadyDownloaded'] as String?,
    );
  }
  final int? id;
  final int? serverUID;
  final bool locallyModified;
  final bool isAux;
  final bool haveItOffline;
  final bool mustDownloadOriginal;
  final String? downloadStatus;

  @override
  CLMedia copyWith({
    int? id,
    String? name,
    CLMediaType? type,
    String? ref,
    DateTime? originalDate,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? md5String,
    bool? isDeleted,
    bool? isHidden,
    String? pin,
    int? collectionId,
    int? serverUID,
    bool? locallyModified,
    bool? isAux,
    bool? haveItOffline,
    bool? mustDownloadOriginal,
    String? alreadyDownloaded,
  }) {
    return CLMedia(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      ref: ref ?? this.ref,
      originalDate: originalDate ?? this.originalDate,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      md5String: md5String ?? this.md5String,
      isDeleted: isDeleted ?? this.isDeleted,
      isHidden: isHidden ?? this.isHidden,
      pin: pin ?? this.pin,
      collectionId: collectionId ?? this.collectionId,
      serverUID: serverUID ?? this.serverUID,
      locallyModified: locallyModified ?? this.locallyModified,
      isAux: isAux ?? this.isAux,
      haveItOffline: haveItOffline ?? this.haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal ?? this.mustDownloadOriginal,
      downloadStatus: alreadyDownloaded ?? downloadStatus,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'CLMedia(id: $id, name: $name, type: $type, ref: $ref, originalDate: $originalDate, createdDate: $createdDate, updatedDate: $updatedDate, md5String: $md5String, isDeleted: $isDeleted, isHidden: $isHidden, pin: $pin, collectionId: $collectionId, serverUID: $serverUID, locallyModified: $locallyModified, isAux: $isAux, haveItOffline: $haveItOffline, mustDownloadOriginal: $mustDownloadOriginal, alreadyDownloaded: $downloadStatus)';
  }

  @override
  bool operator ==(covariant CLMedia other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.type == type &&
        other.ref == ref &&
        other.originalDate == originalDate &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate &&
        other.md5String == md5String &&
        other.isDeleted == isDeleted &&
        other.isHidden == isHidden &&
        other.pin == pin &&
        other.collectionId == collectionId &&
        other.serverUID == serverUID &&
        other.locallyModified == locallyModified &&
        other.isAux == isAux &&
        other.haveItOffline == haveItOffline &&
        other.mustDownloadOriginal == mustDownloadOriginal &&
        other.downloadStatus == downloadStatus;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        ref.hashCode ^
        originalDate.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode ^
        md5String.hashCode ^
        isDeleted.hashCode ^
        isHidden.hashCode ^
        pin.hashCode ^
        collectionId.hashCode ^
        serverUID.hashCode ^
        locallyModified.hashCode ^
        isAux.hashCode ^
        haveItOffline.hashCode ^
        mustDownloadOriginal.hashCode ^
        downloadStatus.hashCode;
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'type': type.name,
      'ref': ref,
      'id': id,
      'collectionId': collectionId,
      'originalDate': originalDate?.millisecondsSinceEpoch,
      'createdDate': createdDate?.millisecondsSinceEpoch,
      'updatedDate': updatedDate?.millisecondsSinceEpoch,
      'md5String': md5String,
      'isDeleted': (isDeleted ?? false) ? 1 : 0,
      'isHidden': (isHidden ?? false) ? 1 : 0,
      'pin': pin,
      'isAux': isAux,
      'serverUID': serverUID,
      'locallyModified': locallyModified ? 1 : 0,
      'haveItOffline': haveItOffline ? 1 : 0,
      'mustDownloadOriginal': mustDownloadOriginal ? 1 : 0,
      'alreadyDownloaded': downloadStatus,
    };
  }

  factory CLMedia.fromJson(String source) => CLMedia.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toJson() => json.encode(toMap());

  CLMedia removePin() {
    return CLMedia(
      name: name,
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
      isAux: isAux,
      serverUID: serverUID,
      haveItOffline: haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal,
      downloadStatus: downloadStatus,

      /* locallyModified: true */
    );
  }

  CLMedia removeId() {
    return CLMedia(
      name: name,
      type: type,
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
      serverUID: serverUID,
      /* locallyModified: true */
      haveItOffline: haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal,
      downloadStatus: downloadStatus,
    );
  }

  CLMedia setCollectionId(int? newCollectionId) {
    return CLMedia(
      name: name,
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
      isAux: isAux,
      serverUID: serverUID,
      /* locallyModified: true, */
      haveItOffline: haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal,
      downloadStatus: downloadStatus,
    );
  }
}
