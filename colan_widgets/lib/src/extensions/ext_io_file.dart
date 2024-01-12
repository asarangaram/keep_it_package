import 'dart:io';

extension ColonExtension on File {
  Future<void> deleteIfExists() async {
    if (existsSync()) {
      await delete();
    }
  }
}
