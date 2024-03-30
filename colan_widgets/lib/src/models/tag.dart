// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'm1_app_settings.dart';

@immutable
class Tag {
  const Tag({
    required this.label,
    this.id,
    this.description,
    this.createdDate,
    this.updatedDate,
  });
  @override
  String toString() {
    return 'Tag(id: $id, label: $label, description: $description,'
        ' createdDate: $createdDate, updatedDate: $updatedDate)';
  }

  factory Tag.fromMap(
    Map<String, dynamic> map, {
    // ignore: avoid_unused_constructor_parameters
    required AppSettings appSettings,
  }) {
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
  /* factory Tag.fromJson(String source) =>
      Tag.fromMap(json.decode(source) as Map<String, dynamic>); */

  final int? id;

  final String label;

  final String? description;

  final DateTime? createdDate;

  final DateTime? updatedDate;

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'description': description,
    };
  }

  String toJson() => json.encode(toMap());
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
}
