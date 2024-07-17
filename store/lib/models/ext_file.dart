import 'dart:io';

extension ExtDeleteFile on File {
  Future<void> deleteIfExists() async {
    if (await exists()) {
      await delete();
    }
  }
}
