// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
class DBQueries {
  const DBQueries({
    this.limit,
    this.collectionID,
  });

  const DBQueries.byCollectionID(int id, {this.limit}) : collectionID = id;
  final int? collectionID;
  final int? limit;

  DBQueries copyWith({
    int? collectionID,
    int? limit,
  }) {
    return DBQueries(
      collectionID: collectionID ?? this.collectionID,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(covariant DBQueries other) {
    if (identical(this, other)) return true;

    return other.collectionID == collectionID && other.limit == limit;
  }

  @override
  int get hashCode => collectionID.hashCode ^ limit.hashCode;

  @override
  String toString() =>
      'DBQueries(collectionID: $collectionID, maxCount: $limit)';
}
