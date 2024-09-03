import 'dart:io';

import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';
import '../models/store_manager.dart';

extension PathExtOnStoreManager on StoreManager {
  Uri getValidPreviewUri(CLMedia media) {
    return Uri.file(getPreviewAbsolutePath(media));
  }

  Uri getValidMediaUri(CLMedia media) => Uri.file(
        getMediaAbsolutePath(media),
      );
  bool doesLocalMediaExist(CLMedia media) =>
      File(getValidMediaUri(media).path).existsSync();

  String getPreviewAbsolutePath(CLMedia media) {
    return path_handler.setExtension(
      path_handler.join(
        appSettings.directories.media.pathString,
        '${media.md5String}_tn',
      ),
      '.jpeg',
    );
  }

  String getMediaAbsolutePath(CLMedia media) => path_handler.setExtension(
        path_handler.join(
          appSettings.directories.media.path.path,
          media.md5String,
        ),
        media.fExt,
      );
  String getMediaRelativePath(CLMedia media) => path_handler.setExtension(
        path_handler.join(
          appSettings.directories.media.relativePath,
          media.md5String,
        ),
        media.fExt,
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
