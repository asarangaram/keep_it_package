// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
class DBQueries {
  const DBQueries._({
    this.tagID,
  });

  factory DBQueries.byTagID(int id) {
    return DBQueries._(tagID: id);
  }
  final int? tagID;

  DBQueries copyWith({
    int? tagID,
  }) {
    return DBQueries._(
      tagID: tagID ?? this.tagID,
    );
  }

  @override
  String toString() => 'DBQueries(tagID: $tagID)';

  @override
  bool operator ==(covariant DBQueries other) {
    if (identical(this, other)) return true;

    return other.tagID == tagID;
  }

  @override
  int get hashCode => tagID.hashCode;
}
