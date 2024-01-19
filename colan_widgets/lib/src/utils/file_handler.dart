import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../extensions/ext_io_file.dart';

class FileHandler {
  static String join(
    String part1, [
    String? part2,
    String? part3,
    String? part4,
    String? part5,
    String? part6,
    String? part7,
    String? part8,
    String? part9,
    String? part10,
    String? part11,
    String? part12,
    String? part13,
    String? part14,
    String? part15,
    String? part16,
  ]) {
    return path.join(
      part1,
      part2,
      part3,
      part4,
      part5,
      part6,
      part7,
      part8,
      part9,
      part10,
      part11,
      part12,
      part13,
      part14,
      part15,
      part16,
    );
  }

  static Future<File> resolveDocPath(
    String relativePath, {
    String subFolder = '',
  }) async {
    return File(
      join(
        (await getApplicationDocumentsDirectory()).path,
        subFolder,
        relativePath,
      ),
    );
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
          .copyToSync(
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
          .moveToSync(
            await resolveDocFilePath(
              path.basename(filePath),
              subFolder: toSubFolder,
            ),
          )
          .path;

  static Future<String> relativePath(String absolutePath) async =>
      absolutePath.replaceFirst(
        '${await getApplicationDocumentsDirectory()}/',
        '',
      );
}
