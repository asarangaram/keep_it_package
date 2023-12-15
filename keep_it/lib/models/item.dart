class Item {
  int? id;
  String path;
  String? ref;
  int clusterId;
  Item({
    this.id,
    required this.path,
    this.ref,
    required this.clusterId,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int?,
      path: map['path'] as String,
      ref: map['ref'] as String?,
      clusterId: map['cluster_id'] as int,
    );
  }

  Item copyWith({
    int? id,
    String? path,
    String? ref,
    int? clusterId,
  }) {
    return Item(
      id: id ?? this.id,
      path: path ?? this.path,
      ref: ref ?? this.ref,
      clusterId: clusterId ?? this.clusterId,
    );
  }

  @override
  bool operator ==(covariant Item other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.path == path &&
        other.ref == ref &&
        other.clusterId == clusterId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ path.hashCode ^ ref.hashCode ^ clusterId.hashCode;
  }

  @override
  String toString() {
    return 'Item(id: $id, path: $path, ref: $ref, clusterId: $clusterId)';
  }
}
