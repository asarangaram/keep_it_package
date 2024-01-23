// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

@immutable
class Collection {
  final int? id;
  final String label;
  final String? description;
  const Collection({
    required this.label,
    this.id,
    this.description,
  });

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'] != null ? map['id'] as int : null,
      label: map['label'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
    );
  }

  Collection copyWith({
    int? id,
    String? label,
    String? description,
  }) {
    return Collection(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
    );
  }

  @override
  String toString() =>
      'Collection(id: $id, label: $label, description: $description)';

  @override
  bool operator ==(covariant Collection other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.label == label &&
        other.description == description;
  }

  @override
  int get hashCode => id.hashCode ^ label.hashCode ^ description.hashCode;
}

class Collections {
  final List<Collection> entries;
  final int? lastupdatedID;
  Collections(this.entries, {this.lastupdatedID});

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  Collections copyWith({
    List<Collection>? entries,
    int? lastupdatedID,
  }) {
    return Collections(
      entries ?? this.entries,
      lastupdatedID: lastupdatedID ?? this.lastupdatedID,
    );
  }

  Collections clearLastUpdated() {
    return Collections(entries);
  }
}
