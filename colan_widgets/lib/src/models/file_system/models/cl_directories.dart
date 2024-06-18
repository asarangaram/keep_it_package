// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';

import 'cl_directory.dart';

enum CLStandardDirectories {
  mediaPersistent,
  notesPersistent,
  dbPersistent,
  capturedMediaPreserved,
  importedMediaPreserved,
  downloadedMediaPreserved,

  tempThumbnail,
  tempTrimmer,
  tempNotes;

  bool get isPersistent {
    return switch (this) {
      mediaPersistent => true,
      notesPersistent => true,
      dbPersistent => true,
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
      capturedMediaPreserved => 'keep_it/temp/captured',
      importedMediaPreserved => 'keep_it/temp/imported',
      downloadedMediaPreserved => 'keep_it/temp/downloaded',
      tempThumbnail => 'keep_it/temp/thumbnail',
      tempTrimmer => 'keep_it/temp/trimmer',
      tempNotes => 'keep_it/temp/notes',
    };
  }
}

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

  CLDirectory standardDirectory(CLStandardDirectories dir) => CLDirectory(
        label: dir.label,
        name: dir.name,
        baseDir: dir.isPersistent ? persistent : temporary,
      )..create();

  CLDirectory get media =>
      standardDirectory(CLStandardDirectories.mediaPersistent);
  CLDirectory get notes =>
      standardDirectory(CLStandardDirectories.notesPersistent);
  CLDirectory get capturedMedia =>
      standardDirectory(CLStandardDirectories.capturedMediaPreserved);
  CLDirectory get importedMedia =>
      standardDirectory(CLStandardDirectories.importedMediaPreserved);
  CLDirectory get downloadedMedia =>
      standardDirectory(CLStandardDirectories.downloadedMediaPreserved);
  CLDirectory get thumbnail =>
      standardDirectory(CLStandardDirectories.tempThumbnail);
  CLDirectory get trimmer =>
      standardDirectory(CLStandardDirectories.tempTrimmer);
  CLDirectory get tempNotes =>
      standardDirectory(CLStandardDirectories.tempNotes);
  CLDirectory get database =>
      standardDirectory(CLStandardDirectories.dbPersistent);
}
