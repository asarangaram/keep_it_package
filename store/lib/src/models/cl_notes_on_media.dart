// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class NotesOnMedia {
  const NotesOnMedia({
    required this.noteId,
    required this.itemId,
  });

  final int noteId;
  final int itemId;

  NotesOnMedia copyWith({
    int? noteId,
    int? itemId,
  }) {
    return NotesOnMedia(
      noteId: noteId ?? this.noteId,
      itemId: itemId ?? this.itemId,
    );
  }

  @override
  String toString() => 'NotesOnMedia(noteId: $noteId, itemId: $itemId)';

  @override
  bool operator ==(covariant NotesOnMedia other) {
    if (identical(this, other)) return true;

    return other.noteId == noteId && other.itemId == itemId;
  }

  @override
  int get hashCode => noteId.hashCode ^ itemId.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'noteId': noteId,
      'itemId': itemId,
    };
  }

  factory NotesOnMedia.fromMap(Map<String, dynamic> map) {
    return NotesOnMedia(
      noteId: map['noteId'] as int,
      itemId: map['itemId'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotesOnMedia.fromJson(String source) =>
      NotesOnMedia.fromMap(json.decode(source) as Map<String, dynamic>);
}
