// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

enum CLNoteTypes { text, audio }

@immutable
class CLNote {
  const CLNote({
    required this.createdDate,
    required this.type,
    required this.note,
    required this.id,
    this.updatedDate,
  });

  factory CLNote.fromMap(Map<String, dynamic> map) {
    if (CLNoteTypes.values.asNameMap()[map['type'] as String] == null) {
      throw Exception('Incorrect type');
    }
    final type = CLNoteTypes.values.asNameMap()[map['type'] as String]!;
    final createdDate =
        DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int);
    final updatedDate =
        DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int);
    final note = map['note'] as String;
    return switch (type) {
      CLNoteTypes.audio => CLAudioNote(
          id: map['id'] == null ? null : map['id']! as int,
          createdDate: createdDate,
          path: note,
          updatedDate: updatedDate,
        ),
      CLNoteTypes.text => CLTextNote(
          id: map['id'] == null ? null : map['id']! as int,
          createdDate: createdDate,
          note: note,
          updatedDate: updatedDate,
        )
    };
  }
  final int? id;
  final DateTime createdDate;
  final DateTime? updatedDate;
  final CLNoteTypes type;
  final String note;

  CLNote copyWith({
    int? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    CLNoteTypes? type,
    String? note,
  }) {
    return CLNote(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'CLNote(id: $id, createdDate: $createdDate, updatedDate: $updatedDate, type: $type, note: $note)';
  }

  @override
  bool operator ==(covariant CLNote other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate &&
        other.type == type &&
        other.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode ^
        type.hashCode ^
        note.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createdDate': createdDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate?.millisecondsSinceEpoch,
      'type': type.name,
      'message': note,
    };
  }

  /* String toJson() => json.encode(toMap());

  factory CLMessage.fromJson(String source) =>
      CLMessage.fromMap(json.decode(source) as Map<String, dynamic>); */
}

@immutable
class CLTextNote extends CLNote {
  const CLTextNote({
    required super.id,
    required super.createdDate,
    required super.note,
    super.updatedDate,
    super.type = CLNoteTypes.text,
  });
}

@immutable
class CLAudioNote extends CLNote {
  const CLAudioNote({
    required super.id,
    required super.createdDate,
    required String path,
    super.type = CLNoteTypes.audio,
    super.updatedDate,
  }) : super(note: path);

  String get path => note;
}
