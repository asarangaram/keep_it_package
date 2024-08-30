import 'dart:io';

import 'package:device_resources/device_resources.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';
import 'package:uuid/uuid.dart';

@immutable
class StoreManager {
  StoreManager({
    required this.store,
    required this.appSettings,
  });
  final Store store;
  final AppSettings appSettings;
  final AlbumManager albumManager = AlbumManager(albumName: 'KeepIt');
  final String tempCollectionName = '*** Recently Captured';

  static const uuidGenerator = Uuid();

  Uri getValidPreviewPath(CLMedia media) {
    return Uri.file(getPreviewFileName(media));
  }

  Uri getValidMediaPath(CLMedia media) => Uri.file(
        getMediaFileName(media),
      );
  bool doesLocalMediaExist(CLMedia media) =>
      File(getValidMediaPath(media).path).existsSync();

  String getPreviewFileName(CLMedia media) {
    final uuid = uuidGenerator.v5(Uuid.NAMESPACE_URL, media.name);
    return path_handler.join(
      appSettings.directories.thumbnail.pathString,
      '$uuid.tn.jpeg',
    );
  }

  String getMediaFileName(CLMedia media) => path_handler.join(
        appSettings.directories.media.path.path,
        media.name,
      );

  String getMediaLabel(CLMedia media) => media.name;

  Future<String> createTempFile({required String ext}) async {
    final dir = appSettings.directories.download.path;
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
}
