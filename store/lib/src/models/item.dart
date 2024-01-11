import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'cluster.dart';

extension ColonExtensionOnString on String {
  bool isURL() {
    try {
      final uri = Uri.parse(this);
      // Check if the scheme is non-empty to ensure it's a valid URL
      return uri.scheme.isNotEmpty;
    } catch (e) {
      return false; // Parsing failed, not a valid URL
    }
  }
}

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

@immutable
class ItemInDB extends Item {
  const ItemInDB({
    required super.path,
    required this.clusterId,
    required super.type,
    this.id,
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
      clusterId: map['cluster_id'] as int,
      type: CLMediaType.values.asNameMap()[map['type'] as String]!,
    );
    //map['type'] as String
  }
  final int? id;

  final int clusterId;

  @override
  ItemInDB copyWith({
    int? id,
    String? path,
    String? ref,
    int? clusterId,
    CLMediaType? type,
  }) {
    return ItemInDB(
      id: id ?? this.id,
      path: path ?? this.path,
      ref: ref ?? this.ref,
      clusterId: clusterId ?? this.clusterId,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'path': path,
      'ref': ref,
      'clusterId': clusterId,
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
        'ref: $ref, clusterId: $clusterId, type: $type)';
  }

  @override
  bool operator ==(covariant ItemInDB other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.path == path &&
        other.ref == ref &&
        other.clusterId == clusterId &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        path.hashCode ^
        ref.hashCode ^
        clusterId.hashCode ^
        type.hashCode;
  }
}

class Items {
  Items(this.cluster, this.entries);
  final List<ItemInDB> entries;
  final Cluster cluster;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;
}
