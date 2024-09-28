// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:content_store/src/storage_service/models/file_system/models/cl_directories.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import 'cl_server.dart';
import 'downloader.dart';
import 'gallery_pin.dart';

abstract class DBReader {}

@immutable
class StoreUpdater {
  StoreUpdater({
    required this.store,
    required this.directories,
    required this.downloader,
    this.server,
  })  : tempCollectionName = '*** Recently Captured',
        albumManager = AlbumManager(albumName: 'KeepIt'),
        allowOnlineViewIfNotDownloaded = false;
  final Store store;
  final CLDirectories directories;
  final CLServer? server;
  final AlbumManager albumManager;
  final Downloader downloader;
  final String tempCollectionName;
  final bool allowOnlineViewIfNotDownloaded;

  StoreUpdater copyWith({
    Store? store,
    CLDirectories? directories,
    ValueGetter<CLServer?>? server,
    Downloader? downloader,
  }) {
    return StoreUpdater(
      store: store ?? this.store,
      directories: directories ?? this.directories,
      server: server != null ? server.call() : this.server,
      downloader: downloader ?? this.downloader,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'StoreUpdater(store: $store, directories: $directories, server: $server, albumManager: $albumManager, downloader: $downloader, tempCollectionName: $tempCollectionName, allowOnlineViewIfNotDownloaded: $allowOnlineViewIfNotDownloaded)';
  }

  @override
  bool operator ==(covariant StoreUpdater other) {
    if (identical(this, other)) return true;

    return other.store == store &&
        other.directories == directories &&
        other.server == server &&
        other.albumManager == albumManager &&
        other.downloader == downloader &&
        other.tempCollectionName == tempCollectionName &&
        other.allowOnlineViewIfNotDownloaded == allowOnlineViewIfNotDownloaded;
  }

  @override
  int get hashCode {
    return store.hashCode ^
        directories.hashCode ^
        server.hashCode ^
        albumManager.hashCode ^
        downloader.hashCode ^
        tempCollectionName.hashCode ^
        allowOnlineViewIfNotDownloaded.hashCode;
  }
}
