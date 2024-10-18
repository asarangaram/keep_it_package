// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:store/src/models/cl_media.dart';

@immutable
class CLMedias {
  const CLMedias(
    this.entries,
  );
  final List<CLMedia> entries;

  CLMedias copyWith({
    List<CLMedia>? entries,
  }) {
    return CLMedias(
      entries ?? this.entries,
    );
  }

  @override
  String toString() => 'CLMedias(entries: $entries)';

  @override
  bool operator ==(covariant CLMedias other) {
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

  factory CLMedias.fromMap(Map<String, dynamic> map) {
    return CLMedias(
      List<CLMedia>.from(
        (map['entries'] as List<int>).map<CLMedia>(
          (x) => CLMedia.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
  factory CLMedias.fromList(List<dynamic> map) {
    return CLMedias(
      List<CLMedia>.from(
        map.map<CLMedia>(
          (x) => CLMedia.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());
  String toJsonList() => json.encode(toList());

  factory CLMedias.fromJson(String source) =>
      CLMedias.fromList(json.decode(source) as List<dynamic>);
}
