// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';

import 'cl_directory.dart';
/* 
enum CLStandardDirectories {
  mediaPersistent,
  notesPersistent,
  dbPersistent,
  backupPersistent,
  capturedMediaPreserved,
  importedMediaPreserved,
  downloadedMediaPreserved,

  tempThumbnail,
  tempTrimmer,
  tempNotes;

  bool get isStore {
    return switch (this) {
      mediaPersistent => true,
      notesPersistent => true,
      _ => false,
    };
  }

  bool get isPersistent {
    return switch (this) {
      mediaPersistent => true,
      notesPersistent => true,
      dbPersistent => true,
      backupPersistent => true,
      capturedMediaPreserved => true,
      importedMediaPreserved => true,
      downloadedMediaPreserved => true,
      tempThumbnail => false,
      tempTrimmer => false,
      tempNotes => false,
    };
  }

  String get label {
    return switch (this) {
      mediaPersistent => 'Media Directory',
      notesPersistent => 'Notes Directory',
      dbPersistent => 'DataBase',
      backupPersistent => 'Backup Dir',
      capturedMediaPreserved => 'Captured Media Unclassified',
      importedMediaPreserved => 'Imported Media Unclassified',
      downloadedMediaPreserved => 'Downloaded Media Unclassified',
      tempThumbnail => 'Thumbnail Cache',
      tempTrimmer => 'Trimmer Cache',
      tempNotes => 'Notes Cache',
    };
  }

  String get name {
    return switch (this) {
      mediaPersistent => 'keep_it/store/media',
      notesPersistent => 'keep_it/store/notes',
      dbPersistent => 'keep_it/store/database',
      backupPersistent => 'keep_it/backup',
      capturedMediaPreserved => 'keep_it/temp/captured',
      importedMediaPreserved => 'keep_it/temp/imported',
      downloadedMediaPreserved => 'keep_it/temp/downloaded',
      tempThumbnail => 'keep_it/temp/thumbnail',
      tempTrimmer => 'Trimmer',
      tempNotes => 'keep_it/temp/notes',
    };
  }
} */

@immutable
class CLDirectories {
  final Directory persistent;
  final Directory temporary;
  final Directory systemTemp;

  const CLDirectories({
    required this.persistent,
    required this.temporary,
    required this.systemTemp,
  });

  CLDirectories copyWith({
    Directory? persistent,
    Directory? temporary,
    Directory? systemTemp,
  }) {
    return CLDirectories(
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

  CLDirectory get media => directories['media']!;
  CLDirectory get thumbnail => directories['thumbnail']!;
  CLDirectory get db => directories['db']!;
  CLDirectory get backup => directories['db']!;
  CLDirectory get temp => directories['temp']!;
  CLDirectory get download => directories['download']!;

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