import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';
import 'package:uuid/uuid.dart';

import '../../gallery_service/models/m5_gallery_pin.dart';
import '../../settings_service/models/m1_app_settings.dart';

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

  Uri getValidPreviewUri(CLMedia media) {
    return Uri.file(getPreviewAbsolutePath(media));
  }

  Uri getValidMediaUri(CLMedia media) => Uri.file(
        getMediaAbsolutePath(media),
      );
  bool doesLocalMediaExist(CLMedia media) =>
      File(getValidMediaUri(media).path).existsSync();

  String getPreviewAbsolutePath(CLMedia media) {
    final uuid = uuidGenerator.v5(Uuid.NAMESPACE_URL, media.name);
    return path_handler.join(
      appSettings.directories.thumbnail.pathString,
      '$uuid.tn.jpeg',
    );
  }

  String getMediaAbsolutePath(CLMedia media) => path_handler.join(
        appSettings.directories.media.path.path,
        media.name,
      );
  String getMediaRelativePath(CLMedia media) => path_handler.join(
        appSettings.directories.media.relativePath,
        media.name,
      );
  /* String getMediaFileName(CLMedia media) => path_handler.join(
        appSettings.directories.media.path.path,
        media.name,
      ); */

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
