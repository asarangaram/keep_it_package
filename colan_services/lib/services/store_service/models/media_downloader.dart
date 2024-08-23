// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:background_downloader/background_downloader.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';

import 'package:store/store.dart';

import 'download_status.dart';

@immutable
class MediaDownloader {
  const MediaDownloader({
    required this.store,
    required this.appSettings,
  });
  final Store store;
  final AppSettings appSettings;

  //

  Future<List<DownloadTask>> prepare({bool reDownload = false}) async {
    final downloadTasks = <DownloadTask>[];
    final server = store.server;
    if (server == null) return downloadTasks;
    final mediaSubDirectory = appSettings.mediaSubDirectory(
      identfier: 'server_${server.identifier}',
    );

    // downloading download status and flags is sufficent
    final medias =
        await store.readMultiple(store.getQuery<CLMedia>(DBQueries.mediaAll));
    final items = medias.map((media) {
      if (media == null) return null;
      return DownloadStatus.readFrom(media);
    });

    return [
      for (final item in items)
        if (item != null)
          ...item.pendingTasks(
            mediaSubDirectory: mediaSubDirectory,
            onGetURI: (path) => server.getEndpointURI(path).toString(),
          ),
    ];
  }

  Future<bool> download() async {
    final tasks = await prepare();
    unawaited(
      FileDownloader().downloadBatch(
        tasks,
        taskStatusCallback: (update) {
          final metadata = jsonDecode(update.task.metaData);
          // ignore: avoid_print
          print(metadata);
        },
      ).then((result) {
        // ignore: avoid_print
        print(
          'Completed ${result.numSucceeded + result.numFailed} '
          'out of ${result.tasks.length}, ${result.numFailed} failed',
        );
      }),
    );
    return true;
  }
}
