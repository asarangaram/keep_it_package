import 'dart:async';
import 'dart:convert';

import 'package:background_downloader/background_downloader.dart';
import 'package:content_store/online_service/providers/downloader.dart';
import 'package:meta/meta.dart';

import 'package:path/path.dart' as p;

import 'package:store/store.dart';

import 'cl_server.dart';
import 'server_upload_entity.dart';

@immutable
class Server {
  const Server({
    this.previousIdentity,
    this.identity,
    bool isOffline = true,
    this.workingOffline = true,
    this.isSyncing = false,
  })  : canSync = !workingOffline && !isOffline && identity != null,
        isRegistered = identity != null,
        isOffline = isOffline || identity == null;
  final CLServer? identity;
  final bool isOffline;
  final bool workingOffline;
  final bool canSync;
  final bool isRegistered;
  final bool isSyncing;
  final CLServer? previousIdentity;

  Server copyWith({
    ValueGetter<CLServer?>? identity,
    bool? isOffline,
    bool? workingOffline,
    bool? isSyncing,
    ValueGetter<CLServer?>? previousIdentity,
  }) {
    return Server(
      identity: identity != null ? identity.call() : this.identity,
      isOffline: isOffline ?? this.isOffline,
      workingOffline: workingOffline ?? this.workingOffline,
      isSyncing: isSyncing ?? this.isSyncing,
      previousIdentity: previousIdentity != null
          ? previousIdentity.call()
          : this.previousIdentity,
    );
  }

  @override
  String toString() {
    return 'Server(identity: $identity, isOffline: $isOffline, workingOffline: $workingOffline, canSync: $canSync, isRegistered: $isRegistered, isSyncing: $isSyncing, previousIdentity: $previousIdentity)';
  }

  @override
  bool operator ==(covariant Server other) {
    if (identical(this, other)) return true;

    return other.identity == identity &&
        other.isOffline == isOffline &&
        other.workingOffline == workingOffline &&
        other.canSync == canSync &&
        other.isRegistered == isRegistered &&
        other.isSyncing == isSyncing &&
        other.previousIdentity == previousIdentity;
  }

  @override
  int get hashCode {
    return identity.hashCode ^
        isOffline.hashCode ^
        workingOffline.hashCode ^
        canSync.hashCode ^
        isRegistered.hashCode ^
        isSyncing.hashCode ^
        previousIdentity.hashCode;
  }

  Future<Map<String, dynamic>?>? postMedia(
    ServerUploadEntity media, {
    required DownloaderNotifier downloader,
    String endPoint = '/media',
  }) {
    if (identity == null) return null;
    return upsertMedia(
      media,
      endPoint: endPoint,
      server: identity!,
      downloader: downloader,
    );
  }

  /// if media has serverUID, update the media on server
  /// else insert.
  static Future<Map<String, dynamic>?> upsertMedia(
    ServerUploadEntity media, {
    required CLServer server,
    required DownloaderNotifier downloader,
    String endPoint = '/media',
  }) {
    const mediaBaseDirectory = BaseDirectory.applicationSupport;
    final completer = Completer<Map<String, dynamic>?>();
    final String endPoint0;
    if (media.serverUID != null) {
      endPoint0 = '$endPoint/${media.serverUID}';
    } else {
      endPoint0 = endPoint;
    }
    if (media.hasFile) {
      // Use background downloader for multipart upload
      final task = UploadTask(
        url: server.getEndpointURI(endPoint0).toString(),
        baseDirectory: mediaBaseDirectory,
        directory: p.dirname(media.path!),
        filename: p.basename(media.path!),
        fileField: 'media',
        fields: media.fields,
        httpRequestMethod: media.serverUID == null ? 'POST' : 'PUT',
      );

      downloader.enqueue(
        task: task,
        onDone: (TaskStatusUpdate update) async {
          try {
            if (update.exception != null) {
              throw Exception(update.exception);
            }
            if (update.status == TaskStatus.complete) {
              final errorCode = update.responseStatusCode;

              if ((errorCode == 201 || errorCode == 200) &&
                  update.responseBody != null) {
                final received =
                    jsonDecode(update.responseBody!) as Map<String, dynamic>;
                completer.complete(received);
              } else {
                throw Exception(update.responseBody);
              }
            } else if (update.status == TaskStatus.canceled) {
              // ignore if cancelled,
              completer.complete(null);
            } else if (update.status == TaskStatus.failed) {
              throw Exception('download failed');
            } else if (update.status == TaskStatus.notFound) {
              throw Exception('unexpected, the download was never queued');
            }
          } catch (e, st) {
            completer.completeError(e, st);
          }
        },
      );
    } else if (media.serverUID != null) {
      server.put(
        endPoint0,
        form: media.fields,
      )
        ..onError((e, st) async {
          final error = e?.toString() ?? 'unknown error';
          completer.completeError(error, st);
          return error;
        })
        ..then((responseBody) {
          completer.complete(jsonDecode(responseBody) as Map<String, dynamic>);
        });
    } else {
      try {
        throw Exception('Partial update is not possible for new media');
      } catch (e, st) {
        completer.completeError(endPoint0, st);
      }
    }
    return completer.future;
  }

