// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:colan_widgets/src/extensions/ext_datetime.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../app_logger.dart';
import 'cl_media.dart';
import 'm1_app_settings.dart';

enum CLNoteTypes { text, audio }

@immutable
class CLNote {
  const CLNote({
    required this.createdDate,
    required this.type,
    required this.path,
    required this.id,
    this.updatedDate,
  });

  factory CLNote.fromMap(Map<String, dynamic> map) {
    if (CLNoteTypes.values.asNameMap()[map['type'] as String] == null) {
      throw Exception('Incorrect type');
    }
    final type = CLNoteTypes.values.asNameMap()[map['type'] as String]!;
    final createdDate = DateTime.parse(map['updatedDate'] as String);
    final updatedDate = map['updatedDate'] != null
        ? DateTime.parse(map['updatedDate'] as String)
        : null;
    final path = map['path'] as String;
    return switch (type) {
      CLNoteTypes.audio => CLAudioNote(
          id: map['id'] == null ? null : map['id']! as int,
          createdDate: createdDate,
          path: path,
          updatedDate: updatedDate,
        ),
      CLNoteTypes.text => CLTextNote(
          id: map['id'] == null ? null : map['id']! as int,
          createdDate: createdDate,
          path: path,
          updatedDate: updatedDate,
        )
    };
  }
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
    return 'CLNote(id: $id, createdDate: $createdDate, updatedDate: $updatedDate, type: $type, note: $path)';
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
      'createdDate': createdDate.toSQL(),
      'type': type.name,
      'path': path,
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

  factory CLNote.fromMap2(
    Map<String, dynamic> map1, {
    // ignore: avoid_unused_constructor_parameters
    required AppSettings appSettings,
  }) {
    final pathPrefix = appSettings.directories.docDir.path;
    if (CLNoteTypes.values.asNameMap()[map1['type'] as String] == null) {
      throw Exception('Incorrect type');
    }
    // ignore: unnecessary_null_comparison
    final path = ((pathPrefix != null)
        ? '$pathPrefix/${map1['path']}'
        : map1['path'] as String)
      ..replaceAll('//', '/');
    if (appSettings.shouldValidate && !File(path).existsSync()) {
      /* exceptionLogger(
        'File not found',
        'CL Note file path read from database is not found',
      ); */
    }
    final map = Map<String, dynamic>.from(map1)
      ..removeWhere((key, value) => value == 'null');
    map['path'] = path;
    return CLNote.fromMap(map);
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
    super.type = CLNoteTypes.text,
  });

  String get text {
    if (!File(path).existsSync()) {
      return 'Content Missing. File is deleted';
    }
    return File(path).readAsStringSync();
  }
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
class NotesOnMedia {
  final int noteId;
  final int itemId;
  const NotesOnMedia({
    required this.noteId,
    required this.itemId,
  });

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
