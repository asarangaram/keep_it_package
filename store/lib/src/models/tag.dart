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

  factory Tag.fromMap(Map<String, dynamic> map) =>
      Tag.fromBase(CollectionBase.fromMap(map));

  factory Tag.fromJson(String source) =>
      Tag.fromMap(json.decode(source) as Map<String, dynamic>);
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
