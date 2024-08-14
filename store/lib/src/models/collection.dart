import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:store/src/extensions/ext_datetime.dart';

@immutable
class Collection {
  const Collection({
    required this.label,
    this.id,
    this.description,
    this.createdDate,
    this.updatedDate,
  });

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'] != null ? map['id'] as int : null,
      label: map['label'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'] as String)
          : null,
      updatedDate: map['updatedDate'] != null
          ? DateTime.parse(map['updatedDate'] as String)
          : null,
    );
  }

  factory Collection.fromJson(String source) =>
      Collection.fromMap(json.decode(source) as Map<String, dynamic>);

  final int? id;
  final String label;
  final String? description;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  Collection copyWith({
    int? id,
    String? label,
    String? description,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return Collection(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'Collection(id: $id, label: $label, description: $description, createdDate: $createdDate, updatedDate: $updatedDate)';
  }

  @override
  bool operator ==(covariant Collection other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.label == label &&
        other.description == description &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        label.hashCode ^
        description.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'description': description,
      'createdDate': createdDate?.toSQL(),
      'updatedDate': updatedDate?.toSQL(),
    };
  }

  String toJson() => json.encode(toMap());
}
