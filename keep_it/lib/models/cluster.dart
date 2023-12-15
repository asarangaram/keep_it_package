class Cluster {
  int? id;
  String description;
  Cluster({
    this.id,
    required this.description,
  });

  factory Cluster.fromMap(Map<String, dynamic> map) {
    return Cluster(
      id: map['id'] as int?,
      description: map['description'] as String,
    );
  }

  @override
  String toString() => 'Cluster(id: $id, description: $description)';

  @override
  bool operator ==(covariant Cluster other) {
    if (identical(this, other)) return true;

    return other.id == id && other.description == description;
  }

  @override
  int get hashCode => id.hashCode ^ description.hashCode;

  Cluster copyWith({
    int? id,
    String? description,
  }) {
    return Cluster(
      id: id ?? this.id,
      description: description ?? this.description,
    );
  }
}
