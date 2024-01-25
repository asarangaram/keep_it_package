// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

import '../local_data/suggested_collections.dart';

@immutable
class Tag {
  final int? id;
  final String label;
  final String? description;
  const Tag({
    required this.label,
    this.id,
    this.description,
  });

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] != null ? map['id'] as int : null,
      label: map['label'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
    );
  }

  Tag copyWith({
    int? id,
    String? label,
    String? description,
  }) {
    return Tag(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => 'Tag(id: $id, label: $label, description: $description)';

  @override
  bool operator ==(covariant Tag other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.label == label &&
        other.description == description;
  }

  @override
  int get hashCode => id.hashCode ^ label.hashCode ^ description.hashCode;
}

class Tags {
  final List<Tag> entries;
  final int? lastupdatedID;
  Tags(this.entries, {this.lastupdatedID});

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  Tags copyWith({
    List<Tag>? entries,
    int? lastupdatedID,
  }) {
    return Tags(
      entries ?? this.entries,
      lastupdatedID: lastupdatedID ?? this.lastupdatedID,
    );
  }

  Tags clearLastUpdated() {
    return Tags(entries);
  }

  Tags get getSuggestions {
    return Tags(
      suggestedTags.where((element) {
        return !entries.map((e) => e.label).contains(element.label);
      }).toList(),
    );
  }
}
