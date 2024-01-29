import 'dart:convert';

import 'package:flutter/material.dart';

@immutable
abstract class CollectionBase {
  const CollectionBase({
    required this.label,
    this.id,
    this.description,
    this.createdDate,
    this.updatedDate,
  });

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
  });

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
    //Don't use Dates
    return other.id == id &&
        other.label == label &&
        other.description == description;
  }

  @override
  int get hashCode {
    //Don't use Dates
    return id.hashCode ^ label.hashCode ^ description.hashCode;
  }
}
