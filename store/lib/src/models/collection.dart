import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:store/store.dart';

import 'cl_media_base.dart';

@immutable
class Collection implements CLEntity {
  factory Collection.fromMap(Map<String, dynamic> map) {
    final timeNow = DateTime.now();
    return Collection._(
      id: map['id'] != null ? map['id'] as int : null,
      label: map['label'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      addedDate: map['addedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['addedDate'] as int)
          : timeNow,
      updatedDate: map['updatedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int)
          : timeNow,
      isDeleted: ((map['isDeleted'] as int?) ?? false) != 0,
    );
  }

  factory Collection.fromJson(String source) =>
      Collection.fromMap(json.decode(source) as Map<String, dynamic>);
  const Collection._({
    required this.label,
    required this.addedDate,
    required this.updatedDate,
    required this.isDeleted,
    this.id,
    this.description,
  });

  factory Collection.strict({
    required String label,
    required bool isDeleted,
    required int? id,
    required String? description,
    DateTime? addedDate,
    DateTime? updatedDate,
  }) {
    final time = DateTime.now();
    return Collection._(
      id: id,
      description: description,
      label: label,
      addedDate: addedDate ?? time,
      updatedDate: updatedDate ?? time,
      isDeleted: isDeleted,
    );
  }
  factory Collection.byLabel(
    String label, {
    DateTime? addedDate,
    DateTime? updatedDate,
    String? description,
  }) {
    return Collection.strict(
      id: null,
      description: description,
      label: label,
      addedDate: addedDate,
      updatedDate: updatedDate,
      isDeleted: false,
    );
  }
  final String label;
  final String? description;
  final DateTime addedDate;
  final DateTime updatedDate;
  final int? id;

  final bool isDeleted;

  Collection copyWith({
    String? label,
    ValueGetter<String?>? description,
    DateTime? addedDate,
    DateTime? updatedDate,
    ValueGetter<int?>? id,
    bool? isDeleted,
    bool? isEdited,
  }) {
    return Collection._(
      label: label ?? this.label,
      description: description != null ? description.call() : this.description,
      addedDate: addedDate ?? this.addedDate,
      updatedDate: updatedDate ?? this.updatedDate,
      id: id != null ? id.call() : this.id,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() {
    return 'Collection(label: $label, description: $description, addedDate: $addedDate, updatedDate: $updatedDate, id: $id, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(covariant Collection other) {
    if (identical(this, other)) return true;

    return other.label == label &&
        other.description == description &&
        other.addedDate == addedDate &&
        other.updatedDate == updatedDate &&
        other.id == id &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode {
    return label.hashCode ^
        description.hashCode ^
        addedDate.hashCode ^
        updatedDate.hashCode ^
        id.hashCode ^
        isDeleted.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'description': description,
      'addedDate': addedDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  Map<String, dynamic> toMapForDisplay() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'description': description,
      'addedDate': addedDate,
      'updatedDate': updatedDate,
      'isDeleted': isDeleted,
    };
  }

  Map<String, String> toUploadMap() {
    final map = toMap();
    final serverFields = <String>[
      'label',
      'description',
      'addedDate',
      'updatedDate',
      'isDeleted',
    ];
    map.removeWhere(
      (key, value) => !serverFields.contains(key) || value == null,
    );
    return map.map((key, value) => MapEntry(key, value.toString()));
  }

  String toJson() => json.encode(toMap());

  @override
  int? get entityId => id;

  @override
  DateTime get sortDate => addedDate;
}
