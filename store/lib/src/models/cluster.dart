import 'package:flutter/material.dart';

import 'collection.dart';

@immutable
class Cluster {
  const Cluster({
    required this.description,
    this.id,
  });

  factory Cluster.fromMap(Map<String, dynamic> map) {
    return Cluster(
      id: map['id'] as int?,
      description: map['description'] as String,
    );
  }
  final int? id;
  final String description;

  @override
  String toString() => 'Cluster(id: $id, description: $description)';

  @override
  bool operator ==(covariant Cluster other) {
    if (identical(this, other)) return true;

    return other.id == id && other.description == description;
  }

  @override
  int get hashCode => id.hashCode ^ description.hashCode;

  Cluster copyWith({
    int? id,
    String? description,
  }) {
    return Cluster(
      id: id ?? this.id,
      description: description ?? this.description,
    );
  }
}

class Clusters {
  Clusters(this.entries, {this.collection});
  final List<Cluster> entries;
  final Tag? collection;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;
}