  static Future<bool> deleteMedia(
    int serverUID, {
    required CLServer server,
    required DownloaderNotifier downloader,
    required BaseDirectory mediaBaseDirectory,
    String endPoint = '/media',
  }) {
    final completer = Completer<bool>();
    final String endPoint0;
    endPoint0 = '$endPoint/$serverUID';

    server.delete(
      endPoint0,
    )
      ..onError((e, st) async {
        final error = e?.toString() ?? 'unknown error';
        completer.completeError(error, st);
        return error;
      })
      ..then((responseBody) {
        completer.complete(responseBody.trim().toLowerCase() == 'true');
      });
    return completer.future;
  }

  static Future<String?> downloadMediaFile(
    int serverUID,
    String filename, {
    required CLServer server,
    required DownloaderNotifier downloader,
    required BaseDirectory mediaBaseDirectory,
    String endPoint = '/media',
  }) {
    final completer = Completer<String?>();
    final endPoint0 = '$endPoint/$serverUID/download';
    final task = DownloadTask(
      url: server.getEndpointURI(endPoint0).toString(),
      baseDirectory: mediaBaseDirectory,
      directory: p.dirname(filename),
      filename: p.basename(filename),
    );
    downloader.enqueue(
      task: task,
      onDone: (TaskStatusUpdate update) async {
        if (update.status == TaskStatus.complete) {
          completer.complete(null);
        } else if (update.status == TaskStatus.failed) {
          completer.complete(update.responseBody ?? 'unknown error');
        } else if (update.status == TaskStatus.canceled) {
          completer.complete('cancelled');
        }
      },
    );
    return completer.future;
  }

  static Future<String?> downloadPreviewFile(
    int serverUID,
    String filename, {
    required CLServer server,
    required DownloaderNotifier downloader,
    required BaseDirectory mediaBaseDirectory,
    String endPoint = '/media',
  }) {
    final completer = Completer<String?>();
    final endPoint0 = '$endPoint/$serverUID/preview';
    final task = DownloadTask(
      url: server.getEndpointURI(endPoint0).toString(),
      baseDirectory: mediaBaseDirectory,
      directory: p.dirname(filename),
      filename: p.basename(filename),
    );
    downloader.enqueue(
      task: task,
      onDone: (TaskStatusUpdate update) async {
        if (update.status == TaskStatus.complete) {
          completer.complete(null);
        } else if (update.status == TaskStatus.failed) {
          completer.complete(update.responseBody ?? 'unknown error');
        } else if (update.status == TaskStatus.canceled) {
          completer.complete('cancelled');
        } else {
          completer.complete('cancelled');
        }
      },
    );
    return completer.future;
  }

  static Future<Map<String, dynamic>?> upsertCollection(
    Collection collection, {
    required CLServer server,
    String endPoint = '/collection',
  }) {
    final completer = Completer<Map<String, dynamic>?>();
    final String endPoint0;
    if (collection.serverUID != null) {
      endPoint0 = '$endPoint/${collection.serverUID}';
    } else {
      endPoint0 = endPoint;
    }
    if (collection.serverUID != null) {
      server.put(
        endPoint0,
        form: collection.toUploadMap(),
      )
        ..onError((e, st) async {
          final error = e?.toString() ?? 'unknown error';
          completer.completeError(error, st);
          return error;
        })
        ..then((responseBody) {
          completer.complete(jsonDecode(responseBody) as Map<String, dynamic>);
        });
    } else {
      server.post(
        endPoint,
        form: collection.toUploadMap(),
      )
        ..onError((e, st) async {
          final error = e?.toString() ?? 'unknown error';
          completer.completeError(error, st);
          return error;
        })
        ..then((responseBody) {
          completer.complete(jsonDecode(responseBody) as Map<String, dynamic>);
        });
    }
    return completer.future;
  }

  static Future<bool> deleteCollection(
    int serverUID, {
    required CLServer server,
    required DownloaderNotifier downloader,
    required BaseDirectory mediaBaseDirectory,
    String endPoint = '/collection',
  }) {
    final completer = Completer<bool>();
    final String endPoint0;
    endPoint0 = '$endPoint/$serverUID';

    server.delete(
      endPoint0,
    )
      ..onError((e, st) async {
        final error = e?.toString() ?? 'unknown error';
        completer.completeError(error, st);
        return error;
      })
      ..then((responseBody) {
        completer.complete(responseBody.trim().toLowerCase() == 'true');
      });
    return completer.future;
  }
}
