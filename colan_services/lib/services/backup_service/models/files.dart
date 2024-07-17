import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

@immutable
class NotesFile {
  const NotesFile({
    required this.path,
    required this.absPath,
  });
  final String path;
  final String absPath;

  NotesFile copyWith({
    String? path,
    String? absPath,
  }) {
    return NotesFile(
      path: path ?? this.path,
      absPath: absPath ?? this.absPath,
    );
  }

  MapEntry<String, File> get mapEntry => MapEntry('notes/$path', File(absPath));

  @override
  String toString() => 'NotesFile(path: $path, absPath: $absPath)';

  @override
  bool operator ==(covariant NotesFile other) {
    if (identical(this, other)) return true;

    return other.path == path && other.absPath == absPath;
  }

  @override
  int get hashCode => path.hashCode ^ absPath.hashCode;
}

@immutable
class MediaFile {
  const MediaFile({
    required this.path,
    required this.absPath,
    this.noteFiles,
  });
  final String path;
  final String absPath;
  final List<NotesFile>? noteFiles;

  MediaFile copyWith({
    String? path,
    String? absPath,
    List<NotesFile>? noteFiles,
  }) {
    return MediaFile(
      path: path ?? this.path,
      absPath: absPath ?? this.absPath,
      noteFiles: noteFiles ?? this.noteFiles,
    );
  }

  int get filesCount => 1 + (noteFiles?.length ?? 0);

  MapEntry<String, File> get mapEntry => MapEntry('media/$path', File(absPath));

  @override
  String toString() =>
      'MediaFile(path: $path, absPath: $absPath, noteFiles: $noteFiles)';

  @override
  bool operator ==(covariant MediaFile other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.path == path &&
        other.absPath == absPath &&
        listEquals(other.noteFiles, noteFiles);
  }

  @override
  int get hashCode => path.hashCode ^ absPath.hashCode ^ noteFiles.hashCode;
}
