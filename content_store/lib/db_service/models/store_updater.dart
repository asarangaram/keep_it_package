// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:content_store/storage_service/models/file_system/models/cl_directories.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import 'collection_updater.dart';
import 'gallery_pin.dart';

abstract class DBReader {}

@immutable
class StoreUpdater {
  StoreUpdater({
    required this.store,
    required this.directories,
  })  : tempCollectionName = '*** Recently Captured',
        albumManager = AlbumManager(albumName: 'KeepIt'),
        collectionUpdater = CollectionUpdater(store);
  final Store store;
  final CLDirectories directories;

  final AlbumManager albumManager;
  final CollectionUpdater collectionUpdater;
  final String tempCollectionName;

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
    // ignore: lines_longer_than_80_chars
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
}
