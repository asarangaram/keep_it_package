import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path_handler;

import '../../../extensions/ext_file.dart';
import '../../cl_media_type.dart';

class URLHandler {
  static Future<CLMediaType?> getMimeType(String url) async {
    try {
      final response = await http.head(Uri.parse(url));

      // Check if the Content-Type header is present in the response
      if (response.headers.containsKey('content-type')) {
        final contentType = response.headers['content-type']!;

        return switch (contentType) {
          (final String c) when c.startsWith('image') => CLMediaType.image,
          (final String c) when c.startsWith('video') => CLMediaType.video,
          (final String c) when c.startsWith('audio') => CLMediaType.audio,
          (final String c) when c.startsWith('application/pdf') =>
            CLMediaType.file,
          _ => CLMediaType.url
        };
      }
    } catch (e) {
      /** */
    }
    return CLMediaType.url;
  }

  static Future<String?> download(String url, Directory downloadDir) async {
    String? filename;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      filename = avoidOverwriting(
        path_handler.join(
          downloadDir.path,
          getFileName(response),
        ),
      );

      File(filename)
        ..createSync(recursive: true)
        ..writeAsBytesSync(response.bodyBytes);
      return filename;
    } catch (e) {
      if (filename != null) {
        await File(filename).deleteIfExists();
      }
      return null;
    }
  }

  static String avoidOverwriting(String fullPath) {
    // Check if the file already exists
    if (!File(fullPath).existsSync()) {
      return fullPath; // If file doesn't exist, return original full path
    }

    final directory = Directory(path_handler.dirname(fullPath));
    final fileName = path_handler.basenameWithoutExtension(fullPath);
    final extension = path_handler.extension(fullPath);

    var index = 1;
    String newFileName;
    do {
      newFileName = '$fileName-$index$extension';
      index++;
    } while (File('${directory.path}/$newFileName').existsSync());

    return '${directory.path}/$newFileName';
  }

  static String getFileName(Response response) {
    String? filename;

    // Check if we get file name
    if (response.headers.containsKey('content-disposition')) {
      final contentDispositionHeader = response.headers['content-disposition'];
      final match = RegExp('filename=(?:"([^"]+)"|(.*))')
          .firstMatch(contentDispositionHeader!);

      filename = match?[1] ?? match?[2];
    }
    filename = filename ?? '${DateTime.now().millisecondsSinceEpoch}_tmp';
    if (path_handler.extension(filename).isEmpty) {
      // If no extension found, add extension if possible
      // Parse the Content-Type header to determine the file extension
      final mediaType = MediaType.parse(response.headers['content-type'] ?? '');

      final fileExtension = mediaType.subtype;
      filename = '$filename.$fileExtension';
    }
    return filename;
  }
}
/* 
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import '../cl_media_type.dart';
import 'file_handler.dart';

class URLHandler {
  static Future<CLMediaType?> getMimeType(String url) async {
    try {
      final response = await http.head(Uri.parse(url));

      // Check if the Content-Type header is present in the response
      if (response.headers.containsKey('content-type')) {
        final contentType = response.headers['content-type']!;

        return switch (contentType) {
          (final String c) when c.startsWith('image') => CLMediaType.image,
          (final String c) when c.startsWith('video') => CLMediaType.video,
          (final String c) when c.startsWith('audio') => CLMediaType.video,
          (final String c) when c.startsWith('application/pdf') =>
            CLMediaType.file,
          _ => CLMediaType.url
        };
      }
    } catch (e) {
      /** */
    }
    return CLMediaType.url;
  }

  static Future<String?> downloadAndSaveImage(
    String imageUrl, {
    String? prefix,
    String docDir,
  }) async {
    try {
      (await FileHandler.resolveDocPath('.nomedia', subFolder: 'downloaded'))
          .createSync(recursive: true);

      final response = await http.get(Uri.parse(imageUrl));

      // Check if the response contains image data
      if (response.statusCode == 200) {
        String? filename;
        // Check if we get file name
        if (response.headers.containsKey('content-disposition')) {
          final contentDispositionHeader =
              response.headers['content-disposition'];
          final match = RegExp('filename=(?:"([^"]+)"|(.*))')
              .firstMatch(contentDispositionHeader!);

          filename = match?[1] ?? match?[2];
        }
        filename = filename ?? 'unnamedfile';

        if (path.extension(filename).isEmpty) {
          // If no extension found, add extension if possible
          // Parse the Content-Type header to determine the file extension
          final mediaType =
              MediaType.parse(response.headers['content-type'] ?? '');

          final fileExtension = mediaType.subtype;
          filename = '$filename.$fileExtension';
        }
        // Create Directory if not exists:

        return (await FileHandler.resolveDocPath(
          '${prefix ?? DateTime.now().millisecondsSinceEpoch.toString()}_'
          '$filename',
          subFolder: 'downloaded',
        )
              ..writeAsBytesSync(response.bodyBytes))
            .path;
      }
    } catch (e) {
      /* */
    }
    return null;
  }
}
 */
