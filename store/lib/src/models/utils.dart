import 'dart:io';
import 'dart:math';

class Utils {
  static String getRandomString(int length) {
    const characters = '0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

  static String getAvailableFileName(String fileName) {
    var file = File(fileName);
    if (!file.existsSync()) {
      return fileName;
    }

    final dir = file.parent.path;
    final baseName = file.uri.pathSegments.last.split('.').first;
    final extension = file.uri.pathSegments.last.split('.').length > 1
        ? '.${file.uri.pathSegments.last.split('.').last}'
        : '';

    while (file.existsSync()) {
      final randomString = getRandomString(5); // Adjust the length as needed
      final newFileName = '$dir/${baseName}_$randomString$extension';
      file = File(newFileName);
    }

    return file.path;
  }
}
