import 'dart:io';

extension ColonExtension on File {
  void deleteIfExists() {
    if (existsSync()) {
      deleteSync();
    }
  }

  File copyTo(String target) {
    if (!existsSync()) {
      throw Exception('src file is missing $absolute');
    }
    return copySync((File(target)..createSync(recursive: true)).path);
  }

  File moveTo(String target) {
    final file = copyTo(target);
    deleteSync();
    return file;
  }
}
