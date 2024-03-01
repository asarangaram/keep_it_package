import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class TagCollection {
  const TagCollection({
    required this.tagID,
    required this.collectionId,
  });

  factory TagCollection.fromMap(Map<String, dynamic> map) {
    return TagCollection(
      tagID: map['tagId'] as int,
      collectionId: map['collectionId'] as int,
    );
  }

  factory TagCollection.fromJson(String source) =>
      TagCollection.fromMap(json.decode(source) as Map<String, dynamic>);
  final int tagID;
  final int collectionId;

  TagCollection copyWith({
    int? tagID,
    int? collectionId,
  }) {
    return TagCollection(
      tagID: tagID ?? this.tagID,
      collectionId: collectionId ?? this.collectionId,
    );
  }

  @override
  bool operator ==(covariant TagCollection other) {
    if (identical(this, other)) return true;

    return other.tagID == tagID && other.collectionId == collectionId;
  }

  @override
  int get hashCode => tagID.hashCode ^ collectionId.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tagId': tagID,
      'collectionId': collectionId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'TagCollection(tagID: $tagID, collectionId: $collectionId)';
}
