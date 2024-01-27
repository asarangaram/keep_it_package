// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter/material.dart';

import 'collection_base.dart';
import 'tag.dart';

@immutable
class Collection extends CollectionBase {
  const Collection({
    required super.label,
    super.id,
    super.description,
    super.createdDate,
    super.updatedDate,
  });
  Collection.fromBase(CollectionBase base)
      : super(
          label: base.label,
          id: base.id,
          description: base.description,
          createdDate: base.createdDate,
          updatedDate: base.updatedDate,
        );

  factory Collection.fromMap(Map<String, dynamic> map) =>
      Collection.fromBase(CollectionBase.fromMap(map));

  factory Collection.fromJson(String source) =>
      Collection.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Collections {
  final List<Collection> entries;
  final Tag? tag;
  final int? lastupdatedID;
  Collections(this.entries, {this.lastupdatedID, this.tag});

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  Collections copyWith({
    List<Collection>? entries,
    int? lastupdatedID,
    Tag? tag,
  }) {
    return Collections(
      entries ?? this.entries,
      lastupdatedID: lastupdatedID ?? this.lastupdatedID,
      tag: tag ?? this.tag,
    );
  }

  Collections clearLastUpdated() {
    return Collections(entries);
  }

  /* Collections get getSuggestions {
    return Collections(
      suggestedCollections.where((element) {
        return !entries.map((e) => e.label).contains(element.label);
      }).toList(),
    );
  } */
}
