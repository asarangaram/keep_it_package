// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class CollectionBase {
  const CollectionBase({
    required this.label,
    this.description,
    this.createdDate,
    this.updatedDate,
  });
  final String label;
  final String? description;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  @override
  bool operator ==(covariant CollectionBase other) {
    if (identical(this, other)) return true;

    return other.label == label &&
        other.description == description &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate;
  }

  @override
  int get hashCode {
    return label.hashCode ^
        description.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode;
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'CollectionBase(label: $label, description: $description, createdDate: $createdDate, updatedDate: $updatedDate)';
  }
}

@immutable
class Collection extends CollectionBase {
  const Collection({
    required super.label,
    this.id,
    super.description,
    super.createdDate,
    super.updatedDate,
  });

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'] != null ? map['id'] as int : null,
      label: map['label'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      createdDate: map['createdDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int)
          : null,
      updatedDate: map['updatedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int)
          : null,
    );
  }

  factory Collection.fromJson(String source) =>
      Collection.fromMap(json.decode(source) as Map<String, dynamic>);

  final int? id;

  Collection copyWith({
    int? id,
    String? label,
    String? description,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return Collection(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'Collection(id: $id, label: $label, description: $description, createdDate: $createdDate, updatedDate: $updatedDate)';
  }

  @override
  bool operator ==(covariant Collection other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.label == label &&
        other.description == description &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        label.hashCode ^
        description.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'description': description,
      'createdDate': createdDate?.millisecondsSinceEpoch,
      'updatedDate': updatedDate?.millisecondsSinceEpoch,
    };
  }

  String toJson() => json.encode(toMap());

  Collection removeID() {
    return Collection(
      label: label,
      description: description,
      createdDate: createdDate,
      updatedDate: updatedDate,
    );
  }
}
