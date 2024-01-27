import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

@immutable
class Grouped<GroupType, RefType> {
  const Grouped({
    required this.entries,
    this.referrer,
    this.lastupdatedID,
  });
  final List<GroupType> entries;
  final RefType? referrer;
  final int? lastupdatedID;

  Grouped<GroupType, RefType> clearLastUpdated() {
    return Grouped(
      entries: entries,
      referrer: referrer,
    );
  }

  Grouped<GroupType, RefType> copyWith({
    List<GroupType>? entries,
    RefType? ref,
    int? lastupdatedID,
  }) {
    return Grouped<GroupType, RefType>(
      entries: entries ?? this.entries,
      referrer: ref ?? this.referrer,
      lastupdatedID: lastupdatedID ?? this.lastupdatedID,
    );
  }

  @override
  String toString() =>
      'Grouped(entries: $entries, ref: $referrer, lastupdatedID: $lastupdatedID)';

  @override
  bool operator ==(covariant Grouped<GroupType, RefType> other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.entries, entries) &&
        other.referrer == referrer &&
        other.lastupdatedID == lastupdatedID;
  }

  @override
  int get hashCode =>
      entries.hashCode ^ referrer.hashCode ^ lastupdatedID.hashCode;
}
