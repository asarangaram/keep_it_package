import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import '../../../db_service/models/store_updater.dart';
import '../../providers/downloader.dart';
import '../cl_server.dart';

@immutable
abstract class SyncModule<T> {
  SyncModule(this.server, this.updater, this.downloader)
      : store = updater.store;
  final CLServer server;
  final StoreUpdater updater;
  final DownloaderNotifier downloader;
  final Store store;

  Future<void> updateServerResponse(T item, Map<String, dynamic> resMap);
  Future<void> upload(T item);
  Future<void> download(T item);
  Future<void> deleteLocal(T item);
  Future<void> deleteOnServer(T item);
  Future<void> updateLocal(T item);
  Future<void> updateOnServer(T item);

  Future<void> sync(
    List<Map<String, dynamic>> itemsOnServerMap,
    List<T> itemsOnDevice,
  );

  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    /* dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Online Service | Server',
    ); */
  }
}
