import 'dart:convert';

import 'package:background_downloader/background_downloader.dart';
import 'package:path/path.dart';

import '../models/server_media_info_impl.dart';

extension StoreExtOnDownloadSettings on ServerMediaInfoImpl {
  // directory: '' , // `TODO`

  List<DownloadTask> pendingMediaDownloadTasks() {
    return [
      if (!metadata.previewDownloaded)
        DownloadTask(
          url: server.getEndpointURI(previewURL).path,
          filename: basename(previewFile.path),
          requiresWiFi: true,
          retries: 5,
          metaData: jsonEncode({'preview': metadata.serverUID}),
        ),
      if (metadata.haveItOffline)
        if (metadata.mustDownloadOriginal)
          DownloadTask(
            url: metadata.mustDownloadOriginal
                ? server.getEndpointURI(originalURL).path
                : server.getEndpointURI(mediaURL).path,
            filename: basename(mediaFile.path),
            requiresWiFi: true,
            retries: 5,
            metaData: jsonEncode({'media': metadata.serverUID}),
          ),
    ];
  }
}
