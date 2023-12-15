import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileHandler {
  static Future<String> getDocumentsDirectory(String? subFolder) async {
    final String documentsDirectory;

    if (subFolder != null) {
      documentsDirectory =
          path.join((await getApplicationDocumentsDirectory()).path, subFolder);
    } else {
      documentsDirectory = (await getApplicationDocumentsDirectory()).path;
    }

    if (!await Directory(documentsDirectory).exists()) {
      await Directory(documentsDirectory).create(recursive: true);
    }
    return documentsDirectory;
  }

  static Future<String> copyAndDeleteFile(
      String srcFilePath, destinationPath) async {
    try {
      // Copy the file to the destination
      await File(srcFilePath).copy(destinationPath);

      // Delete the original file
      await File(srcFilePath).delete();

      return destinationPath;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> move(filePath, {required String toDir}) async {
    // Get the file name from the path
    String fileName = path.basename(filePath);

    // Set the destination directory in the documents folder
    String documentsDirectory = await FileHandler.getDocumentsDirectory(toDir);
    String destinationPath = path.join(documentsDirectory, fileName);
    final newFile =
        await FileHandler.copyAndDeleteFile(filePath, destinationPath);
    return newFile;
  }
}
