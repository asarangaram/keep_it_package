import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import '../models/supported_media.dart';
import 'file_handler.dart';

class URLHandler {
  static Future<SupportedMediaType?> getMimeType(String url) async {
    try {
      final response = await http.head(Uri.parse(url));

      // Check if the Content-Type header is present in the response
      if (response.headers.containsKey('content-type')) {
        final String contentType = response.headers['content-type']!;

        return switch (contentType) {
          (String c) when c.startsWith("image") => SupportedMediaType.image,
          (String c) when c.startsWith("video") => SupportedMediaType.video,
          (String c) when c.startsWith("audio") => SupportedMediaType.video,
          (String c) when c.startsWith("application/pdf") =>
            SupportedMediaType.file,
          _ => SupportedMediaType.url
        };
      }
    } catch (e) {
      /** */
    }
    return SupportedMediaType.url;
  }

  static Future<String?> downloadAndSaveImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      // Check if the response contains image data
      if (response.statusCode == 200) {
        // Parse the Content-Type header to determine the file extension
        MediaType mediaType =
            MediaType.parse(response.headers['content-type'] ?? '');
        String fileExtension = mediaType.subtype;

        String documentsDirectory =
            await FileHandler.getDocumentsDirectory("downloaded");

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName = '$timestamp.$fileExtension';
        final logFileName = '$timestamp.$fileExtension.url';

        String filePath = path.join(documentsDirectory, uniqueFileName);
        String logPath = path.join(documentsDirectory, logFileName);

        await File(filePath).writeAsBytes(response.bodyBytes);
        await File(logPath).writeAsString(imageUrl);
        debugPrint("Downloaded $imageUrl");
        return filePath;
      }
    } catch (e) {
      /* */
    }
    return null;
  }
}
