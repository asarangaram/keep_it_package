import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'collection.dart';

@immutable
class Item {
  const Item({required this.path, required this.type, this.ref});

  factory Item.fromText(String text) {
    final type = text.isURL() ? CLMediaType.url : CLMediaType.text;
    return Item(path: text, type: type);
  }
  final String path;
  final CLMediaType type;
  final String? ref;

  Item copyWith({String? path, CLMediaType? type, String? ref}) {
    return Item(
      path: path ?? this.path,
      type: type ?? this.type,
      ref: ref ?? this.ref,
    );
  }
}
/* 
@immutable
class ItemInDB extends CLMedia {
  ItemInDB({
    required super.path,
    required super.type,
    super.collectionId,
    super.id,
    super.ref,
  });

  factory ItemInDB.fromMap(Map<String, dynamic> map) {
    if (CLMediaType.values.asNameMap()[map['type'] as String] == null) {
      throw Exception('Incorrect type');
    }

    return ItemInDB(
      id: map['id'] != null ? map['id'] as int : null,
      path: map['path'] as String,
      ref: map['ref'] != null ? map['ref'] as String : null,
      collectionId: map['collection_id'] as int,
      type: CLMediaType.values.asNameMap()[map['type'] as String]!,
    );
  }

  @override
  ItemInDB copyWith({
    int? id,
    String? path,
    String? ref,
    int? collectionId,
    CLMediaType? type,
  }) {
    return ItemInDB(
      id: id ?? this.id,
      path: path ?? this.path,
      ref: ref ?? this.ref,
      collectionId: collectionId ?? this.collectionId,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'path': path,
      'ref': ref,
      'collectionId': collectionId,
      'type': type,
    };
  }

  /* String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) =>
      Item.fromMap(json.decode(source) as Map<String, dynamic>);
 */
  @override
  String toString() {
    return 'Item(id: $id, path: $path, '
        'ref: $ref, collectionId: $collectionId, type: $type)';
  }

  @override
  bool operator ==(covariant ItemInDB other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.path == path &&
        other.ref == ref &&
        other.collectionId == collectionId &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        path.hashCode ^
        ref.hashCode ^
        collectionId.hashCode ^
        type.hashCode;
  }
} */

class Items {
  Items(this.collection, this.entries);
  final List<CLMedia> entries;
  final Collection collection;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;
}
