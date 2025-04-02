import 'package:meta/meta.dart';
import 'package:store/store.dart';

import '../../extensions/ext_cldirectories.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';

@immutable
class MediaPathDeterminer {
  const MediaPathDeterminer({required this.directories});
  final CLDirectories directories;
  Uri getPreviewUri(CLMedia m) {
    return Uri.file(directories.getPreviewAbsolutePath(m));
  }

  Uri getMediaUri(CLMedia m) {
    return Uri.file(directories.getMediaAbsolutePath(m));
  }
}
