import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'collection.dart';

List<T> updateEntry<T>(
  List<T> list,
  bool Function(T) test,
  T Function(T) replaceBy,
) {
  final index = list.indexWhere(test);
  if (index == -1) {
    return list;
  }

  final updatedList = List<T>.from(list);

  updatedList[index] = replaceBy(updatedList[index]);

  return updatedList;
}

@immutable
class Collections {
  const Collections(
    this.entries,
  );

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

  factory Collections.fromJson(String source) =>
      Collections.fromList(json.decode(source) as List<dynamic>);
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

  List<dynamic> toList() {
    return entries.map((x) => x.toMap()).toList();
  }

  String toJson() => json.encode(toMap());
  String toJsonList() => json.encode(toList());
}
