// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import '../extensions/ext_file.dart';
import 'cl_media_type.dart';

@immutable
class CLMediaBase {
  const CLMediaBase({
    required this.name,
    required this.type,
    this.ref,
    this.originalDate,
    this.createdDate,
    this.updatedDate,
    this.md5String,
    this.isDeleted,
    this.isHidden,
    this.pin,
    this.collectionId,
    this.isAux = false,
  });

  factory CLMediaBase.fromMap(Map<String, dynamic> map) {
    return CLMediaBase(
      name: map['name'] as String,
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
      isDeleted: (map['isDeleted'] as int) != 0,
      isHidden: (map['isHidden'] as int) != 0,
      pin: map['pin'] != null ? map['pin'] as String : null,
      collectionId:
          map['collectionId'] != null ? map['collectionId'] as int : null,
    );
  }

  factory CLMediaBase.fromJson(String source) =>
      CLMediaBase.fromMap(json.decode(source) as Map<String, dynamic>);
  final String name;
  final CLMediaType type;
  final String? ref;
  final DateTime? originalDate;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? md5String;
  final bool? isDeleted;
  final bool? isHidden;
  final String? pin;
  final int? collectionId;
  final bool isAux;

  Future<void> deleteFile() async {
    await File(name).deleteIfExists();
  }

  CLMediaBase copyWith({
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
    bool? isAux,
  }) {
    return CLMediaBase(
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
      isAux: isAux ?? this.isAux,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'CLMediaBase(name: $name, type: $type, ref: $ref, originalDate: $originalDate, createdDate: $createdDate, updatedDate: $updatedDate, md5String: $md5String, isDeleted: $isDeleted, isHidden: $isHidden, pin: $pin, collectionId: $collectionId, isAux: $isAux)';
  }

  @override
  bool operator ==(covariant CLMediaBase other) {
    if (identical(this, other)) return true;

    return other.name == name &&
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
        other.isAux == isAux;
  }

  @override
  int get hashCode {
    return name.hashCode ^
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
        isAux.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'type': type.name,
      'ref': ref,
      'originalDate': originalDate?.millisecondsSinceEpoch,
      'createdDate': createdDate?.millisecondsSinceEpoch,
      'updatedDate': updatedDate?.millisecondsSinceEpoch,
      'md5String': md5String,
    };
  }

  String toJson() => json.encode(toMap());
}
