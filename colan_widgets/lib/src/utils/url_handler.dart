import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import 'file_handler.dart';
import 'media/cl_media_type.dart';

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
    String subDir = '',
  }) async {
    try {
      final noMediaFile = File(
        path.join(
          await FileHandler.getDocumentsDirectory(
            'downloaded',
          ),
          '.nomedia',
        ),
      );
      if (!noMediaFile.existsSync()) {
        noMediaFile.createSync(recursive: true);
      }
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

        final documentsDirectory = await FileHandler.getDocumentsDirectory(
          path.join('downloaded', subDir),
        );
        final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
        final filePath =
            '${uniqueId}_${path.join(documentsDirectory, filename)}';

        File(filePath).writeAsBytesSync(response.bodyBytes);

        return filePath;
      }
    } catch (e) {
      /* */
    }
    return null;
  }
}
