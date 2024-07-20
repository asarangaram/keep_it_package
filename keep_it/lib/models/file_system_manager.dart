// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_handler;
import 'package:uuid/uuid.dart';

@immutable
class FileSystemManager {
  const FileSystemManager(
    this.appSettings,
  );
  final AppSettings appSettings;

  static const uuidGenerator = Uuid();

  /// FileSystem
  Future<void> deleteMediaFiles(CLMedia media) async {
    await File(getMediaPath(media)).deleteIfExists();
    await File(getPreviewPath(media)).deleteIfExists();
  }

  Future<void> deleteNoteFiles(CLNote note) async {
    await File(getNotesPath(note)).deleteIfExists();
  }

  String getPreviewPath(CLMedia media) {
    final uuid = uuidGenerator.v5(Uuid.NAMESPACE_URL, media.label);
    final previewFileName = path_handler.join(
      appSettings.directories.thumbnail.pathString,
      '$uuid.tn.jpeg',
    );
    return previewFileName;
  }

  String getMediaPath(CLMedia media) => path_handler.join(
        appSettings.directories.media.path.path,
        media.label,
      );
  String getMediaLabel(CLMedia media) => media.label;

  String getNotesPath(CLNote note) => path_handler.join(
        appSettings.directories.notes.path.path,
        note.path,
      );

  String getText(CLTextNote? note) {
    final String text;
    if (note != null) {
      final notesPath = getNotesPath(note);

      final notesFile = File(notesPath);
      if (!notesFile.existsSync()) {
        text = 'Content Missing. File is deleted';
      } else {
        text = notesFile.readAsStringSync();
      }
    } else {
      text = '';
    }
    return text;
  }

  Future<String> createTempFile({required String ext}) async {
    final dir = appSettings.directories.downloadedMedia.path;
    final fileBasename = 'keep_it_${DateTime.now().millisecondsSinceEpoch}';
    final absolutePath = '${dir.path}/$fileBasename.$ext';

    return absolutePath;
  }

  Future<String> createBackupFile() async {
    final dir = appSettings.directories.backup.path;
    final fileBasename =
        'keep_it_backup_${DateTime.now().millisecondsSinceEpoch}';
    final absolutePath = '${dir.path}/$fileBasename.tar.gz';

    return absolutePath;
  }

  Future<CLMedia> getMetadata(
    CLMedia media, {
    bool? regenerate,
  }) async {
    if (media.type == CLMediaType.image) {
      return media.copyWith(
        originalDate: (await File(getMediaPath(media))
                .getImageMetaData(regenerate: regenerate))
            ?.originalDate,
      );
    } else if (media.type == CLMediaType.video) {
      return media.copyWith(
        originalDate: (await File(getMediaPath(media))
                .getVideoMetaData(regenerate: regenerate))
            ?.originalDate,
      );
    } else {
      return media;
    }
  }
}
