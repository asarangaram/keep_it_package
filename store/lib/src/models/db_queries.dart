// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
class DBQueries {
  const DBQueries._({
    this.collectionID,
  });

  factory DBQueries.byTagID(int id) {
    return DBQueries._(collectionID: id);
  }
  final int? collectionID;

  DBQueries copyWith({
    int? collectionID,
  }) {
    return DBQueries._(
      collectionID: collectionID ?? this.collectionID,
    );
  }

  @override
  String toString() => 'DBQueries(collectionID: $collectionID)';

  @override
  bool operator ==(covariant DBQueries other) {
    if (identical(this, other)) return true;

    return other.collectionID == collectionID;
  }

  @override
  int get hashCode => collectionID.hashCode;
}
