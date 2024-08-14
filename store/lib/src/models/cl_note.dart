// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

import 'cl_note_type.dart';

@immutable
class CLTextNote extends CLNote {
  const CLTextNote({
    required super.id,
    required super.createdDate,
    required super.path,
    super.updatedDate,
    super.type = CLNoteTypes.text,
  });
}

@immutable
class CLAudioNote extends CLNote {
  const CLAudioNote({
    required super.id,
    required super.createdDate,
    required super.path,
    super.type = CLNoteTypes.audio,
    super.updatedDate,
  });
}

@immutable
class CLNote {
  const CLNote({
    required this.id,
    required this.createdDate,
    required this.type,
    required this.path,
    this.updatedDate,
  });

  final int? id;
  final DateTime createdDate;
  final DateTime? updatedDate;
  final CLNoteTypes type;
  final String path;

  CLNote copyWith({
    int? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    CLNoteTypes? type,
    String? path,
  }) {
    return CLNote(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      type: type ?? this.type,
      path: path ?? this.path,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'CLNote(id: $id, createdDate: $createdDate, updatedDate: $updatedDate, type: $type, path: $path)';
  }

  @override
  bool operator ==(covariant CLNote other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate &&
        other.type == type &&
        other.path == path;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode ^
        type.hashCode ^
        path.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate?.millisecondsSinceEpoch,
      'type': type.name,
      'path': path,
    };
  }

  factory CLNote.fromMap(Map<String, dynamic> map) {
    final type = CLNoteTypes.values.asNameMap()[map['type'] as String]!;

    return switch (type) {
      CLNoteTypes.text => CLTextNote(
          id: map['id'] != null ? map['id'] as int : null,
          createdDate:
              DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
          updatedDate: map['updatedDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int)
              : null,
          path: map['path'] as String,
        ),
      CLNoteTypes.audio => CLAudioNote(
          id: map['id'] != null ? map['id'] as int : null,
          createdDate:
              DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
          updatedDate: map['updatedDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int)
              : null,
          path: map['path'] as String,
        ),
    };
  }

  String toJson() => json.encode(toMap());

  factory CLNote.fromJson(String source) =>
      CLNote.fromMap(json.decode(source) as Map<String, dynamic>);
}
