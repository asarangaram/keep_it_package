import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../extensions/ext_io_file.dart';

class FileHandler {
  static Future<File> resolveDocPath(
    String relativePath, {
    String subFolder = '',
  }) async {
    if (!subFolder.startsWith('/')) {
      return File(
        path.join(
          (await getApplicationDocumentsDirectory()).path,
          subFolder,
          relativePath,
        ),
      );
    } else {
      return File(
        path.join(
          subFolder,
          relativePath,
        ),
      );
    }
  }

  static Future<String> resolveDocFilePath(
    String relativePath, {
    String subFolder = '',
  }) async =>
      (await resolveDocPath(relativePath, subFolder: subFolder)).path;

  static Future<String> copy(
    String filePath, {
    required String toSubFolder,
  }) async =>
      File(filePath)
          .copyTo(
            await resolveDocFilePath(
              path.basename(filePath),
              subFolder: toSubFolder,
            ),
          )
          .path;

  static Future<String> move(
    String filePath, {
    required String toSubFolder,
  }) async =>
      File(filePath)
          .moveTo(
            await resolveDocFilePath(
              path.basename(filePath),
              subFolder: toSubFolder,
            ),
          )
          .path;
}
