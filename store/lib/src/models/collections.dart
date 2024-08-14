// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'collection.dart';

@immutable
class Collections {
  const Collections(
    this.entries,
  );
  final List<Collection> entries;

  Collections copyWith({
    List<Collection>? entries,
  }) {
    return Collections(
      entries ?? this.entries,
    );
  }

  @override
  String toString() => 'Collections(entries: $entries)';

  @override
  bool operator ==(covariant Collections other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.entries, entries);
  }

  @override
  int get hashCode => entries.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'entries': entries.map((x) => x.toMap()).toList(),
    };
  }

  factory Collections.fromMap(Map<String, dynamic> map) {
    return Collections(
      List<Collection>.from(
        (map['entries'] as List<int>).map<Collection>(
          (x) => Collection.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
  factory Collections.fromList(List<dynamic> map) {
    return Collections(
      List<Collection>.from(
        map.map<Collection>(
          (x) => Collection.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Collections.fromJson(String source) =>
      Collections.fromList(json.decode(source) as List<dynamic>);
}
