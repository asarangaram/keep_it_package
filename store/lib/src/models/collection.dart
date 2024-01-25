import 'package:flutter/material.dart';

import 'tag.dart';

@immutable
class Collection {
  const Collection({
    required this.description,
    this.id,
  });

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'] as int?,
      description: map['description'] as String,
    );
  }
  final int? id;
  final String description;

  @override
  String toString() => 'Collection(id: $id, description: $description)';

  @override
  bool operator ==(covariant Collection other) {
    if (identical(this, other)) return true;

    return other.id == id && other.description == description;
  }

  @override
  int get hashCode => id.hashCode ^ description.hashCode;

  Collection copyWith({
    int? id,
    String? description,
  }) {
    return Collection(
      id: id ?? this.id,
      description: description ?? this.description,
    );
  }
}

class Collections {
  Collections(this.entries, {this.tag});
  final List<Collection> entries;
  final Tag? tag;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;
}
