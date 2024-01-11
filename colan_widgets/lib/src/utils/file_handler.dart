import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileHandler {
  static Future<String> getDocumentsDirectory(String? subFolder) async {
    final String documentsDirectory;

    if (subFolder != null) {
      documentsDirectory =
          path.join((await getApplicationDocumentsDirectory()).path, subFolder);
    } else {
      documentsDirectory = (await getApplicationDocumentsDirectory()).path;
    }

    if (!Directory(documentsDirectory).existsSync()) {
      await Directory(documentsDirectory).create(recursive: true);
    }
    return documentsDirectory;
  }

  static Future<String> copyAndDeleteFile(
    String srcFilePath,
    String destinationPath,
  ) async {
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

  static Future<String> move(String filePath, {required String toDir}) async {
    // Get the file name from the path
    final fileName = path.basename(filePath);

    // Set the destination directory in the documents folder
    final documentsDirectory = await FileHandler.getDocumentsDirectory(toDir);
    final destinationPath = path.join(documentsDirectory, fileName);
    final newFile =
        await FileHandler.copyAndDeleteFile(filePath, destinationPath);
    return newFile;
  }

  static Future<String> getAbsoluteFilePath(String mediaPath) async {
    final dir = await FileHandler.getDocumentsDirectory(null);
    return getAbsoluteFilePathSync(mediaPath, dir: dir);
  }

  static String getAbsoluteFilePathSync(
    String mediaPath, {
    required String dir,
  }) {
    /// prefix the directory if the path is not absolute
    ///  if from assets, leave it as it is.
    return switch (mediaPath) {
      (final String s) when mediaPath.startsWith('assets') => s,
      (final String s) when mediaPath.startsWith('/') => s,
      _ => path.join(dir, mediaPath),
    };
  }
}
