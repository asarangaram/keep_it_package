// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:content_store/online_service/providers/downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'cl_server.dart';
import 'server_media.dart';

@immutable
class Server {
  final CLServer? identity;
  final bool isOffline;
  final bool workingOffline;
  final bool canSync;
  final bool isRegistered;
  final bool isSyncing;
  const Server({
    this.identity,
    bool isOffline = true,
    this.workingOffline = true,
    this.isSyncing = false,
  })  : canSync = !workingOffline && !isOffline && identity != null,
        isRegistered = identity != null,
        isOffline = isOffline || identity == null;

  Server copyWith({
    ValueGetter<CLServer?>? identity,
    bool? isOffline,
    bool? workingOffline,
    bool? isSyncing,
  }) {
    return Server(
      identity: identity != null ? identity.call() : this.identity,
      isOffline: isOffline ?? this.isOffline,
      workingOffline: workingOffline ?? this.workingOffline,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'Server(identity: $identity, isOffline: $isOffline, workingOffline: $workingOffline, isSyncing: $isSyncing, canSync: $canSync, isRegistered: $isRegistered)';
  }

  @override
  bool operator ==(covariant Server other) {
    if (identical(this, other)) return true;

    return other.identity == identity &&
        other.isOffline == isOffline &&
        other.workingOffline == workingOffline &&
        other.isSyncing == isSyncing &&
        other.canSync == canSync &&
        other.isRegistered == isRegistered;
  }

  @override
  int get hashCode {
    return identity.hashCode ^
        isOffline.hashCode ^
        workingOffline.hashCode ^
        isSyncing.hashCode ^
        canSync.hashCode ^
        isRegistered.hashCode;
  }

  Completer<ServerMedia?>? postMedia(
    ServerMedia media, {
    required DownloaderNotifier downloader,
    String endPoint = '/media',
  }) {
    if (identity == null) return null;
    return _postMedia(
      media,
      endPoint: endPoint,
      server: identity!,
      downloader: downloader,
      mediaBaseDirectory: BaseDirectory.applicationSupport,
    );
  }

  static Completer<ServerMedia?> _postMedia(
    ServerMedia media, {
    required CLServer server,
    required String endPoint,
    required DownloaderNotifier downloader,
    required BaseDirectory mediaBaseDirectory,
  }) {
    final completer = Completer<ServerMedia?>();
    if (media.hasFile) {
      // Use background downloader for multipart upload
      final task = UploadTask(
        url: server.getEndpointURI(endPoint).toString(),
        baseDirectory: mediaBaseDirectory,
        directory: p.dirname(media.path!),
        filename: p.basename(media.path!),
        fileField: 'media',
      );
      downloader.upload(
        task: task,
        onDone: (TaskStatusUpdate update) async {
          if (update.status == TaskStatus.complete) {
            /* final body = update.responseBody;
            final errorCode = update.responseStatusCode; */

            completer.complete(null);
          }
        },
      );
    } else {
      // Use RestAPI
    }
    return completer;
  }
}
