import 'dart:io';

extension ExtDirectory on Directory {
  void clear() {
    if (existsSync()) {
      final contents = listSync();
      for (final content in contents) {
        if (content is File) {
          content.deleteSync();
        } else if (content is Directory) {
          content.deleteSync(recursive: true);
        }
      }
    }
  }
}
