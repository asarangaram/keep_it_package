import 'dart:convert';

import 'package:flutter/material.dart';

@immutable
class CollectionBase {
  const CollectionBase({
    required this.label,
    this.id,
    this.description,
    this.createdDate,
    this.updatedDate,
  });

  factory CollectionBase.fromMap(Map<String, dynamic> map) {
    return CollectionBase(
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
    );
  }

  factory CollectionBase.fromJson(String source) =>
      CollectionBase.fromMap(json.decode(source) as Map<String, dynamic>);
  final int? id;
  final String label;
  final String? description;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  CollectionBase copyWith({
    int? id,
    String? label,
    String? description,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return CollectionBase(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
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

  @override
  String toString() {
    return 'CollectionBase(id: $id, label: $label, description: $description,'
        ' createdDate: $createdDate, updatedDate: $updatedDate)';
  }

  @override
  bool operator ==(covariant CollectionBase other) {
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
}
