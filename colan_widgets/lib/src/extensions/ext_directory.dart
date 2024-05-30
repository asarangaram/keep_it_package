import 'dart:io';

import '../app_logger.dart';

extension ExtDirectory on Directory {
  void clear() {
    if (existsSync()) {
      _infoLogger('clearning $path');
      final contents = listSync();
      for (final content in contents) {
        if (content is File) {
          content.deleteSync();
        } else if (content is Directory) {
          content.deleteSync(recursive: true);
        }
      }
    } else {
      _infoLogger("$path doesn't exists");
    }
  }
}

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
