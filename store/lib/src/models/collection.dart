// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:store/src/extensions/ext_datetime.dart';

@immutable
class Collection {
  const Collection({
    required this.label,
    this.id,
    this.description,
    this.createdDate,
    this.updatedDate,
    this.serverUID,
    this.locallyModified = true,
  });

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'] != null ? map['id'] as int : null,
      label: map['label'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'] as String).toLocal()
          : null,
      updatedDate: map['updatedDate'] != null
          ? DateTime.parse(map['updatedDate'] as String).toLocal()
          : null,
      serverUID: map['serverUID'] != null ? map['serverUID'] as int : null,
      locallyModified: (map['locallyModified'] as int? ?? 1) == 1,
    );
  }

  factory Collection.fromJson(String source) =>
      Collection.fromMap(json.decode(source) as Map<String, dynamic>);

  final int? id;
  final String label;
  final String? description;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final int? serverUID;
  final bool locallyModified;

  Collection copyWith({
    int? id,
    String? label,
    String? description,
    DateTime? createdDate,
    DateTime? updatedDate,
    int? serverUID,
    bool? locallyModified,
  }) {
    return Collection(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      serverUID: serverUID ?? this.serverUID,
      locallyModified: locallyModified ?? this.locallyModified,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'Collection(id: $id, label: $label, description: $description, createdDate: $createdDate, updatedDate: $updatedDate, serverUID: $serverUID, locallyModified: $locallyModified)';
  }

  @override
  bool operator ==(covariant Collection other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.label == label &&
        other.description == description &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate &&
        other.serverUID == serverUID &&
        other.locallyModified == locallyModified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        label.hashCode ^
        description.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode ^
        serverUID.hashCode ^
        locallyModified.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'description': description,
      'createdDate': createdDate?.toSQL(),
      'updatedDate': updatedDate?.toSQL(),
      'serverUID': serverUID,
      'locallyModified': locallyModified,
    };
  }

  String toJson() => json.encode(toMap());

  Collection removeID() {
    return Collection(
      label: label,
      description: description,
      createdDate: createdDate,
      updatedDate: updatedDate,
      serverUID: serverUID,
      locallyModified: locallyModified,
    );
  }
}
