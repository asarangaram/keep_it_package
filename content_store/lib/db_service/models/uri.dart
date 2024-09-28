import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:store/store.dart';

import '../../extensions/ext_cldirectories.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';

@immutable
class MediaPathDeterminer {
  const MediaPathDeterminer({required this.directories});
  final CLDirectories directories;
  AsyncValue<Uri> getPreviewUriAsync(CLMedia m) {
    return AsyncValue.data(Uri.file(directories.getPreviewAbsolutePath(m)));
  }

  AsyncValue<Uri> getMediaUriAsync(
    CLMedia m,
  ) {
    return AsyncValue.data(Uri.file(directories.getMediaAbsolutePath(m)));
  }
}
