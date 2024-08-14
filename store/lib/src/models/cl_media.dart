// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:store/src/extensions/ext_datetime.dart';

import 'cl_media_type.dart';

@immutable
class CLMedia {
  final int? id;
  final String name;
  final CLMediaType type;
  final int? collectionId;
  final String? md5String;
  final DateTime? createdDate;
  final DateTime? originalDate;
  final DateTime? updatedDate;
  final String? ref;
  final bool? isDeleted;
  final String path;
  final bool? isHidden;
  final String? pin;

  factory CLMedia({
    required CLMediaType type,
    required String path,
    int? collectionId,
    String? md5String,
    DateTime? createdDate,
    DateTime? originalDate,
    DateTime? updatedDate,
    String? ref,
    bool? isDeleted,
    bool? isHidden,
    String? pin,
    int? id,
    String name = 'Unnamed',
  }) {
    return CLMedia.regid(
      id: id,
      name: name,
      type: type,
      collectionId: collectionId,
      md5String: md5String,
      createdDate: createdDate,
      originalDate: originalDate,
      updatedDate: updatedDate,
      ref: ref,
      isDeleted: isDeleted,
      path: path,
      isHidden: isHidden,
      pin: pin,
    );
  }

  const CLMedia.regid({
    required this.name,
    required this.type,
    required this.path,
    required this.id,
    required this.collectionId,
    required this.md5String,
    required this.createdDate,
    required this.originalDate,
    required this.updatedDate,
    required this.ref,
    required this.isDeleted,
    required this.isHidden,
    required this.pin,
  });

  CLMedia copyWith({
    int? id,
    String? name,
    CLMediaType? type,
    int? collectionId,
    String? md5String,
    DateTime? createdDate,
    DateTime? originalDate,
    DateTime? updatedDate,
    String? ref,
    bool? isDeleted,
    String? path,
    bool? isHidden,
    String? pin,
  }) {
    return CLMedia(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      collectionId: collectionId ?? this.collectionId,
      md5String: md5String ?? this.md5String,
      createdDate: createdDate ?? this.createdDate,
      originalDate: originalDate ?? this.originalDate,
      updatedDate: updatedDate ?? this.updatedDate,
      ref: ref ?? this.ref,
      isDeleted: isDeleted ?? this.isDeleted,
      path: path ?? this.path,
      isHidden: isHidden ?? this.isHidden,
      pin: pin ?? this.pin,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'CLMedia(id: $id, name: $name, type: $type, collectionId: $collectionId, md5String: $md5String, createdDate: $createdDate, originalDate: $originalDate, updatedDate: $updatedDate, ref: $ref, isDeleted: $isDeleted, path: $path, isHidden: $isHidden, pin: $pin)';
  }

  @override
  bool operator ==(covariant CLMedia other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.type == type &&
        other.collectionId == collectionId &&
        other.md5String == md5String &&
        other.createdDate == createdDate &&
        other.originalDate == originalDate &&
        other.updatedDate == updatedDate &&
        other.ref == ref &&
        other.isDeleted == isDeleted &&
        other.path == path &&
        other.isHidden == isHidden &&
        other.pin == pin;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        collectionId.hashCode ^
        md5String.hashCode ^
        createdDate.hashCode ^
        originalDate.hashCode ^
        updatedDate.hashCode ^
        ref.hashCode ^
        isDeleted.hashCode ^
        path.hashCode ^
        isHidden.hashCode ^
        pin.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'type': type.name,
      'collectionId': collectionId,
      'md5String': md5String,
      'createdDate': createdDate?.toSQL(),
      'originalDate': originalDate?.toSQL(),
      'updatedDate': updatedDate?.toSQL(),
      'ref': ref,
      'isDeleted': (isDeleted ?? false) ? 1 : 0,
      'path': path,
      'isHidden': (isHidden ?? false) ? 1 : 0,
      'pin': pin,
    };
  }

  factory CLMedia.fromMap(Map<String, dynamic> map) {
    return CLMedia(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] != null ? map['name'] as String : 'Name not found',
      type: CLMediaType.values.asNameMap()[map['type'] as String]!,
      collectionId:
          map['collectionId'] != null ? map['collectionId'] as int : null,
      md5String: map['md5String'] != null ? map['md5String'] as String : null,
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'] as String)
          : null,
      originalDate: map['originalDate'] != null
          ? DateTime.parse(map['originalDate'] as String)
          : null,
      updatedDate: map['updatedDate'] != null
          ? DateTime.parse(map['updatedDate'] as String)
          : null,
      ref: map['ref'] != null ? map['ref'] as String : null,
      isDeleted:
          map['isDeleted'] != null ? (map['isDeleted'] as int) != 0 : null,
      path: map['path'] as String,
      isHidden: map['isHidden'] != null ? (map['isHidden'] as int) != 0 : null,
      pin: map['pin'] != null ? map['pin'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CLMedia.fromJson(String source) =>
      CLMedia.fromMap(json.decode(source) as Map<String, dynamic>);
}
