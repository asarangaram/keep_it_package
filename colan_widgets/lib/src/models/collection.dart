// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter/material.dart';

@immutable
class Collection {
  const Collection({
    required this.label,
    required this.createdDate,
    required this.updatedDate,
    this.id,
    this.description,
  });

  factory Collection.fromMap(
    Map<String, dynamic> map,
  ) {
    return Collection(
      id: map['id'] != null ? map['id'] as int : null,
      label: map['label'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      createdDate: DateTime.parse(map['createdDate'] as String).toLocal(),
      updatedDate: DateTime.parse(map['updatedDate'] as String).toLocal(),
    );
  }
  /* factory Collection.fromJson(String source) =>
      Collection.fromMap(json.decode(source) as Map<String, dynamic>); */

  final int? id;
  final String label;
  final String? description;
  final DateTime createdDate;
  final DateTime updatedDate;

  Collection copyWith({
    int? id,
    String? label,
    String? description,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return Collection(
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

  @override
  String toString() {
    return 'Collection(id: $id, label: $label, description: $description, '
        'createdDate: $createdDate, updatedDate: $updatedDate)';
  }

  static String? validateName({
    required String? newLabel,
    required String? existingLabel,
    required List<Collection> collections,
  }) {
    final newLabel0 = newLabel?.trim();

    if (newLabel0?.isEmpty ?? true) {
      return "Name can't be empty";
    }

    if (existingLabel?.trim() == newLabel0) {
      // Nothing changed.
      return null;
    }
    if (collections.map((e) => e.label.trim()).contains(newLabel0)) {
      return '$newLabel0 already exists';
    }
    return null;
  }

  static String? validateDescription({
    required String? description,
    required String? existingDescription,
    required List<Collection> collections,
  }) {
    // No validation speccified as of now.
    return null;
  }
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

  Collection? getByID(int id) => entries.where((e) => e.id == id).firstOrNull;
}
