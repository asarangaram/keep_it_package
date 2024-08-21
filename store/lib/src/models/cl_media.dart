// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import '../extensions/ext_datetime.dart';
import '../extensions/ext_file.dart';
import '../extensions/ext_string.dart';
import 'cl_media_type.dart';

@immutable
class CLMediaBase {
  const CLMediaBase({
    required this.path,
    required this.type,
    this.ref,
    this.originalDate,
    this.createdDate,
    this.updatedDate,
    this.md5String,
  });
  final String path;
  final CLMediaType type;
  final String? ref;
  final DateTime? originalDate;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? md5String;

  Future<void> deleteFile() async {
    await File(path).deleteIfExists();
  }

  CLMediaBase copyWith({
    String? path,
    CLMediaType? type,
    String? ref,
    DateTime? originalDate,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? md5String,
  }) {
    return CLMediaBase(
      path: path ?? this.path,
      type: type ?? this.type,
      ref: ref ?? this.ref,
      originalDate: originalDate ?? this.originalDate,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      md5String: md5String ?? this.md5String,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'CLMediaFile(path: $path, type: $type, ref: $ref, originalDate: $originalDate, createdDate: $createdDate, updatedDate: $updatedDate, md5String: $md5String)';
  }

  @override
  bool operator ==(covariant CLMediaBase other) {
    if (identical(this, other)) return true;

    return other.path == path &&
        other.type == type &&
        other.ref == ref &&
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
        originalDate.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode ^
        md5String.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'path': path,
      'type': type.name,
      'ref': ref,
      'originalDate': originalDate?.millisecondsSinceEpoch,
      'createdDate': createdDate?.millisecondsSinceEpoch,
      'updatedDate': updatedDate?.millisecondsSinceEpoch,
      'md5String': md5String,
    };
  }

  factory CLMediaBase.fromMap(Map<String, dynamic> map) {
    return CLMediaBase(
      path: map['path'] as String,
      type: CLMediaType.values.asNameMap()[map['type'] as String]!,
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
    );
  }

  String toJson() => json.encode(toMap());

  factory CLMediaBase.fromJson(String source) =>
      CLMediaBase.fromMap(json.decode(source) as Map<String, dynamic>);
}

@immutable
class CLMedia extends CLMediaBase {
  CLMedia({
    required super.path,
    required super.type,
    required this.collectionId,
    super.ref,
    this.id,
    super.originalDate,
    super.createdDate,
    super.updatedDate,
    super.md5String,
    this.isDeleted,
    this.isHidden,
    this.pin,
    this.serverUID,
    this.locallyModified = true,
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
        break;
    }
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
      serverUID: map['serverUID'] != null ? map['serverUID'] as int : null,
      locallyModified: (map['locallyModified'] as int? ?? 1) == 1,
    );
  }

  final bool? isDeleted;
  final bool? isHidden;
  final String? pin;

  final int? id;
  final int? collectionId;
  final int? serverUID;
  final bool locallyModified;

  @override
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
    int? serverUID,
    bool? locallyModified,
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
      serverUID: serverUID ?? this.serverUID,
      locallyModified: locallyModified ?? this.locallyModified,
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
      serverUID: serverUID,
      /* locallyModified: true, */
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
        other.pin == pin &&
        other.serverUID == serverUID &&
        other.locallyModified == locallyModified;
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
        pin.hashCode ^
        serverUID.hashCode ^
        locallyModified.hashCode;
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'CLMedia(path: $path, type: $type, ref: $ref, id: $id, collectionId: $collectionId, originalDate: $originalDate, createdDate: $createdDate, updatedDate: $updatedDate, md5String: $md5String, isDeleted: $isDeleted, isHidden: $isHidden, pin: $pin, serverUID: $serverUID, locallyModified: $locallyModified)';
  }

  @override
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
      'serverUID': serverUID,
      'locallyModified': locallyModified ? 1 : 0,
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

  @override
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
      serverUID: serverUID,
      /* locallyModified: true */
    );
  }

  CLMedia removeId() {
    return CLMedia(
      path: path,
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
      serverUID: serverUID,
      /* locallyModified: true */
    );
  }

  String get label => path;
}
