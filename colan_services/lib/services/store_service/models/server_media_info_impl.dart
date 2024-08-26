import 'dart:io';

import 'package:device_resources/device_resources.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

class ServerMediaInfoImpl extends ServerMediaInfo {
  const ServerMediaInfoImpl({
    required this.serverMediaMetadata,
    required this.appSettings,
    required this.server,
    required this.downloadSettings,
  });

  final AppSettings appSettings;
  final CLServer server;

  final ServerMediaMetadata serverMediaMetadata;
  final DownloadSettings downloadSettings;

  String get mediaFilename =>
      '${serverMediaMetadata.id}.${serverMediaMetadata.fileExtension}';

  ServerMediaMetadata get metadata => serverMediaMetadata;
  Uri get previewFile => returnValidPath(
        Uri.file(
          path_handler.join(
            appSettings.thumbnailDirectoryPath,
            '$mediaFilename.tn',
          ),
        ),
      );
  Uri get mediaFile => returnValidPath(
        Uri.file(
          path_handler.join(
            appSettings.mediaDirectory.path,
            mediaFilename,
          ),
        ),
      );

  @override
  Uri get previewURI {
    if (metadata.previewDownloaded && File(previewFile.path).existsSync()) {
      /// File missing ??
      /// trigger onDownload here
      return previewFile;
    } else {
      return server.getEndpointURI(previewURL);
    }
  }

  @override
  Uri get mediaURI {
    if (metadata.haveItOffline && metadata.mediaDownloaded) {
      /// Caching is requested and cache is ready
      /// send the file cached.

      return mediaFile;
    } else {
      /// File is not in our cache, just return the URL.
      /// image viewer may implement another cache to handle no-network
      /// situation.
      ///
      return server.getEndpointURI(
        metadata.mustDownloadOriginal ? originalURL : mediaURL,
      );
    }
  }

  @override
  bool get isUriOriginal => metadata.mediaDownloaded
      ? metadata.isMediaOriginal
      : metadata.mustDownloadOriginal;

  @override
  String get mediaURL => 'media/${metadata.serverUID}/download/'
      'dim=${downloadSettings.previewDimension}';

  @override
  String get originalURL => 'media/${metadata.serverUID}/download';

  @override
  String get previewURL => 'media/${metadata.serverUID}/download/'
      'dim=${metadata.id}/dim=${downloadSettings.downloadMediaDimension}';
}
