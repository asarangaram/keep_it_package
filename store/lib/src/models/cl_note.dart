// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

@immutable
class CLNote {
  const CLNote({
    required this.createdDate,
    required this.type,
    required this.path,
    required this.id,
    this.updatedDate,
    this.serverUID,
    this.locallyModified = true,
  });

  factory CLNote.fromMap(Map<String, dynamic> map) {
    if (CLMediaType.values.asNameMap()[map['type'] as String] == null) {
      throw Exception('Incorrect type');
    }
    final type = CLMediaType.values.asNameMap()[map['type'] as String]!;
    final createdDate = DateTime.parse(map['updatedDate'] as String);
    final updatedDate = map['updatedDate'] != null
        ? DateTime.parse(map['updatedDate'] as String)
        : null;
    final path = map['path'] as String;
    final serverUID = map['serverUID'] != null ? map['serverUID'] as int : null;
    final locallyModified = (map['locallyModified'] as int? ?? 1) == 1;
    return switch (type) {
      CLMediaType.audio => CLAudioNote(
          id: map['id'] == null ? null : map['id']! as int,
          createdDate: createdDate,
          path: path,
          updatedDate: updatedDate,
          serverUID: serverUID,
          locallyModified: locallyModified,
        ),
      CLMediaType.text => CLTextNote(
          id: map['id'] == null ? null : map['id']! as int,
          createdDate: createdDate,
          path: path,
          updatedDate: updatedDate,
          serverUID: serverUID,
          locallyModified: locallyModified,
        ),
      _ => throw UnimplementedError('Unsupported Notes')
    };
  }
  final int? id;
  final DateTime createdDate;
  final DateTime? updatedDate;
  final CLMediaType type;
  final String path;
  final int? serverUID;
  final bool locallyModified;

  CLNote copyWith({
    int? id,
    DateTime? createdDate,
    DateTime? updatedDate,
    CLMediaType? type,
    String? path,
    int? serverUID,
    bool? locallyModified,
  }) {
    return CLNote(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      type: type ?? this.type,
      path: path ?? this.path,
      serverUID: serverUID ?? this.serverUID,
      locallyModified: locallyModified ?? this.locallyModified,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'CLNote(id: $id, createdDate: $createdDate, updatedDate: $updatedDate, type: $type, path: $path, serverUID: $serverUID, locallyModified: $locallyModified)';
  }

  @override
  bool operator ==(covariant CLNote other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate &&
        other.type == type &&
        other.path == path &&
        other.serverUID == serverUID &&
        other.locallyModified == locallyModified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode ^
        type.hashCode ^
        path.hashCode ^
        serverUID.hashCode ^
        locallyModified.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'createdDate': createdDate.toSQL(),
      'type': type.name,
      'path': path,
      'serverUID': serverUID,
      'locallyModified': locallyModified ? 1 : 0,
    };
  }

  Map<String, dynamic> toMap2({
    required bool validate,
    String? pathPrefix,
  }) {
    return <String, dynamic>{
      'id': id,
      'createdDate': createdDate.toSQL(),
      'type': type.name,
      'path': CLMedia.relativePath(
        path,
        pathPrefix: pathPrefix,
        validate: validate,
      ),
    };
  }

  /* String toJson() => json.encode(toMap());

  factory CLMessage.fromJson(String source) =>
      CLMessage.fromMap(json.decode(source) as Map<String, dynamic>); */

  Future<CLNote> moveFile({
    required String targetDir,
  }) async {
    final sourceFile = File(path);
    final dir = Directory(targetDir);

    if (!sourceFile.existsSync()) {
      throw FileSystemException('Source file does not exist', path);
    }

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final baseName = p.basenameWithoutExtension(path);
    final extension = p.extension(path);
    var newFilePath = p.join(dir.path, p.basename(path));

    var counter = 1;

    while (File(newFilePath).existsSync()) {
      newFilePath = p.join(dir.path, '${baseName}_($counter)$extension');
      counter++;
    }

    final copiedFile = await sourceFile.copy(newFilePath);
    return copyWith(path: copiedFile.path);
  }
}

@immutable
class CLTextNote extends CLNote {
  const CLTextNote({
    required super.id,
    required super.createdDate,
    required super.path,
    super.updatedDate,
    super.type = CLMediaType.text,
    super.serverUID,
    super.locallyModified,
  });
}

@immutable
class CLAudioNote extends CLNote {
  const CLAudioNote({
    required super.id,
    required super.createdDate,
    required super.path,
    super.type = CLMediaType.audio,
    super.updatedDate,
    super.serverUID,
    super.locallyModified,
  });
}

@immutable
class NotesOnMedia {
  const NotesOnMedia({
    required this.noteId,
    required this.itemId,
  });

  factory NotesOnMedia.fromMap(Map<String, dynamic> map) {
    return NotesOnMedia(
      noteId: map['noteId'] as int,
      itemId: map['itemId'] as int,
    );
  }

  factory NotesOnMedia.fromJson(String source) =>
      NotesOnMedia.fromMap(json.decode(source) as Map<String, dynamic>);
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

  String toJson() => json.encode(toMap());
}
