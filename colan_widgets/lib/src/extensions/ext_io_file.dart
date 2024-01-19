import 'dart:io';

extension ColonExtension on File {
  void deleteIfExists() {
    if (existsSync()) {
      deleteSync();
    }
  }

  File copyToSync(String target) {
    if (!existsSync()) {
      throw Exception('src file is missing $absolute');
    }
    return copySync((File(target)..createSync(recursive: true)).path);
  }

  File moveToSync(String target) {
    final file = copyToSync(target);
    deleteSync();
    return file;
  }
}
