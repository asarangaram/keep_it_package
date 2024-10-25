// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

import 'cl_media_base.dart';

@immutable
class Collection {
  const Collection({
    required this.label,
    required this.haveItOffline,
    required this.createdDate,
    required this.updatedDate,
    required this.isDeleted,
    required this.isEditted,
    this.id,
    this.description,
    this.serverUID,
  });

  factory Collection.strict({
    required String label,
    required bool haveItOffline,
    required bool isDeleted,
    required bool isEditted,
    required int? id,
    required String? description,
    required int? serverUID,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    final time = DateTime.now();
    return Collection(
      id: id,
      description: description,
      serverUID: serverUID,
      label: label,
      haveItOffline: haveItOffline,
      createdDate: createdDate ?? time,
      updatedDate: updatedDate ?? time,
      isDeleted: isDeleted,
      isEditted: isEditted,
    );
  }
  factory Collection.byLabel(
    String label, {
    DateTime? createdDate,
    DateTime? updatedDate,
    int? serverUID,
  }) {
    return Collection.strict(
      id: null,
      description: null,
      serverUID: serverUID,
      label: label,
      haveItOffline: false,
      createdDate: createdDate,
      updatedDate: updatedDate,
      isDeleted: false,
      isEditted: false,
    );
  }
  final String label;
  final String? description;
  final DateTime createdDate;
  final DateTime updatedDate;
  final int? id;
  final bool haveItOffline;
  final int? serverUID;
  final bool isDeleted;
  final bool isEditted;

  factory Collection.fromMap(Map<String, dynamic> map) {
    final timeNow = DateTime.now();
    return Collection(
      id: map['id'] != null ? map['id'] as int : null,
      label: map['label'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      createdDate: map['createdDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int)
          : timeNow,
      updatedDate: map['updatedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int)
          : timeNow,
      haveItOffline: (map['haveItOffline'] as int?) != 1,
      serverUID: map['serverUID'] != null ? map['serverUID'] as int : null,
      isDeleted: ((map['isDeleted'] as int?) ?? false) != 0,
      isEditted: ((map['isEditted'] as int?) ?? false) != 0,
    );
  }

  factory Collection.fromJson(String source) =>
      Collection.fromMap(json.decode(source) as Map<String, dynamic>);

  Collection copyWith({
    String? label,
    ValueGetter<String?>? description,
    DateTime? createdDate,
    DateTime? updatedDate,
    ValueGetter<int?>? id,
    bool? haveItOffline,
    ValueGetter<int?>? serverUID,
    bool? isDeleted,
    bool? isEditted,
  }) {
    return Collection(
      label: label ?? this.label,
      description: description != null ? description.call() : this.description,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      id: id != null ? id.call() : this.id,
      haveItOffline: haveItOffline ?? this.haveItOffline,
      serverUID: serverUID != null ? serverUID.call() : this.serverUID,
      isDeleted: isDeleted ?? this.isDeleted,
      isEditted: isEditted ?? this.isEditted,
    );
  }

  @override
  String toString() {
    return 'Collection(label: $label, description: $description, createdDate: $createdDate, updatedDate: $updatedDate, id: $id, haveItOffline: $haveItOffline, serverUID: $serverUID, isDeleted: $isDeleted, isEditted: $isEditted)';
  }

  @override
  bool operator ==(covariant Collection other) {
    if (identical(this, other)) return true;

    return other.label == label &&
        other.description == description &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate &&
        other.id == id &&
        other.haveItOffline == haveItOffline &&
        other.serverUID == serverUID &&
        other.isDeleted == isDeleted &&
        other.isEditted == isEditted;
  }

  @override
  int get hashCode {
    return label.hashCode ^
        description.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode ^
        id.hashCode ^
        haveItOffline.hashCode ^
        serverUID.hashCode ^
        isDeleted.hashCode ^
        isEditted.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'description': description,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate.millisecondsSinceEpoch,
      'haveItOffline': haveItOffline ? 1 : 0,
      'serverUID': serverUID,
    };
  }

  String toJson() => json.encode(toMap());
}
