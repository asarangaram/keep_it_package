// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
class DBQueries {
  const DBQueries._({
    this.tagId,
  });

  factory DBQueries.byTagId(int id) {
    return DBQueries._(tagId: id);
  }
  final int? tagId;

  DBQueries copyWith({
    int? tagId,
  }) {
    return DBQueries._(
      tagId: tagId ?? this.tagId,
    );
  }

  @override
  String toString() => 'DBQueries(tagId: $tagId)';

  @override
  bool operator ==(covariant DBQueries other) {
    if (identical(this, other)) return true;

    return other.tagId == tagId;
  }

  @override
  int get hashCode => tagId.hashCode;
}
