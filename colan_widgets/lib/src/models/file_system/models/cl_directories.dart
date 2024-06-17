// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';

import 'cl_directory.dart';

enum CLStandardDirectories {
  mediaPersistent,
  notesPersistent,
  capturedMediaPreserved,
  importedMediaPreserved,
  downloadedMediaPreserved,

  tempThumbnail,
  tempTrimmer,
  tempAudioRecorder;

  bool get isPersistent {
    return switch (this) {
      mediaPersistent => true,
      notesPersistent => true,
      capturedMediaPreserved => true,
      importedMediaPreserved => true,
      downloadedMediaPreserved => true,
      tempThumbnail => false,
      tempTrimmer => false,
      tempAudioRecorder => false,
    };
  }

  String get label {
    return switch (this) {
      mediaPersistent => 'Media Directory',
      notesPersistent => 'Notes Directory',
      capturedMediaPreserved => 'Captured Media Unclassified',
      importedMediaPreserved => 'Imported Media Unclassified',
      downloadedMediaPreserved => 'Downloaded Media Unclassified',
      tempThumbnail => 'Thumbnail Cache',
      tempTrimmer => 'Trimmer Cache',
      tempAudioRecorder => 'Audio Recorder Cache',
    };
  }

  String get name {
    return switch (this) {
      mediaPersistent => 'keep_it/store/media',
      notesPersistent => 'keep_it/store/notes',
      capturedMediaPreserved => 'keep_it/temp/captured',
      importedMediaPreserved => 'keep_it/temp/imported',
      downloadedMediaPreserved => 'keep_it/temp/downloaded',
      tempThumbnail => 'keep_it/temp/thumbnail',
      tempTrimmer => 'keep_it/temp/trimmer',
      tempAudioRecorder => 'keep_it/temp/audio_recorder',
    };
  }
}

@immutable
class CLDirectories {
  final Directory persistent;
  final Directory temporary;
  const CLDirectories({
    required this.persistent,
    required this.temporary,
  });

  CLDirectories copyWith({
    Directory? persistent,
    Directory? temporary,
  }) {
    return CLDirectories(
      persistent: persistent ?? this.persistent,
      temporary: temporary ?? this.temporary,
    );
  }

  @override
  String toString() =>
      'CLDirectories(persistent: $persistent, temporary: $temporary)';

  @override
  bool operator ==(covariant CLDirectories other) {
    if (identical(this, other)) return true;

    return other.persistent == persistent && other.temporary == temporary;
  }

  @override
  int get hashCode => persistent.hashCode ^ temporary.hashCode;

  CLDirectory standardDirectory(CLStandardDirectories dir) => CLDirectory(
        label: dir.label,
        name: dir.name,
        baseDir: dir.isPersistent ? persistent : temporary,
      );

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
  CLDirectory get audioRecorder =>
      standardDirectory(CLStandardDirectories.tempAudioRecorder);
}
