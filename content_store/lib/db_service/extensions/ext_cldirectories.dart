import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../storage_service/models/file_system/models/cl_directories.dart';
import 'ext_cl_media.dart';

extension PathExt on CLDirectories {
  String getPreviewAbsolutePath(CLMedia m) => p.join(
        thumbnail.pathString,
        m.previewFileName,
      );

  String getMediaAbsolutePath(CLMedia m) => p.join(
        media.path.path,
        m.mediaFileName,
      );
}
