import 'package:content_store/storage_service/models/file_system/models/cl_directories.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import 'collection_updater.dart';
import 'gallery_pin.dart';
import 'media_updater.dart';

abstract class DBReader {}

@immutable
class StoreUpdater {
  StoreUpdater({
    required this.store,
    required this.directories,
  }) {
    tempCollectionName = '*** Recently Captured';
    albumManager = AlbumManager(albumName: 'KeepIt');
    collectionUpdater = CollectionUpdater(store);
    mediaUpdater = MediaUpdater(
      store: store,
      directories: directories,
      albumManager: albumManager,
      getCollectionByLabel: collectionUpdater.getCollectionByLabel,
      tempCollectionName: tempCollectionName,
    );
  }
  final Store store;
  final CLDirectories directories;

  late final AlbumManager albumManager;
  late final CollectionUpdater collectionUpdater;
  late final MediaUpdater mediaUpdater;
  late final String tempCollectionName;

  StoreUpdater copyWith({
    Store? store,
    CLDirectories? directories,
  }) {
    return StoreUpdater(
      store: store ?? this.store,
      directories: directories ?? this.directories,
    );
  }

  @override
  String toString() {
    return 'StoreUpdater(store: $store, directories: $directories, albumManager: $albumManager, tempCollectionName: $tempCollectionName)';
  }

  @override
  bool operator ==(covariant StoreUpdater other) {
    if (identical(this, other)) return true;

    return other.store == store &&
        other.directories == directories &&
        other.albumManager == albumManager &&
        other.tempCollectionName == tempCollectionName;
  }

  @override
  int get hashCode {
    return store.hashCode ^
        directories.hashCode ^
        albumManager.hashCode ^
        tempCollectionName.hashCode;
  }

  String createTempFile({required String ext}) {
    final dir = directories.download.path; // FIXME temp Directory
    final fileBasename = 'keep_it_${DateTime.now().millisecondsSinceEpoch}';
    final absolutePath = '${dir.path}/$fileBasename.$ext';

    return absolutePath;
  }
}
