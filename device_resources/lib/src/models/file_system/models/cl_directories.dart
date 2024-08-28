// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';

import 'cl_directory.dart';

@immutable
class CLDirectories {
  final Directory persistent;
  final Directory temporary;
  final Directory systemTemp;

  factory CLDirectories({
    required Directory persistent,
    required Directory temporary,
    required Directory systemTemp,
  }) {
    final directories = CLDirectories._(
      persistent: persistent,
      temporary: temporary,
      systemTemp: systemTemp,
    );
    for (final d in directories.directories.values) {
      if (!d.path.existsSync()) {
        d.path.createSync(recursive: true);
      }
    }
    return directories;
  }
  const CLDirectories._({
    required this.persistent,
    required this.temporary,
    required this.systemTemp,
  });

  CLDirectories copyWith({
    Directory? persistent,
    Directory? temporary,
    Directory? systemTemp,
  }) {
    return CLDirectories._(
      persistent: persistent ?? this.persistent,
      temporary: temporary ?? this.temporary,
      systemTemp: systemTemp ?? this.systemTemp,
    );
  }

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'CLDirectories(persistent: $persistent, temporary: $temporary, systemTemp: $systemTemp)';

  @override
  bool operator ==(covariant CLDirectories other) {
    if (identical(this, other)) return true;

    return other.persistent == persistent &&
        other.temporary == temporary &&
        other.systemTemp == systemTemp;
  }

  @override
  int get hashCode =>
      persistent.hashCode ^ temporary.hashCode ^ systemTemp.hashCode;

  Map<String, CLDirectory> get directories => <String, CLDirectory>{
        'media': CLDirectory(
          baseDir: persistent,
          label: 'Media Directory',
          name: 'keep_it/store/media',
          isStore: true,
        ),
        'thumbnail': CLDirectory(
          baseDir: persistent,
          label: 'Thumbnail Cache',
          name: 'keep_it/store/thumbnail',
          isStore: false,
        ),
        'db': CLDirectory(
          baseDir: persistent,
          label: 'DataBase Directory',
          name: 'keep_it/store/database',
          isStore: true,
        ),
        'backup': CLDirectory(
          baseDir: persistent,
          label: 'Backup Directory',
          name: 'keep_it/backup',
          isStore: true,
        ),
        'temp': CLDirectory(
          baseDir: temporary,
          label: 'Temporary Directory',
          name: 'keep_it/temp',
          isStore: false,
        ),
        'download': CLDirectory(
          baseDir: temporary,
          label: 'Download Directory',
          name: 'keep_it/download',
          isStore: false,
        ),
      };

  CLDirectory _directory(String id) {
    final d = directories[id]!;
    if (!d.path.existsSync()) {
      d.path.createSync(recursive: true);
    }
    return d;
  }

  CLDirectory get media => _directory('media');
  CLDirectory get thumbnail => _directory('thumbnail');
  CLDirectory get db => _directory('db');
  CLDirectory get backup => _directory('backup');
  CLDirectory get temp => _directory('temp');
  CLDirectory get download => _directory('download');

  List<CLDirectory> get persistentDirs =>
      directories.values.where((e) => e.isStore == true).toList();
  List<CLDirectory> get cacheDirs =>
      directories.values.where((e) => e.isStore == false).toList();
}



/**
  mediaPersistent => ,
      notesPersistent => 'Notes Directory',
      dbPersistent => ,
      backupPersistent => ,
      capturedMediaPreserved => 'Captured Media Unclassified',
      importedMediaPreserved => 'Imported Media Unclassified',
      downloadedMediaPreserved => 'Downloaded Media Unclassified',
      tempThumbnail => ,
      tempTrimmer => 'Trimmer Cache',
      tempNotes => 'Notes Cache',

 */
