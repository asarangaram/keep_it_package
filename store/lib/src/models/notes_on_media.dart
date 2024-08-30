import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class NotesOnMedia {
  const NotesOnMedia({
    required this.noteId,
    required this.mediaId,
  });

  factory NotesOnMedia.fromMap(Map<String, dynamic> map) {
    return NotesOnMedia(
      noteId: map['noteId'] as int,
      mediaId: map['mediaId'] as int,
    );
  }

  factory NotesOnMedia.fromJson(String source) =>
      NotesOnMedia.fromMap(json.decode(source) as Map<String, dynamic>);
  final int noteId;
  final int mediaId;

  NotesOnMedia copyWith({
    int? noteId,
    int? mediaId,
  }) {
    return NotesOnMedia(
      noteId: noteId ?? this.noteId,
      mediaId: mediaId ?? this.mediaId,
    );
  }

  @override
  String toString() => 'NotesOnMedia(noteId: $noteId, mediaId: $mediaId)';

  @override
  bool operator ==(covariant NotesOnMedia other) {
    if (identical(this, other)) return true;

    return other.noteId == noteId && other.mediaId == mediaId;
  }

  @override
  int get hashCode => noteId.hashCode ^ mediaId.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'noteId': noteId,
      'mediaId': mediaId,
    };
  }

  String toJson() => json.encode(toMap());
}
