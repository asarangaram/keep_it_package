// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter/material.dart';

import '../local_data/suggested_tags.dart';
import 'collection_base.dart';

@immutable
class Tag extends CollectionBase {
  const Tag({
    required super.label,
    super.id,
    super.description,
    super.createdDate,
    super.updatedDate,
  });
  Tag.fromBase(CollectionBase base)
      : super(
          label: base.label,
          id: base.id,
          description: base.description,
          createdDate: base.createdDate,
          updatedDate: base.updatedDate,
        );

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
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
  factory Tag.fromJson(String source) =>
      Tag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  Tag copyWith({
    int? id,
    String? label,
    String? description,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return Tag(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }
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
