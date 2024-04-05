import 'dart:io';

import 'package:crypto/crypto.dart';

extension ExtFile on File {
  Future<void> deleteIfExists() async {
    if (await exists()) {
      await delete();
    }
  }

  Future<String> get checksum async {
    try {
      final stream = openRead();
      final hash = await md5.bind(stream).first;

      // NOTE: You might not need to convert it to base64
      return hash.toString();
    } catch (exception) {
      throw Exception('unable to determine md5');
    }
  }
}
