/* import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

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

  static Future<String?> downloadAndSaveImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      // Check if the response contains image data
      if (response.statusCode == 200) {
        // Parse the Content-Type header to determine the file extension
        final mediaType =
            MediaType.parse(response.headers['content-type'] ?? '');
        final fileExtension = mediaType.subtype;

        final documentsDirectory =
            await FileHandler.getDocumentsDirectory('downloaded');

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName = '$timestamp.$fileExtension';
        final logFileName = '$timestamp.$fileExtension.url';

        final filePath = path.join(documentsDirectory, uniqueFileName);
        final logPath = path.join(documentsDirectory, logFileName);

        await File(filePath).writeAsBytes(response.bodyBytes);
        await File(logPath).writeAsString(imageUrl);
        debugPrint('Downloaded $imageUrl');
        return filePath;
      }
    } catch (e) {
      /* */
    }
    return null;
  }
}
 */
